module Document exposing
    ( DocType(..)
    , Document
    , MiniFileRecord
    , NewDocumentData
    , miniFileRecord
    , new
    )


type DocType
    = MarkdownDoc
    | MiniLaTeXDoc


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


type alias NewDocumentData =
    { fileName : String
    , id : String
    , docType : DocType
    , content : String
    }


shortId : String -> String
shortId uuid =
    let
        parts_ =
            String.split "-" uuid

        parts =
            parts_ |> List.drop 1 |> List.take 2
    in
    String.join "-" parts


new : NewDocumentData -> Document
new data =
    let
        shortId_ =
            shortId data.id

        ext =
            case data.docType of
                MarkdownDoc ->
                    ".md"

                MiniLaTeXDoc ->
                    ".tex"

        fileName =
            data.fileName ++ "-" ++ shortId_ ++ ext
    in
    { fileName = fileName, id = data.id, content = data.content }


miniFileRecord : Document -> MiniFileRecord
miniFileRecord doc =
    { id = doc.id, fileName = doc.fileName }
