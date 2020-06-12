module Document exposing
    ( DocType(..)
    , Document
    , Metadata
    , NewDocumentData
    , miniFileRecord
    , new
    )


type DocType
    = MarkdownDoc
    | MiniLaTeXDoc


type alias Document =
    { fileName : String
    , id : String
    , content : String
    }


type alias Metadata =
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


miniFileRecord : Document -> Metadata
miniFileRecord doc =
    { id = doc.id, fileName = doc.fileName }
