module Update.Line exposing (break)

import Array
import Model exposing (AutoLineBreak(..), Model, Position)
import Update.Function


break : Model -> Model
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
                    case currentLineLength <= k of
                        True ->
                            model

                        False ->
                            case currentLineLength == model.cursor.column of
                                True ->
                                    case Update.Function.breakLineBefore k currentLine of
                                        ( _, Nothing ) ->
                                            model

                                        ( adjustedLine, Just extraLine ) ->
                                            let
                                                newCursor =
                                                    { line = line + 1, column = String.length extraLine }
                                            in
                                            model
                                                |> Update.Function.replaceLineAt line adjustedLine
                                                |> Update.Function.insertLineAfter line extraLine
                                                |> putCursorAt newCursor

                                False ->
                                    case Update.Function.breakLineAfter model.cursor.column currentLine of
                                        ( _, Nothing ) ->
                                            model

                                        ( adjustedLine, Just extraLine ) ->
                                            let
                                                newCursor =
                                                    model.cursor
                                            in
                                            model
                                                |> Update.Function.replaceLineAt line adjustedLine
                                                |> Update.Function.insertLineAfter line extraLine
                                                |> putCursorAt newCursor



-- LINE BREAKING


optimumWrapWidth : Model -> Int
optimumWrapWidth model =
    charactersPerLine model.width model.fontSize
        - 6
        |> truncate


charactersPerLine : Float -> Float -> Float
charactersPerLine screenWidth fontSize =
    (1.55 * screenWidth) / fontSize


putCursorAt : Position -> Model -> Model
putCursorAt position model =
    { model | cursor = position }
