module Future.Document exposing
    ( Author
    , Manifest
    , Metadata
    , Uuid
    , docTypeOfString
    , stringFromDocType
    )

import Document exposing (DocType(..))
import Time


type alias Author =
    { name : String
    , id : Uuid
    , passwordHash : String
    , email : String
    , timeCreated : Time.Posix
    , timeUpdated : Time.Posix
    }


type alias Metadata =
    { id : Uuid
    , fileName : String

    ----
    , title : String
    , subtitle : String
    , authorName : String
    , authorId : Uuid

    ----
    , domain : String
    , isPublic : Bool
    , tags : List String
    , categories : List String
    , isPartOf : Maybe Uuid
    , level : Int
    , docType : DocType
    , timeCreated : Time.Posix
    , timeUpdated : Time.Posix
    }


type alias Manifest =
    { title : String
    , subtitle : String
    , id : Uuid
    , isPublic : Bool
    , tags : List String
    , categories : List String
    , authorName : String
    , authorId : Uuid
    , description : String
    , items : List Uuid
    , timeCreated : Time.Posix
    , timeUpdated : Time.Posix
    }


docTypeOfString : String -> DocType
docTypeOfString str =
    case str of
        "markdown" ->
            MarkdownDoc

        "minilatex" ->
            MiniLaTeXDoc

        _ ->
            MarkdownDoc


stringFromDocType : DocType -> String
stringFromDocType docType =
    case docType of
        MarkdownDoc ->
            "markdown"

        MiniLaTeXDoc ->
            "minilatex"

        IndexDoc ->
            "TODO" -- TODO implement


type alias Uuid =
    String
