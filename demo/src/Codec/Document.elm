module Codec.Document exposing
    ( decodeMiniFileRecord
    , documentDecoder
    , documentEncoder
    , documentListDecoder
    , encodeMiniFileRecord
    , extendedDocumentEncoder
    , messageDecoder
    )

import Document exposing (Document, Metadata)
import Json.Decode as D exposing (Decoder, bool, int, list, nullable, string)
import Json.Decode.Pipeline as JP exposing (required)
import Json.Encode as Encode



-- DECODERS


documentListDecoder : D.Decoder (List Metadata)
documentListDecoder =
    D.list decodeMiniFileRecord


documentDecoder : Decoder Document
documentDecoder =
    D.succeed Document
        |> required "fileName" string
        |> required "id" string
        |> required "content" string


decodeMiniFileRecord : Decoder Metadata
decodeMiniFileRecord =
    D.succeed Metadata
        |> required "id" string
        |> required "fileName" string


type alias MessageContainer =
    { msg : String }


messageDecoder : Decoder String
messageDecoder =
    (D.succeed MessageContainer
        |> required "msg" string
    )
        |> D.map .msg



-- ENCODERS


encodeMiniFileRecord : Metadata -> Encode.Value
encodeMiniFileRecord record =
    Encode.object
        [ ( "fileName", Encode.string record.fileName )
        , ( "id", Encode.string record.id )
        ]


documentEncoder : Document -> Encode.Value
documentEncoder doc =
    Encode.object
        [ ( "fileName", Encode.string doc.fileName )
        , ( "id", Encode.string doc.id )
        , ( "content", Encode.string doc.content )
        ]


extendedDocumentEncoder : String -> Document -> Encode.Value
extendedDocumentEncoder token doc =
    Encode.object
        [ ( "fileName", Encode.string doc.fileName )
        , ( "id", Encode.string doc.id )
        , ( "content", Encode.string doc.content )
        , ( "token", Encode.string token )
        ]
