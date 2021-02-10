module View.Helper exposing (showIf, showIfE)

import EditorMsg exposing (EMsg(..))
import Element exposing (Element)
import Html exposing (Html)


showIf : Bool -> Html EMsg -> Html EMsg
showIf flag el =
    if flag then
        el

    else
        Html.div [] []


showIfE : Bool -> Element EMsg -> Element EMsg
showIfE flag el =
    if flag then
        el

    else
        Element.none
