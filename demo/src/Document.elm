module Document exposing (Document, MiniFileRecord, miniFileRecord)


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


miniFileRecord : Document -> MiniFileRecord
miniFileRecord doc =
    { id = doc.id, fileName = doc.fileName }
