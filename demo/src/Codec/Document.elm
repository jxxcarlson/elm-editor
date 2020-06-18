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



-- DOCUMENT


documentDecoder : Decoder Document
documentDecoder =
    D.succeed Document
        |> required "fileName" string
        |> required "id" string
        |> required "author" string
        |> required "content" string


documentEncoder : Document -> Encode.Value
documentEncoder doc =
    Encode.object
        [ ( "fileName", Encode.string doc.fileName )
        , ( "id", Encode.string doc.id )
        , ( "author", Encode.string doc.author )
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


metadataEncoder : Metadata -> Encode.Value
metadataEncoder metadata =
    Encode.object
        [ ( "fileName", Encode.string metadata.fileName )
        , ( "id", Encode.string metadata.id )
        , ( "author", Encode.string metadata.author )
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
