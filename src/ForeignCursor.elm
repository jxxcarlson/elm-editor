module ForeignCursor exposing (CursorId, ForeignCursor, set)

import EditorMsg exposing (Position)
import List.Extra


type alias ForeignCursor comparable =
    { id : comparable, position : Position }


type alias Color =
    String


type alias CursorId =
    String


set : ForeignCursor comparable -> List (ForeignCursor comparable) -> List (ForeignCursor comparable)
set fc list =
    case List.head (List.filter (\fc_ -> fc_.id == fc.id) list) of
        Nothing ->
            fc :: list

        Just _ ->
            List.Extra.setIf (\fc_ -> fc_.id == fc.id) fc list
