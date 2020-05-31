module Codec exposing
    ( basicDocumentDecoder
    , basicDocumentEncoder
    )

import Json.Decode as D exposing (Decoder, bool, int, list, nullable, string)
import Json.Decode.Pipeline as JP exposing (required)
import Json.Encode as Encode
import Types exposing (BasicDocument)


basicDocumentDecoder : Decoder BasicDocument
basicDocumentDecoder =
    D.succeed BasicDocument
        |> required "fileName" string
        |> required "id" string
        |> required "content" string


basicDocumentEncoder : BasicDocument -> Encode.Value
basicDocumentEncoder doc =
    Encode.object
        [ ( "fileName", Encode.string doc.fileName )
        , ( "id", Encode.string doc.id )
        , ( "content", Encode.string doc.content )
        ]
