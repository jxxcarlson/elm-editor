module Document exposing (Document, MiniFileRecord)


type alias ExtendedDocument =
    { fileName : String
    , id : String
    , content : String
    , token : String
    }


type alias Document =
    { fileName : String
    , id : String
    , content : String
    }


type alias MiniFileRecord =
    { id : String
    , fileName : String
    }
