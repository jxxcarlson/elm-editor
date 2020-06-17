module Codec.System exposing (Preferences, preferencesDecoder)

import Json.Decode as D exposing (Decoder, string)
import Json.Decode.Pipeline as JP exposing (required)


type alias Preferences =
    { userName : String
    , documentDirectory : String
    }


preferencesDecoder : Decoder Preferences
preferencesDecoder =
    D.succeed Preferences
        |> required "userName" string
        |> required "documentDirectory" string
