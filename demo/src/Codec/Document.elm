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
        |> required "content" string


documentEncoder : Document -> Encode.Value
documentEncoder doc =
    Encode.object
        [ ( "fileName", Encode.string doc.fileName )
        , ( "id", Encode.string doc.id )
        , ( "author", Encode.string doc.author )
        , ( "timeCreated", Encode.int (Time.posixToMillis doc.timeCreated) )
        , ( "timeUpdated", Encode.int (Time.posixToMillis doc.timeUpdated) )
        , ( "content", Encode.string doc.content )
        ]



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


metadataEncoder : Metadata -> Encode.Value
metadataEncoder metadata =
    Encode.object
        [ ( "fileName", Encode.string metadata.fileName )
        , ( "id", Encode.string metadata.id )
        , ( "author", Encode.string metadata.author )
        , ( "timeCreated", Encode.int (Time.posixToMillis metadata.timeCreated) )
        , ( "timeUpdated", Encode.int (Time.posixToMillis metadata.timeUpdated) )
        ]



--  MESSAGE


type alias MessageContainer =
    { msg : String }


messageDecoder : Decoder String
messageDecoder =
    (D.succeed MessageContainer
        |> required "msg" string
    )
        |> D.map .msg
