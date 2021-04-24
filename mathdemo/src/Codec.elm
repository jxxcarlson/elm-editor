module Codec exposing (encodeForPDF)

import Json.Encode as E



{- ENCODERS -}


encodeForPDF : String -> String -> List String -> E.Value
encodeForPDF id content urlList =
    E.object
        [ ( "id", E.string id )
        , ( "content", E.string content )
        , ( "urlList", E.list E.string urlList )
        ]


encodeForPDF1 : String -> String -> List String -> E.Value
encodeForPDF1 id content urlList =
    E.object
        [ ( "id", E.string id )
        , ( "content", E.string content )
        , ( "urlList", E.list E.string urlList )
        ]
