module View.Footer exposing (view)

import EditorModel exposing (AutoLineBreak(..), EditorModel, ViewMode(..))
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA


view : EditorModel -> Html msg
view model =
    let
        _ = model.viewMode
    in
    H.div [  HA.style "height" "24px"
            , HA.style "font-size" "14px"
            , HA.style "padding-left" "12px"
            , HA.style "padding-top" "6px"
            , footerBackgroundColor model.viewMode
            , footerFontColor model.viewMode
            ]
            [H.text "testing ..."]

footerBackgroundColor : ViewMode -> Attribute msg
footerBackgroundColor viewMode_ =
 case viewMode_ of
     Light ->
         HA.style "background-color" "#f0f0f0"

     Dark ->
         HA.style "background-color" "#557"



footerFontColor : ViewMode -> Attribute msg
footerFontColor viewMode_ =
 case viewMode_ of
     Light ->
         HA.style "color" "#444"

     Dark ->
         HA.style "color" "#f0f0f0"
