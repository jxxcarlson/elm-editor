module Window exposing (Window, empty, lines, positive, shift, recenter, shiftPosition, shiftHover, shiftSelection)

import Array exposing(Array(..))
import EditorMsg exposing(Position, Selection(..), Hover(..))

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

shiftPosition : Int -> Position -> Position
shiftPosition k pos =
    {pos | line = pos.line + k}


shiftHover : Int -> Hover -> Hover
shiftHover k h =
    case h of
        NoHover -> NoHover
        HoverLine l -> HoverLine (l + k)
        HoverChar p -> HoverChar (shiftPosition k p)


shiftSelection : Int -> Selection -> Selection
shiftSelection k sel =
    case sel of
        NoSelection -> NoSelection
        SelectingFrom hover -> SelectingFrom (shiftHover k hover)
        SelectedChar pos -> SelectedChar (shiftPosition k pos)
        Selection p q -> Selection (shiftPosition k p) (shiftPosition k q)


shift : Int -> Window -> Window
shift offset window =
    {window | offset = offset}


-- recenter : Int -> Window -> Window
recenter : Int -> Window -> { window : Window, windowLine : Int }
recenter lineNumber window =
    if lineNumber < window.height then
      {window = {window | offset = 0}, windowLine = lineNumber}
    else --
      {window = {window | offset = lineNumber}, windowLine = 0}

positive  : Int -> Int
positive x = if x < 0 then 0 else x

lines : Window -> Array String -> Array String
lines window lines_ =
      Array.slice window.offset (window.offset + window.height) lines_
