module Window exposing
    ( Window
    ,  init
       -- used in Editor.Model

    ,  lines
       -- used in View.Editor

    ,  positive
       -- used in Action

    ,  recenter
       -- used in Action

    ,  shift
       -- used in Update

    ,  shiftHover
       -- used in View.Editor

    ,  shiftPosition
       -- used in Update and View.Editor

    ,  shiftSelection
       -- used in View.Editor

    )

import Array exposing (Array(..))
import EditorMsg exposing (Hover(..), Position, Selection(..))
import OuterConfig


{-| A Window w defines a contiguous subset of the lines of an array,
begin at w.offset. The number of elements in w is at most w.height.

model.window points to the window in the full array of lines
that is visible to the editor.

-}
type alias Window =
    { offset : Int
    , height : Int
    }


midLine : Window -> Int
midLine window =
    2 * window.height


init : Int -> Window
init height =
    { offset = 0
    , height = height
    }


shiftPosition : Int -> Position -> Position
shiftPosition k pos =
    { pos | line = pos.line + k }


shiftHover : Int -> Hover -> Hover
shiftHover k h =
    case h of
        NoHover ->
            NoHover

        HoverLine l ->
            HoverLine (l + k)

        HoverChar p ->
            HoverChar (shiftPosition k  p)


shiftSelection : Int -> Selection -> Selection
shiftSelection k sel =
    case sel of
        NoSelection ->
            NoSelection

        SelectingFrom hover ->
            SelectingFrom (shiftHover k hover)

        SelectedChar pos ->
            SelectedChar (shiftPosition k pos)

        Selection p q ->
            Selection (shiftPosition k p) (shiftPosition k q)


shift : Int -> Window -> Window
shift line window =
    if line < window.offset + (window.height // 3) then
        -- decrease the offset because we are too close to the top of the window
        { window | offset = positive <| line - window.height // 2 }

    else if line > window.offset + (2 * window.height) // 3 then
        -- increase the offset because we are too close to the bottom of the window
        { window | offset = positive <| line - window.height // 2 }

    else
         window


recenter : Int -> Window -> { window : Window, windowLine : Int }
recenter lineNumber window =
    { window = { window | offset = positive (lineNumber - OuterConfig.topMargin) }, windowLine = 0 }


recenterIfClose : Int -> Window -> { window : Window, line : Int }
recenterIfClose k w =
    let
        delta =
            5

        eta =
            20
    in
    if k < delta then
        { window = { w | offset = w.offset - eta }, line = delta }

    else if k > w.height - delta then
        { window = { w | offset = w.offset + eta }, line = w.height - delta }

    else
        { window = w, line = k }


positive : Int -> Int
positive x =
    if x < 0 then
        0

    else
        x


lines : Window -> Array String -> Array String
lines window lines_ =
    Array.slice window.offset (window.offset + window.height) lines_
