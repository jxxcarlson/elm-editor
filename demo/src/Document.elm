module Document exposing
    ( DocType(..)
    , Document
    , Metadata
    , NewDocumentData
    , changeDocType
    , docType
    , fileExtension
    , new
    , titleFromFileName
    , toMetadata
    )


type DocType
    = MarkdownDoc
    | MiniLaTeXDoc


type alias Document =
    { fileName : String
    , id : String
    , content : String
    }


type alias SimpleDocument a =
    { a
        | fileName : String
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


toMetadata : Document -> Metadata
toMetadata doc =
    { id = doc.id, fileName = doc.fileName }


changeDocType : DocType -> String -> String
changeDocType docType_ fileName =
    case docType_ of
        MiniLaTeXDoc ->
            titleFromFileName fileName ++ ".tex"

        MarkdownDoc ->
            titleFromFileName fileName ++ ".md"


titleFromFileName : String -> String
titleFromFileName fileName =
    fileName
        |> String.split "."
        |> List.reverse
        |> List.drop 1
        |> List.reverse
        |> String.join "."


fileExtension : String -> String
fileExtension str =
    str |> String.split "." |> List.reverse |> List.head |> Maybe.withDefault "txt"


docType : String -> DocType
docType fileName =
    case fileExtension fileName of
        "md" ->
            MarkdownDoc

        "tex" ->
            MiniLaTeXDoc

        "latex" ->
            MiniLaTeXDoc

        _ ->
            MarkdownDoc
