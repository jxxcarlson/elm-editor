module Update exposing (update)

import Action
import Array exposing (Array)
import Common exposing (..)
import ContextMenu exposing (ContextMenu)
import Debounce exposing (Debounce)
import History
import Model exposing (AutoLineBreak(..), Hover(..), Model, Msg(..), Position, Selection(..), Snapshot)
import Task
import UpdateFunction
import Wrap exposing (WrapParams)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
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
            ( insertChar char { model | debounce = debounce } |> breakLine
            , debounceCmd
            )
                |> recordHistory model

        KillLine ->
            let
                lineNumber =
                    model.cursor.line

                newCursor =
                    { line = lineNumber, column = 0 }

                lastColumnOfLine =
                    Array.get lineNumber model.lines
                        |> Maybe.map String.length
                        |> Maybe.withDefault 0
                        |> (\x -> x - 1)

                lineEnd =
                    { line = lineNumber, column = lastColumnOfLine }

                newSelection =
                    Selection newCursor lineEnd

                ( newLines, selectedText ) =
                    Action.deleteSelection newSelection model.lines
            in
            ( { model | lines = newLines, selectedText = selectedText }, Cmd.none )
                |> recordHistory model

        Cut ->
            UpdateFunction.deleteSelection model
                |> recordHistory model

        Copy ->
            UpdateFunction.copySelection model

        Paste ->
            UpdateFunction.pasteSelection model
                |> recordHistory model

        RemoveCharBefore ->
            UpdateFunction.deleteSelection model
                |> recordHistory model

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
                ( contextMenu, cmd ) =
                    ContextMenu.update msg_ model.contextMenu
            in
            ( { model | contextMenu = contextMenu }
            , Cmd.map ContextMenuMsg cmd
            )

        Item k ->
            ( model, Cmd.none )

        WrapSelection ->
            case model.selection of
                Selection p1 p2 ->
                    let
                        params =
                            { maximumWidth = maxWrapWidth model
                            , optimalWidth = optimumWrapWidth model
                            , stringWidth = String.length
                            }

                        ( _, selectedText ) =
                            Action.deleteSelection model.selection model.lines

                        newLines =
                            Wrap.stringArray params selectedText

                        n =
                            Array.length newLines

                        c =
                            Array.get (n - 1) newLines
                                |> Maybe.map String.length
                                |> Maybe.withDefault 0

                        newCursor =
                            { line = p1.line + n - 1, column = c }
                    in
                    UpdateFunction.replaceLines { model | cursor = newCursor } newLines
                        |> recordHistory model

                _ ->
                    ( model, Cmd.none )

        WrapAll ->
            let
                params =
                    { maximumWidth = maxWrapWidth model, optimalWidth = optimumWrapWidth model, stringWidth = String.length }

                lines =
                    Wrap.stringArray params model.lines
            in
            ( { model | lines = lines }, Cmd.none )
                |> recordHistory model

        ToggleAutoLineBreak ->
            case model.autoLineBreak of
                AutoLineBreakOFF ->
                    ( { model | autoLineBreak = AutoLineBreakON }, Cmd.none )

                AutoLineBreakON ->
                    ( { model | autoLineBreak = AutoLineBreakOFF }, Cmd.none )


maxWrapWidth : Model -> Int
maxWrapWidth model =
    charactersPerLine model.width model.fontSize
        - 3
        |> truncate


optimumWrapWidth : Model -> Int
optimumWrapWidth model =
    charactersPerLine model.width model.fontSize
        - 6
        |> truncate


charactersPerLine : Float -> Float -> Float
charactersPerLine screenWidth fontSize =
    (1.55 * screenWidth) / fontSize


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

        maxLineLength =
            20

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



-- LINE BREAKING


breakLine : Model -> Model
breakLine model =
    case model.autoLineBreak of
        AutoLineBreakOFF ->
            model

        AutoLineBreakON ->
            let
                k =
                    optimumWrapWidth model

                line =
                    model.cursor.line
            in
            case Array.get line model.lines of
                Nothing ->
                    model

                Just currentLine ->
                    let
                        currentLineLength =
                            String.length currentLine
                    in
                    case currentLineLength <= k of
                        True ->
                            model

                        False ->
                            case currentLineLength == model.cursor.column of
                                True ->
                                    case UpdateFunction.breakLineBefore k currentLine of
                                        ( _, Nothing ) ->
                                            model

                                        ( adjustedLine, Just extraLine ) ->
                                            let
                                                newCursor =
                                                    { line = line + 1, column = String.length extraLine }
                                            in
                                            model
                                                |> UpdateFunction.replaceLineAt line adjustedLine
                                                |> UpdateFunction.insertLineAfter line extraLine
                                                |> putCursorAt newCursor

                                False ->
                                    case UpdateFunction.breakLineAfter model.cursor.column currentLine of
                                        ( _, Nothing ) ->
                                            model

                                        ( adjustedLine, Just extraLine ) ->
                                            let
                                                newCursor =
                                                    model.cursor
                                            in
                                            model
                                                |> UpdateFunction.replaceLineAt line adjustedLine
                                                |> UpdateFunction.insertLineAfter line extraLine
                                                |> putCursorAt newCursor


putCursorAt : Position -> Model -> Model
putCursorAt position model =
    { model | cursor = position }



-- DEBOUNCE


unload : String -> Cmd Msg
unload s =
    Task.perform Unload (Task.succeed s)
