module Update.Helper exposing
    ( postMessage
    , updateMessageLife
    )

import Config
import Types exposing (Model)


postMessage : String -> Model -> Model
postMessage msg model =
    { model | message = msg, messageLife = Config.messageLifeTime }


updateMessageLife : Model -> Model
updateMessageLife model =
    case model.messageLife > 0 of
        True ->
            { model | messageLife = model.messageLife - 1 }

        False ->
            model
