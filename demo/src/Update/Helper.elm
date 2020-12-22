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
    if model.messageLife > 0 then
        { model | messageLife = model.messageLife - 1 }
    else
        model
