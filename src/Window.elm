module Window exposing (Window, empty, lines, shift, recenter, shiftPosition, shiftPosition2, shiftPosition3, shiftPosition_)

import Array exposing(Array(..))
import EditorMsg exposing(Position)

type alias Window = {
     offset : Int
   , height : Int
  }


midLine : Window -> Int
midLine window = 2*window.height

empty : Int -> Window
empty height  =  {
    offset = 0
  , height = height
 }

shiftPosition_ : Int -> Position -> Position
shiftPosition_ k pos =
    {pos | line = pos.line + k}

shiftPosition : Window -> Position -> Position
shiftPosition window pos =
  if pos.line < 2*window.height then
    pos
  else
    {pos | line = pos.line + window.offset}


shiftPosition2 : Window -> Position -> Position
shiftPosition2 window pos =
  if pos.line < 2*window.height then
    pos
  else
    {pos | line = window.offset}

shiftPosition3 : Int -> Window -> Position -> Position
shiftPosition3 k window pos =
  if pos.line < 2*window.height then
    pos
  else
    {pos | line = window.offset + k}

shift : Int -> Window -> Window
shift offset window =
    {window | offset = offset}


-- recenter : Int -> Window -> Window
recenter : Int -> Window -> { window : Window, windowLine : Int }
recenter lineNumber window =
    if lineNumber < 2*window.height then
      {window = {window | offset = 0}, windowLine = lineNumber}
    else --
      {window = {window | offset = lineNumber}, windowLine = (midLine window) - 5}

positive  : Int -> Int
positive x = if x < 0 then 0 else x

lines : Int -> Window -> Array String -> Array String
lines lineNumber window lines_ =
    let
        offset = positive (lineNumber - 2*window.height)
    in
      Array.slice offset (offset + 4*window.height) lines_
