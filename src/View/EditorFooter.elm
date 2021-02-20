module View.EditorFooter exposing (view)

import EditorModel exposing (AutoLineBreak(..), EditMode(..), EditorModel, ViewMode(..), VimMode(..))
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Vim.Update as Vim


view : EditorModel -> Html msg
view model =
    let
        prefix =
            "State: "

        message : String
        message =
            Vim.toString model.vimModel.state
                |> (\x -> prefix ++ x)
                |> (\y -> String.padRight (45 - String.length y) ' ' y)
    in
    H.div
        [ HA.style "height" "30px"
        , HA.style "font-size" "14px"
        , HA.style "padding-left" "12px"
        , HA.style "line-height" "30px"
        , footerBackgroundColor model.viewMode
        , footerFontColor model.viewMode
        ]
        [ editModeDisplay model, vimStateDisplay model, vimBufferDisplay model ]


vimStateDisplay : EditorModel -> Html msg
vimStateDisplay model =
    if model.editMode == StandardEditor then
        H.span [] []

    else
        H.span [ HA.style "font-size" "14px", HA.style "width" "30px", HA.style "margin-right" "16px", HA.style "color" "#eee" ]
            [ H.text <| Vim.toString model.vimModel.state ]


vimBufferDisplay : EditorModel -> Html msg
vimBufferDisplay model =
    if model.editMode == StandardEditor || String.length model.vimModel.buffer == 0 then
        H.span [] []

    else
        H.span [ HA.style "font-size" "14px", HA.style "width" "400px", HA.style "margin-right" "16px", HA.style "color" "#eee" ] [ H.text <| "Buffer: " ++ model.vimModel.buffer ]


editModeDisplay : EditorModel -> Html msg
editModeDisplay model =
    let
        message =
            case model.editMode of
                StandardEditor ->
                    "Standard"

                VimEditor VimNormal ->
                    "Vim"

                VimEditor VimInsert ->
                    "Vim: Insert"
    in
    H.span [ HA.style "font-style" "bold", HA.style "font-size" "14px", HA.style "width" "20px", HA.style "margin-left" "4px", HA.style "margin-right" "16px", HA.style "color" "#ee4444" ] [ H.text message ]


footerBackgroundColor : ViewMode -> Attribute msg
footerBackgroundColor viewMode_ =
    case viewMode_ of
        Light ->
            HA.style "background-color" "#557"

        Dark ->
            HA.style "background-color" "#557"


footerFontColor : ViewMode -> Attribute msg
footerFontColor viewMode_ =
    case viewMode_ of
        Light ->
            HA.style "color" "#f0f0f0"

        Dark ->
            HA.style "color" "#f0f0f0"
