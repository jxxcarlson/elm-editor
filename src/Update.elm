module Update exposing (update)

import Action
import Array exposing (Array)
import Common exposing (..)
import ContextMenu exposing (ContextMenu)
import Debounce exposing (Debounce)
import History
import Model exposing (Hover(..), Model, Msg(..), Position, Selection(..), Snapshot)
import Task
import UpdateFunction


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "ED.update" msg
    in
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Test ->
            Action.goToLine 30 model

        DebounceMsg msg_ ->
            let
                ( debounce, cmd ) =
                    Debounce.update
                        Model.debounceConfig
                        (Debounce.takeLast unload)
                        msg_
                        model.debounce
            in
            ( { model | debounce = debounce }, cmd )

        Unload _ ->
            ( { model | debounce = model.debounce }, Cmd.none )

        MoveUp ->
            ( { model | cursor = moveUp model.cursor model.lines }
            , Cmd.none
            )
                |> recordHistory model

        MoveDown ->
            ( { model | cursor = moveDown model.cursor model.lines }
            , Cmd.none
            )
                |> recordHistory model

        MoveLeft ->
            ( { model | cursor = moveLeft model.cursor model.lines }
            , Cmd.none
            )
                |> recordHistory model

        MoveRight ->
            ( { model | cursor = moveRight model.cursor model.lines }
            , Cmd.none
            )
                |> recordHistory model

        NewLine ->
            ( newLine model
                |> Common.sanitizeHover
            , Cmd.none
            )

        InsertChar char ->
            let
                ( debounce, debounceCmd ) =
                    Debounce.push Model.debounceConfig char model.debounce
            in
            ( insertChar char { model | debounce = debounce }
            , debounceCmd
            )
                |> recordHistory model

        Cut ->
            UpdateFunction.deleteSelection model

        Copy ->
            UpdateFunction.copySelection model

        Paste ->
            UpdateFunction.pasteSelection model

        RemoveCharBefore ->
            UpdateFunction.deleteSelection model

        FirstLine ->
            Action.firstLine model

        Hover hover ->
            ( { model | hover = hover }
                |> Common.sanitizeHover
            , Cmd.none
            )

        GoToHoveredPosition ->
            ( { model
                | cursor =
                    case model.hover of
                        NoHover ->
                            model.cursor

                        HoverLine line ->
                            { line = line
                            , column = lastColumn model.lines line
                            }

                        HoverChar position ->
                            position
              }
            , Cmd.none
            )

        LastLine ->
            Action.lastLine model

        AcceptLineToGoTo str ->
            ( { model | lineNumberToGoTo = str }, Cmd.none )

        GoToLine ->
            case String.toInt model.lineNumberToGoTo of
                Nothing ->
                    ( model, Cmd.none )

                Just n ->
                    Action.goToLine n model

        RemoveCharAfter ->
            ( removeCharAfter model
                |> Common.sanitizeHover
            , Cmd.none
            )
                |> recordHistory model

        StartSelecting ->
            ( { model | selection = SelectingFrom model.hover }
            , Cmd.none
            )

        StopSelecting ->
            -- Selection for all other
            let
                endHover =
                    model.hover

                newSelection =
                    case model.selection of
                        NoSelection ->
                            NoSelection

                        SelectingFrom startHover ->
                            if startHover == endHover then
                                case startHover of
                                    NoHover ->
                                        NoSelection

                                    HoverLine _ ->
                                        NoSelection

                                    HoverChar position ->
                                        SelectedChar position

                            else
                                hoversToPositions model.lines startHover endHover
                                    |> Maybe.map (\( from, to ) -> Selection from to)
                                    |> Maybe.withDefault NoSelection

                        SelectedChar _ ->
                            NoSelection

                        Selection _ _ ->
                            NoSelection
            in
            ( { model | selection = newSelection }
            , Cmd.none
            )

        SelectLine ->
            Action.selectLine model

        MoveToLineStart ->
            Action.moveToLineStart model

        MoveToLineEnd ->
            Action.moveToLineEnd model

        PageDown ->
            Action.pageDown model

        PageUp ->
            Action.pageUp model

        Clear ->
            ( { model | lines = Array.fromList [ "" ] }, Cmd.none )

        Undo ->
            case History.undo (Common.stateToSnapshot model) model.history of
                Just ( history, snapshot ) ->
                    ( { model
                        | cursor = snapshot.cursor
                        , selection = snapshot.selection
                        , lines = snapshot.lines
                        , history = history
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        Redo ->
            case History.redo (Common.stateToSnapshot model) model.history of
                Just ( history, snapshot ) ->
                    ( { model
                        | cursor = snapshot.cursor
                        , selection = snapshot.selection
                        , lines = snapshot.lines
                        , history = history
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        ContextMenuMsg msg_ ->
            let
                _ =
                    Debug.log "CTMM" msg_

                ( contextMenu, cmd ) =
                    ContextMenu.update msg_ model.contextMenu
            in
            ( { model | contextMenu = contextMenu }
            , Cmd.map ContextMenuMsg cmd
            )

        Item k ->
            let
                _ =
                    Debug.log "ITEM" k
            in
            ( model, Cmd.none )


newLine : Model -> Model
newLine ({ cursor, lines } as model) =
    let
        { line, column } =
            cursor

        linesList : List String
        linesList =
            Array.toList lines

        line_ : Int
        line_ =
            line + 1

        contentUntilCursor : List String
        contentUntilCursor =
            linesList
                |> List.take line_
                |> List.indexedMap
                    (\i content ->
                        if i == line then
                            String.left column content

                        else
                            content
                    )

        restOfLineAfterCursor : String
        restOfLineAfterCursor =
            String.dropLeft column (lineContent lines line)

        restOfLines : List String
        restOfLines =
            List.drop line_ linesList

        newLines : Array String
        newLines =
            (contentUntilCursor
                ++ [ restOfLineAfterCursor ]
                ++ restOfLines
            )
                |> Array.fromList

        newCursor : Position
        newCursor =
            { line = line_
            , column = 0
            }
    in
    { model
        | lines = newLines
        , cursor = newCursor
    }


insertChar : String -> Model -> Model
insertChar char ({ cursor, lines } as model) =
    let
        { line, column } =
            cursor

        lineWithCharAdded : String -> String
        lineWithCharAdded content =
            String.left column content
                ++ char
                ++ String.dropLeft column content

        newLines : Array String
        newLines =
            lines
                |> Array.indexedMap
                    (\i content ->
                        if i == line then
                            lineWithCharAdded content

                        else
                            content
                    )

        newCursor : Position
        newCursor =
            { line = line
            , column = column + 1
            }
    in
    { model
        | lines = newLines
        , cursor = newCursor
    }



-- DEBOUNCE


unload : String -> Cmd Msg
unload s =
    Task.perform Unload (Task.succeed s)
