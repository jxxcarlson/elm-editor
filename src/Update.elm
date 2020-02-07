module Update exposing (update)

import Action
import Array exposing (Array)
import Common exposing (..)
import ContextMenu exposing (ContextMenu)
import Debounce exposing (Debounce)
import History
import Model exposing (Hover(..), Model, Msg(..), Position, Selection(..), Snapshot)
import Task


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
                |> sanitizeHover
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

        RemoveCharBefore ->
            let
                ( debounce, debounceCmd ) =
                    Debounce.push Model.debounceConfig "RCB" model.debounce
            in
            case model.selection of
                NoSelection ->
                    ( removeCharBefore { model | debounce = debounce }
                        |> sanitizeHover
                    , debounceCmd
                    )
                        |> recordHistory model

                (Selection beginSel endSel) as sel ->
                    let
                        newLines =
                            Action.deleteSelection sel model.lines
                    in
                    ( { model | lines = newLines, cursor = beginSel, selection = NoSelection } |> sanitizeHover, debounceCmd )
                        |> recordHistory model

                SelectedChar _ ->
                    ( removeCharBefore { model | debounce = debounce }
                        |> sanitizeHover
                    , debounceCmd
                    )
                        |> recordHistory model

                _ ->
                    ( removeCharBefore { model | debounce = debounce }
                        |> sanitizeHover
                    , debounceCmd
                    )
                        |> recordHistory model

        FirstLine ->
            Action.firstLine model

        Hover hover ->
            ( { model | hover = hover }
                |> sanitizeHover
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
                |> sanitizeHover
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
            case History.undo (stateToSnapshot model) model.history of
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
            case History.redo (stateToSnapshot model) model.history of
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


sanitizeHover : Model -> Model
sanitizeHover model =
    { model
        | hover =
            case model.hover of
                NoHover ->
                    model.hover

                HoverLine line ->
                    HoverLine (clamp 0 (lastLine model.lines) line)

                HoverChar { line, column } ->
                    let
                        sanitizedLine =
                            clamp 0 (lastLine model.lines) line

                        sanitizedColumn =
                            clamp 0 (lastColumn model.lines sanitizedLine) column
                    in
                    HoverChar
                        { line = sanitizedLine
                        , column = sanitizedColumn
                        }
    }


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



-- HISTORY


stateToSnapshot : Model -> Snapshot
stateToSnapshot model =
    { cursor = model.cursor, selection = model.selection, lines = model.lines }


recordHistory :
    Model
    -> ( Model, Cmd Msg )
    -> ( Model, Cmd Msg )
recordHistory oldModel ( newModel, cmd ) =
    ( { newModel
        | history =
            if oldModel.lines /= newModel.lines then
                History.push
                    (stateToSnapshot oldModel)
                    newModel.history

            else
                newModel.history
      }
    , cmd
    )



-- DEBOUNCE


unload : String -> Cmd Msg
unload s =
    Task.perform Unload (Task.succeed s)
