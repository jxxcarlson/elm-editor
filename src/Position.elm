module Position exposing (..)


type alias Position =
    { line : Int
    , column : Int
    }


deltaLine : Int -> Position -> Position
deltaLine delta pos =
    { pos | line = pos.line + delta }


deltaColumn : Int -> Position -> Position
deltaColumn delta pos =
    { pos | column = pos.column + delta }
