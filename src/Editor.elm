module Editor exposing
    ( Editor(..), init, loadArray
    , EditorMsg, getLines, update, view
    )

{-| Use the Editor module to embed a pure Elm text editor
into another application. See `./demo` in the source
code for an example.


## Setting up the editor

@docs Editor, init, loadArray


## Using the editor

@docs EditorMsg, getLines, update, view

-}

import Array exposing (Array)
import Html as H exposing (Html)
import Html.Attributes as HA
import Model exposing (Config, Model, Msg(..))
import Update as U
import View exposing (viewDebug, viewEditor, viewHeader)


{-| Opaque type for the editor
-}
type Editor
    = Editor Model


{-| View function for the editor
-}
view : Editor -> Html Msg
view (Editor model) =
    H.div []
        [ viewHeader model
        , viewEditor model
        , viewDebug model
        ]


{-| Initialize the editor with a configuration
-}
init : Config -> Editor
init config =
    config |> Model.init |> Editor


{-| Update the editor with a message
-}
update : Msg -> Editor -> ( Editor, Cmd Msg )
update msg (Editor model) =
    let
        ( newModel, cmd ) =
            U.update msg model
    in
    ( Editor newModel, cmd )


{-| The messages to which the editor responds
-}
type alias EditorMsg =
    Msg


{-| Load content into the editor
-}
loadArray : Array String -> Editor -> Editor
loadArray array (Editor model) =
    Editor { model | lines = array }


{-| Get the current editor content
-}
getLines : Editor -> Array String
getLines (Editor model) =
    model.lines
