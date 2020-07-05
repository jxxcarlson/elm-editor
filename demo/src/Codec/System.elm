module Codec.System exposing (Preferences, messageDecoder, preferencesDecoder)

import Json.Decode as D exposing (Decoder, string)
import Json.Decode.Pipeline as JP exposing (required)


type alias Preferences =
    { userName : String
    , documentDirectory : String
    , downloadDirectory : String
    }


preferencesDecoder : Decoder Preferences
preferencesDecoder =
    D.succeed Preferences
        |> required "userName" string
        |> required "documentDirectory" string
        |> required "downloadDirectory" string


messageDecoder : Decoder String
messageDecoder =
    D.string
