module Document exposing
    ( Document
    , Manifest
    , Uuid
    , docTypeOfString
    , stringFromDocType
    )

import Time
import Types exposing (DocType(..))


type alias Document =
    { title : String
    , subtitle : String
    , id : Uuid
    , isPublic : Bool
    , tags : List String
    , categories : List String
    , authorName : String
    , authorId : Uuid
    , isPartOf : Maybe Uuid
    , level : Int
    , docType : DocType
    , content : String
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


type alias Uuid =
    String
