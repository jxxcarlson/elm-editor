module Editor exposing
    ( Editor(..), init, loadArray
    , EditorMsg, getLines, getContextMenu, update, view
    , loadString, syncMessages
    )

{-| Use the Editor module to embed a pure Elm text editor
into another application. See `./demo` in the source
code for an example.


## Setting up the editor

@docs Editor, init, loadArray


## Using the editor

@docs EditorMsg, getLines, getContextMenu, update, view

-}

import Array exposing (Array)
import Cmd.Extra
import ContextMenu exposing (ContextMenu)
import Html as H exposing (Html)
import Menu.View exposing (viewContextMenu)
import Model exposing (Config, Context(..), Model, Msg(..))
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
        , viewContextMenu model
        , viewDebug model
        ]


{-| Initialize the editor with a configuration
-}
init : Config -> ( Editor, Cmd Msg )
init config =
    let
        ( contextMenu, msg ) =
            ContextMenu.init

        cmd : Cmd Msg
        cmd =
            Cmd.map ContextMenuMsg msg
    in
    ( config, contextMenu )
        |> Model.init
        |> Editor
        |> Cmd.Extra.withCmd cmd


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


loadString : String -> Editor -> Editor
loadString str (Editor model) =
    Editor { model | lines = str |> String.lines |> Array.fromList }


{-| Get the current editor content
-}
getLines : Editor -> Array String
getLines (Editor model) =
    model.lines


{-| Get the context menu
-}
getContextMenu : Editor -> ContextMenu Context
getContextMenu (Editor model) =
    model.contextMenu


syncMessages : List Msg
syncMessages =
    [ RemoveCharBefore
    , RemoveCharAfter
    , KillLine
    , Cut
    , Copy
    , NewLine
    , Paste
    , WrapAll
    , WrapSelection
    ]
