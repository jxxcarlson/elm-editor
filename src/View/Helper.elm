module View.Helper exposing (showIf)

import EditorMsg exposing (EMsg(..))
import Html exposing (Html)


showIf : Bool -> Html EMsg -> Html EMsg
showIf flag el =
    if flag then
        el
    else
        Html.div [] []
