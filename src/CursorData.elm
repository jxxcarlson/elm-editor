module CursorData exposing (CursorData, updateNative, CursorId, ForeignCursor, set)

import EditorMsg exposing (Position)
import List.Extra


type alias ForeignCursor comparable =
    { id : comparable, position : Position, color : String }


type alias CursorId =
    String

type alias CursorData comparable = { native : Position, foreign : List (ForeignCursor comparable)}

updateNative : Position -> CursorData comparable -> CursorData comparable
updateNative position cursorData =
    { native = position, foreign = cursorData.foreign}

set : ForeignCursor comparable -> List (ForeignCursor comparable) -> List (ForeignCursor comparable)
set fc list =
    case List.head (List.filter (\fc_ -> fc_.id == fc.id) list) of
        Nothing ->
            fc :: list

        Just _ ->
            List.Extra.setIf (\fc_ -> fc_.id == fc.id) fc list
