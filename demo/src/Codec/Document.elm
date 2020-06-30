module Codec.Document exposing
    ( documentDecoder
    , documentEncoder
    , extendedDocumentEncoder
    , messageDecoder
    , metadataDecoder
    , metadataEncoder
    , metadataListDecoder
    )

import Document exposing (Document, Metadata)
import Json.Decode as D exposing (Decoder, bool, int, list, nullable, string)
import Json.Decode.Pipeline as JP exposing (required)
import Json.Encode as Encode
import Time



-- DOCUMENT


documentDecoder : Decoder Document
documentDecoder =
    D.succeed Document
        |> required "fileName" string
        |> required "id" string
        |> required "author" string
        |> required "timeCreated" (int |> D.map Time.millisToPosix)
        |> required "timeUpdated" (int |> D.map Time.millisToPosix)
        |> required "timeSynced" (nullable int |> D.map (Maybe.map Time.millisToPosix))
        |> required "tags" (list string)
        |> required "categories" (list string)
        |> required "title" string
        |> required "subtitle" string
        |> required "abstract" string
        |> required "belongsTo" string
        |> required "docType" (string |> D.map Document.docType)
        |> required "content" string


documentEncoder : Document -> Encode.Value
documentEncoder doc =
    Encode.object
        [ ( "fileName", Encode.string doc.fileName )
        , ( "id", Encode.string doc.id )
        , ( "author", Encode.string doc.author )
        , ( "timeCreated", Encode.int (Time.posixToMillis doc.timeCreated) )
        , ( "timeUpdated", Encode.int (Time.posixToMillis doc.timeUpdated) )
        , ( "timeSynced", encodeMaybeInt (Maybe.map Time.posixToMillis doc.timeSynced) )
        , ( "tags", Encode.list Encode.string doc.tags )
        , ( "categories", Encode.list Encode.string doc.categories )
        , ( "title", Encode.string (normalize doc.title) )
        , ( "subtitle", Encode.string (normalize doc.subtitle) )
        , ( "abstract", Encode.string (normalize doc.abstract) )
        , ( "belongsTo", Encode.string (normalize doc.belongsTo) )
        , ( "docType", Encode.string (Document.stringOfDocType doc.docType) )
        , ( "content", Encode.string doc.content )
        ]


encodeMaybeInt : Maybe Int -> Encode.Value
encodeMaybeInt maybeInt =
    case maybeInt of
        Nothing ->
            Encode.null

        Just k ->
            Encode.int k



-- EXTENDED DOCUMENT


extendedDocumentEncoder : String -> Document -> Encode.Value
extendedDocumentEncoder token doc =
    Encode.object
        [ ( "fileName", Encode.string doc.fileName )
        , ( "id", Encode.string doc.id )
        , ( "content", Encode.string doc.content )
        , ( "token", Encode.string token )
        ]



-- METADATA


metadataListDecoder : D.Decoder (List Metadata)
metadataListDecoder =
    D.list metadataDecoder


metadataDecoder : Decoder Metadata
metadataDecoder =
    D.succeed Metadata
        |> required "fileName" string
        |> required "id" string
        |> required "author" string
        |> required "timeCreated" (int |> D.map Time.millisToPosix)
        |> required "timeUpdated" (int |> D.map Time.millisToPosix)
        |> required "timeSynced" (nullable int |> D.map (Maybe.map Time.millisToPosix))
        |> required "tags" (list string)
        |> required "categories" (list string)
        |> required "title" string
        |> required "subtitle" string
        |> required "abstract" string
        |> required "belongsTo" string
        |> required "docType" (string |> D.map Document.docType)


metadataEncoder : Metadata -> Encode.Value
metadataEncoder metadata =
    Encode.object
        [ ( "fileName", Encode.string metadata.fileName )
        , ( "id", Encode.string metadata.id )
        , ( "author", Encode.string metadata.author )
        , ( "timeCreated", Encode.int (Time.posixToMillis metadata.timeCreated) )
        , ( "timeUpdated", Encode.int (Time.posixToMillis metadata.timeUpdated) )
        , ( "timeSynced", encodeMaybeInt (Maybe.map Time.posixToMillis metadata.timeSynced) )
        , ( "tags", Encode.list Encode.string metadata.tags )
        , ( "categories", Encode.list Encode.string metadata.categories )
        , ( "title", Encode.string (normalize metadata.title) )
        , ( "subtitle", Encode.string (normalize metadata.subtitle) )
        , ( "abstract", Encode.string (normalize metadata.abstract) )
        , ( "belongsTo", Encode.string (normalize metadata.belongsTo) )
        , ( "docType", Encode.string (Document.stringOfDocType metadata.docType) )
        ]


normalize : String -> String
normalize str =
    case str == "" of
        True ->
            "none"

        False ->
            str



--  MESSAGE


type alias MessageContainer =
    { msg : String }


messageDecoder : Decoder String
messageDecoder =
    (D.succeed MessageContainer
        |> required "msg" string
    )
        |> D.map .msg
