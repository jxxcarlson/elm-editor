module Common exposing
    ( clampColumn
    , comparePositions
    , endOfDocument
    , hoversToPositions
    , isEndOfDocument
    , isFirstColumn
    , isFirstLine
    , isLastColumn
    , isLastLine
    , isStartOfDocument
    , lastColumn
    , lastLine
    , lineContent
    , lineLength
    , maxLine
    , moveDown
    , moveLeft
    , moveRight
    , moveUp
    , nextLine
    , previousLine
    , recordHistory
    , recordHistoryX
    , recordHistory_
    , removeCharAfter
    , removeCharBefore
    , sanitizeHover
    , startOfDocument
    , stateToSnapshot
    )

import Array exposing (Array)
import Cmd.Extra exposing (withNoCmd)
import History
import Model exposing (Hover(..), Model, Msg(..), Position, Snapshot)


hoversToPositions : Array String -> Hover -> Hover -> Maybe ( Position, Position )
hoversToPositions lines from to =
    let
        selectionLinePosition : Int -> Position -> ( Position, Position )
        selectionLinePosition line position =
            if line >= position.line then
                ( position
                , { line = line, column = lastColumn lines line }
                )

            else
                ( { line = line + 1, column = 0 }
                , position
                )
    in
    case ( from, to ) of
        ( NoHover, _ ) ->
            Nothing

        ( _, NoHover ) ->
            Nothing

        ( HoverLine line1, HoverLine line2 ) ->
            let
                smaller =
                    min line1 line2

                bigger =
                    max line1 line2
            in
            Just
                ( { line = smaller + 1, column = 0 }
                , { line = bigger, column = lastColumn lines bigger }
                )

        ( HoverLine line, HoverChar position ) ->
            Just (selectionLinePosition line position)

        ( HoverChar position, HoverLine line ) ->
            Just (selectionLinePosition line position)

        ( HoverChar position1, HoverChar position2 ) ->
            let
                ( smaller, bigger ) =
                    if comparePositions position1 position2 == LT then
                        ( position1, position2 )

                    else
                        ( position2, position1 )
            in
            Just ( smaller, bigger )


comparePositions : Position -> Position -> Order
comparePositions from to =
    if from.line < to.line || (from.line == to.line && from.column < to.column) then
        LT

    else if from == to then
        EQ

    else
        GT


removeCharBefore : Model -> Model
removeCharBefore ({ cursor, lines } as model) =
    if isStartOfDocument cursor then
        model

    else
        let
            { line, column } =
                cursor

            lineIsEmpty : Bool
            lineIsEmpty =
                lineContent lines line
                    |> String.isEmpty

            removeCharFromLine : ( Int, String ) -> List String
            removeCharFromLine ( lineNum, content ) =
                if lineNum == line - 1 then
                    if isFirstColumn column then
                        [ content ++ lineContent lines line ]

                    else
                        [ content ]

                else if lineNum == line then
                    if isFirstColumn column then
                        []

                    else
                        [ String.left (column - 1) content
                            ++ String.dropLeft column content
                        ]

                else
                    [ content ]

            newLines : Array String
            newLines =
                lines
                    |> Array.toIndexedList
                    |> List.concatMap removeCharFromLine
                    |> Array.fromList
        in
        { model
            | lines = newLines
            , cursor = moveLeft cursor lines
        }


removeCharAfter : Model -> Model
removeCharAfter ({ cursor, lines } as model) =
    if isEndOfDocument lines cursor then
        model

    else
        let
            { line, column } =
                cursor

            isOnLastColumn : Bool
            isOnLastColumn =
                isLastColumn lines line column

            removeCharFromLine : ( Int, String ) -> List String
            removeCharFromLine ( lineNum, content ) =
                if lineNum == line then
                    if isOnLastColumn then
                        [ content ++ lineContent lines (line + 1) ]

                    else
                        [ String.left column content
                            ++ String.dropLeft (column + 1) content
                        ]

                else if lineNum == line + 1 then
                    if isOnLastColumn then
                        []

                    else
                        [ content ]

                else
                    [ content ]

            newLines : Array String
            newLines =
                lines
                    |> Array.toIndexedList
                    |> List.concatMap removeCharFromLine
                    |> Array.fromList
        in
        { model
            | lines = newLines
            , cursor = cursor
        }


moveUp : Position -> Array String -> Position
moveUp { line, column } lines =
    if isFirstLine line then
        startOfDocument

    else
        let
            line_ : Int
            line_ =
                previousLine line
        in
        { line = line_
        , column = clampColumn lines line_ column
        }


moveDown : Position -> Array String -> Position
moveDown { line, column } lines =
    if isLastLine lines line then
        endOfDocument lines

    else
        let
            line_ : Int
            line_ =
                nextLine lines line
        in
        { line = line_
        , column = clampColumn lines line_ column
        }


moveLeft : Position -> Array String -> Position
moveLeft ({ line, column } as position) lines =
    if isStartOfDocument position then
        position

    else if isFirstColumn column then
        let
            line_ : Int
            line_ =
                previousLine line
        in
        { line = line_
        , column = lastColumn lines line_
        }

    else
        { line = line
        , column = column - 1
        }


moveRight : Position -> Array String -> Position
moveRight ({ line, column } as position) lines =
    if isEndOfDocument lines position then
        position

    else if isLastColumn lines line column then
        { line = nextLine lines line
        , column = 0
        }

    else
        { line = line
        , column = column + 1
        }


startOfDocument : Position
startOfDocument =
    { line = 0
    , column = 0
    }


endOfDocument : Array String -> Position
endOfDocument lines =
    { line = lastLine lines
    , column = lastColumn lines (lastLine lines)
    }


isStartOfDocument : Position -> Bool
isStartOfDocument { line, column } =
    isFirstLine line
        && isFirstColumn column


isEndOfDocument : Array String -> Position -> Bool
isEndOfDocument lines { line, column } =
    isLastLine lines line
        && isLastColumn lines line column


isFirstLine : Int -> Bool
isFirstLine line =
    line == 0


isLastLine : Array String -> Int -> Bool
isLastLine lines line =
    line == lastLine lines


isFirstColumn : Int -> Bool
isFirstColumn column =
    column == 0


isLastColumn : Array String -> Int -> Int -> Bool
isLastColumn lines line column =
    column == lastColumn lines line


lastLine : Array String -> Int
lastLine lines =
    Array.length lines - 1


previousLine : Int -> Int
previousLine line =
    (line - 1)
        |> max 0


nextLine : Array String -> Int -> Int
nextLine lines line =
    (line + 1)
        |> min (maxLine lines)


maxLine : Array String -> Int
maxLine lines =
    Array.length lines - 1


clampColumn : Array String -> Int -> Int -> Int
clampColumn lines line column =
    column
        |> clamp 0 (lineLength lines line)


lastColumn : Array String -> Int -> Int
lastColumn lines line =
    lineLength lines line


lineLength : Array String -> Int -> Int
lineLength lines lineNum =
    lineContent lines lineNum
        |> String.length


lineContent : Array String -> Int -> String
lineContent lines lineNum =
    lines
        |> Array.get lineNum
        |> Maybe.withDefault ""


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


recordHistoryX : Model -> ( Model, Cmd Msg )
recordHistoryX model =
    model
        |> recordHistory_ model
        |> withNoCmd


recordHistory_ : Model -> Model -> Model
recordHistory_ oldModel newModel =
    { newModel
        | history =
            if oldModel.lines /= newModel.lines then
                History.push
                    (stateToSnapshot oldModel)
                    newModel.history

            else
                newModel.history
    }
