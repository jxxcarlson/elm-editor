module Window exposing (Window, empty, lines, shiftCursor)

import Array exposing(Array(..))
import EditorMsg exposing(Position)

type alias Window = {
     offset : Int
   , height : Int
  }


empty : Int -> Window
empty height  =  {
    offset = 0
  , height = height
 }


shiftCursor : Window -> Position -> Position
shiftCursor window pos =
    {pos | line = pos.line + window.offset}



positive  : Int -> Int
positive x = if x < 0 then 0 else x

lines : Int -> Window -> Array String -> Array String
lines lineNumber window lines_ =
    let
        offset = positive (lineNumber - 2*window.height)
    in
      Array.slice offset (offset + 4*window.height) lines_
