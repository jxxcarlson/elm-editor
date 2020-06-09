module Future.Codec exposing
    ( authorDecoder
    , authorEncoder
    , documentDecoder
    , documentEncoder
    , manifestDecoder
    , manifestEncoder
    )

import Future.Document exposing (Author, Document, Manifest)
import Json.Decode as D exposing (Decoder, bool, int, list, nullable, string)
import Json.Decode.Pipeline as JP exposing (required)
import Json.Encode as Encode
import Time


authorDecoder : Decoder Author
authorDecoder =
    D.succeed Document
        |> required "name" string
        |> required "id" string
        |> required "email" string
        |> required "timeCreated" (int |> D.map Time.millisToPosix)
        |> required "timeUpdated" (int |> D.map Time.millisToPosix)


authorEncoder : Author -> Encode.Value
authorEncoder author =
    Encode.object
        [ ( "name", Encode.string author.name )
        , ( "userName", Encode.string author.userName )
        , ( "id", Encode.string author.id )
        , ( "email", Encode.string author.email )
        , ( "passwordHash", Encode.string author.passwordHash )
        , ( "dateCreated", Encode.int (Time.posixToMillis author.dateCreated) )
        , ( "dateModified", Encode.int (Time.posixToMillis author.dateModified) )
        ]


documentDecoder : Decoder Document
documentDecoder =
    D.succeed Document
        |> required "title" string
        |> required "subtitle" string
        |> required "fileName" string
        |> required "url" string
        |> required "id" string
        |> required "isPublic" bool
        |> required "tags" (list string)
        |> required "categories" (list string)
        |> required "authorName" string
        |> required "authorId" string
        |> required "isPartOf" (nullable string)
        |> required "level" int
        |> required "docType" (string |> D.map Document.docTypeOfString)
        |> required "content" string
        |> required "timeCreated" (int |> D.map Time.millisToPosix)
        |> required "timeUpdated" (int |> D.map Time.millisToPosix)


manifestDecoder : Decoder Manifest
manifestDecoder =
    D.succeed Manifest
        |> required "title" string
        |> required "subtitle" string
        |> required "id" string
        |> required "isPublic" bool
        |> required "tags" (list string)
        |> required "categories" (list string)
        |> required "authorName" string
        |> required "authorId" string
        |> required "description" string
        |> required "items" (list string)
        |> required "timeCreated" (int |> D.map Time.millisToPosix)
        |> required "timeUpdated" (int |> D.map Time.millisToPosix)


documentEncoder : Document -> Encode.Value
documentEncoder doc =
    Encode.object
        [ ( "title", Encode.string doc.title )
        , ( "subtitle", Encode.string doc.subtitle )
        , ( "fileName", Encode.string doc.fileName )
        , ( "url", Encode.string doc.url )
        , ( "id", Encode.string doc.id )
        , ( "isPublic", Encode.bool doc.isPublic )
        , ( "tags", Encode.list Encode.string doc.tags )
        , ( "categories", Encode.list Encode.string doc.categories )
        , ( "authorId", Encode.string doc.authorId )
        , ( "isPartOf", encodeMaybeString doc.isPartOf )
        , ( "level", Encode.int doc.level )
        , ( "docType", Encode.string (Document.stringFromDocType doc.docType) )
        , ( "content", Encode.string doc.content )
        , ( "timeCreated", Encode.int (Time.posixToMillis doc.timeCreated) )
        , ( "timeUpdated", Encode.int (Time.posixToMillis doc.timeUpdated) )
        ]


manifestEncoder : Manifest -> Encode.Value
manifestEncoder doc =
    Encode.object
        [ ( "title", Encode.string doc.title )
        , ( "subtitle", Encode.string doc.subtitle )
        , ( "id", Encode.string doc.id )
        , ( "isPublic", Encode.bool doc.isPublic )
        , ( "tags", Encode.list Encode.string doc.tags )
        , ( "categories", Encode.list Encode.string doc.categories )
        , ( "authorId", Encode.string doc.authorId )
        , ( "description", Encode.string doc.description )
        , ( "items", Encode.list Encode.string doc.items )
        , ( "timeCreated", Encode.int (Time.posixToMillis doc.timeCreated) )
        , ( "timeUpdated", Encode.int (Time.posixToMillis doc.timeUpdated) )
        ]



-- HELPERS


encodeMaybeString : Maybe String -> Encode.Value
encodeMaybeString maybeString =
    case maybeString of
        Nothing ->
            Encode.null

        Just str ->
            Encode.string str
