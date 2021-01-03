module Window exposing (Window, empty, lines, shift, recenter, shiftPosition)

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


shiftPosition : Window -> Position -> Position
shiftPosition window pos =
  if pos.line < 2*window.height then
    pos
  else
    {pos | line = pos.line + window.offset}

shift : Int -> Window -> Window
shift offset window =
    {window | offset = offset}


-- recenter : Int -> Window -> Window
recenter : Int -> Window -> { window : Window, line : Int }
recenter lineNumber window =
    if lineNumber < 2*window.height then
      {window = {window | offset = 0}, line = lineNumber}
    else
      {window = {window | offset = lineNumber}, line = 2*window.height}

positive  : Int -> Int
positive x = if x < 0 then 0 else x

lines : Int -> Window -> Array String -> Array String
lines lineNumber window lines_ =
    let
        offset = positive (lineNumber - 2*window.height)
    in
      Array.slice offset (offset + 4*window.height) lines_
