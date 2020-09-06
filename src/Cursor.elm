module Cursor exposing (CursorList
      , updateHeadWithPosition
      , update
      , CursorId
      , Cursor
      , initalCursor
     , updatePosition
     , position
     , init)

import EditorMsg exposing (Position)
import List.Extra
import List.Nonempty exposing(Nonempty)


type alias Cursor comparable =
    { id : comparable, position : Position, color : String }


type alias CursorId =
    String

type alias CursorList comparable = Nonempty (Cursor comparable)

-- (1, current) cursorData.native : Position
-- (2, proposed) cursorData.native.position : Position

position : CursorList comparable -> Position
position cursor =
  (List.Nonempty.head cursor).position

initalCursor : Cursor String
initalCursor = {id = "self", position = Position 0 0, color = "orange"}

updatePosition : Position -> Cursor comparable -> Cursor comparable
updatePosition position_ cursor =
    { cursor | position = position_ }

init : CursorList String
init = List.Nonempty.fromElement initalCursor

updateHeadWithPosition : Position -> CursorList comparable -> CursorList comparable
updateHeadWithPosition position_ cursorList =
    List.Nonempty.replaceHead (updatePosition position_ (List.Nonempty.head cursorList)) cursorList

update : Cursor comparable -> Nonempty (Cursor comparable) -> Nonempty (Cursor comparable)
update fc list =
            setIf (\fc_ -> fc_.id == fc.id) fc list



-- HELPERS

setIf : (a -> Bool) -> a -> Nonempty a -> Nonempty a
setIf predicate replacement list =
    updateIf predicate (always replacement) list


{-| Replace all values that satisfy a predicate by calling an update function.
-}
updateIf : (a -> Bool) -> (a -> a) -> Nonempty a -> Nonempty a
updateIf predicate update_ list =
    List.Nonempty.map
        (\item ->
            if predicate item then
                update_ item

            else
                item
        )
        list