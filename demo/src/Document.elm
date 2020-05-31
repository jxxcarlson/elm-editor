module Document exposing (BasicDocument, MiniFileRecord)


type alias BasicDocument =
    { fileName : String
    , id : String
    , content : String
    }


type alias MiniFileRecord =
    { id : String
    , fileName : String
    }
