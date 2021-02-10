module Update.Line exposing (break, breakLineAfter, breakLineBefore)

import Array
import ArrayUtil
import EditorModel exposing (AutoLineBreak(..), EditorModel)
import EditorMsg exposing (Position)


break : EditorModel -> EditorModel
break model =
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
                    if currentLineLength <= k then
                        model

                    else if currentLineLength == model.cursor.column then
                        case breakLineBefore k currentLine of
                            ( _, Nothing ) ->
                                model

                            ( adjustedLine, Just extraLine ) ->
                                let
                                    newCursor =
                                        { line = line + 1, column = String.length extraLine }
                                in
                                model
                                    |> replaceLineAt line adjustedLine
                                    |> insertLineAfter line extraLine
                                    |> putCursorAt newCursor

                    else
                        case breakLineAfter model.cursor.column currentLine of
                            ( _, Nothing ) ->
                                model

                            ( adjustedLine, Just extraLine ) ->
                                let
                                    newCursor =
                                        model.cursor
                                in
                                model
                                    |> replaceLineAt line adjustedLine
                                    |> insertLineAfter line extraLine
                                    |> putCursorAt newCursor



-- LINE BREAKING


optimumWrapWidth : EditorModel -> Int
optimumWrapWidth model =
    charactersPerLine model.width model.fontSize
        - 6
        |> truncate


charactersPerLine : Float -> Float -> Float
charactersPerLine screenWidth fontSize =
    (1.55 * screenWidth) / fontSize


putCursorAt : Position -> EditorModel -> EditorModel
putCursorAt position model =
    { model | cursor = position }


replaceLineAt : Int -> String -> EditorModel -> EditorModel
replaceLineAt k str model =
    { model | lines = Array.set k str model.lines }


insertLineAfter : Int -> String -> EditorModel -> EditorModel
insertLineAfter k str model =
    { model | lines = ArrayUtil.insertLineAfter k str model.lines }


breakLineAfter : Int -> String -> ( String, Maybe String )
breakLineAfter k str =
    if String.length str > k then
        let
            indexOfSucceedingBlank =
                str
                    |> String.indexes " "
                    |> List.filter (\i -> i > k)
                    |> List.head
                    |> Maybe.withDefault k
        in
        splitStringAt (indexOfSucceedingBlank + 1) str
            |> (\( a, b ) -> ( a, Just b ))

    else
        ( str, Nothing )


splitStringAt : Int -> String -> ( String, String )
splitStringAt k str =
    let
        n =
            String.length str
    in
    ( String.slice 0 k str, String.slice k n str )



-- BREAK LINES


breakLineBefore : Int -> String -> ( String, Maybe String )
breakLineBefore k str =
    if String.length str > k then
        let
            indexOfPrecedingBlank =
                str
                    |> String.indexes " "
                    |> List.filter (\i -> i < k)
                    |> List.reverse
                    |> List.head
                    |> Maybe.withDefault k
        in
        if indexOfPrecedingBlank <= k then
            splitStringAt (indexOfPrecedingBlank + 1) str
                |> (\( a, b ) -> ( a, Just b ))

        else
            ( str, Nothing )

    else
        ( str, Nothing )
