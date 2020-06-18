module Codec.Document exposing
    ( decodeMetadata
    , documentDecoder
    , documentEncoder
    , extendedDocumentEncoder
    , messageDecoder
    , metadataEncoder
    , metadataListDecoder
    )

import Document exposing (Document, Metadata)
import Json.Decode as D exposing (Decoder, bool, int, list, nullable, string)
import Json.Decode.Pipeline as JP exposing (required)
import Json.Encode as Encode



-- DOCUMENT


documentDecoder : Decoder Document
documentDecoder =
    D.succeed Document
        |> required "fileName" string
        |> required "id" string
        |> required "content" string


documentEncoder : Document -> Encode.Value
documentEncoder doc =
    Encode.object
        [ ( "fileName", Encode.string doc.fileName )
        , ( "id", Encode.string doc.id )
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
    D.list decodeMetadata


decodeMetadata : Decoder Metadata
decodeMetadata =
    D.succeed Metadata
        |> required "id" string
        |> required "fileName" string


metadataEncoder : Metadata -> Encode.Value
metadataEncoder record =
    Encode.object
        [ ( "fileName", Encode.string record.fileName )
        , ( "id", Encode.string record.id )
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
