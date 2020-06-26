module Document exposing
    ( DocType(..)
    , Document
    , Metadata
    , NewDocumentData
    , changeDocType
    , docType
    , extendFileName
    , extensionOfDocType
    , fileExtension
    , stringOfDocType
    , titleFromFileName
    , toMetadata
    )

import Time


type DocType
    = MarkdownDoc
    | MiniLaTeXDoc


type alias Document =
    { fileName : String
    , id : String
    , author : String
    , timeCreated : Time.Posix
    , timeUpdated : Time.Posix
    , tags : List String
    , categories : List String
    , title : String
    , subtitle : String
    , abstract : String
    , belongsTo : String
    , docType : DocType
    , content : String
    }


type alias Metadata =
    { fileName : String
    , id : String
    , author : String
    , timeCreated : Time.Posix
    , timeUpdated : Time.Posix
    , tags : List String
    , categories : List String
    , title : String
    , subtitle : String
    , abstract : String
    , belongsTo : String
    , docType : DocType
    }


type alias SimpleDocument a =
    { a
        | fileName : String
        , id : String
        , content : String
    }


type alias NewDocumentData =
    SimpleDocument { docType : DocType }


shortId : String -> String
shortId uuid =
    let
        parts_ =
            String.split "-" uuid

        parts =
            parts_ |> List.drop 1 |> List.take 2
    in
    String.join "-" parts


extendFileName : DocType -> String -> String -> String -> String
extendFileName docType_ prefix uuid fileName =
    let
        shortId_ =
            shortId uuid

        ext =
            case docType_ of
                MarkdownDoc ->
                    ".md"

                MiniLaTeXDoc ->
                    ".tex"

        removeMDSuffix s =
            case String.right 3 s == ".md" of
                True ->
                    String.dropRight 3 s

                False ->
                    s

        removeTeXSuffix s =
            case String.right 4 s == ".tex" of
                True ->
                    String.dropRight 4 s

                False ->
                    s

        fileName_ =
            fileName |> removeMDSuffix |> removeTeXSuffix
    in
    case prefix of
        "" ->
            fileName_ ++ "-" ++ shortId_ ++ ext

        _ ->
            prefix ++ "." ++ fileName_ ++ "-" ++ shortId_ ++ ext


toMetadata : Document -> Metadata
toMetadata doc =
    { fileName = doc.fileName
    , id = doc.id
    , author = doc.author
    , timeCreated = doc.timeCreated
    , timeUpdated = doc.timeUpdated
    , tags = doc.tags
    , title = doc.title
    , subtitle = doc.subtitle
    , abstract = doc.abstract
    , belongsTo = doc.belongsTo
    , categories = doc.categories
    , docType = doc.docType
    }


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


extensionOfDocType : DocType -> String
extensionOfDocType docType_ =
    case docType_ of
        MarkdownDoc ->
            "md"

        MiniLaTeXDoc ->
            "tex"


stringOfDocType : DocType -> String
stringOfDocType docType_ =
    case docType_ of
        MarkdownDoc ->
            "markdown"

        MiniLaTeXDoc ->
            "minilatex"


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
