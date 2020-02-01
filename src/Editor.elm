module Editor exposing (Editor(..), EditorMsg, init, view)

import Html as H exposing (Html)
import Html.Attributes as HA
import Model exposing (Config, Model)
import Update exposing (Msg(..))
import View exposing (viewDebug, viewEditor, viewHeader)


type Editor
    = Editor Model


view : Editor -> Html Msg
view (Editor model) =
    H.div []
        [ viewHeader model
        , viewEditor model
        , viewDebug model
        ]


init : Config -> Editor
init config =
    config |> Model.init |> Editor


type alias EditorMsg =
    Msg
