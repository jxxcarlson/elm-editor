module Update.System exposing
    ( handleMessage
    , windowSize
    )

import Cmd.Extra exposing (withCmd, withCmds, withNoCmd)
import Editor
import Helper.Common
import Types exposing (Model)
import Update.Helper


handleMessage : Result error String -> Model -> ( Model, Cmd msg )
handleMessage result model =
    case result of
        Ok str ->
            model
                |> Update.Helper.postMessage str
                |> withNoCmd

        Err _ ->
            model
                |> Update.Helper.postMessage "Unknown error"
                |> withNoCmd


windowSize : Int -> Int -> Model -> ( Model, Cmd msg )
windowSize width height model =
    let
        w =
            toFloat width

        h =
            toFloat height
    in
    ( { model
        | width = w
        , height = h
        , editor = Editor.resize (Helper.Common.windowWidth w) (Helper.Common.windowHeight h) model.editor
      }
    , Cmd.none
    )
