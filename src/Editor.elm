module Editor exposing
    ( Editor(..)
    , EditorMsg
    , getLines
    , init
    , loadArray
    , update
    , view
    )

import Array exposing (Array)
import Html as H exposing (Html)
import Html.Attributes as HA
import Model exposing (Config, Model, Msg(..))
import Update as U
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


update : Msg -> Editor -> ( Editor, Cmd Msg )
update msg (Editor model) =
    let
        ( newModel, cmd ) =
            U.update msg model
    in
    ( Editor newModel, cmd )


type alias EditorMsg =
    Msg


loadArray : Array String -> Editor -> Editor
loadArray array (Editor model) =
    Editor { model | lines = array }


getLines : Editor -> Array String
getLines (Editor model) =
    model.lines
