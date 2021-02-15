module Line exposing (lastColumn, lastPosition)

import Array exposing (Array)
import Position exposing (Position)


lastColumn : Int -> Array String -> Int
lastColumn lineNumber lines =
    Array.get lineNumber lines
        |> Maybe.map String.length
        |> Maybe.withDefault 0
        |> (\x -> x - 1)


lastPosition : Int -> Array String -> Position
lastPosition lineNumber lines =
    { line = lineNumber, column = lastColumn lineNumber lines }
