module View.Helper exposing (showIf)

import EditorMsg exposing (EMsg(..))
import Html exposing (Html)


showIf : Bool -> Html EMsg -> Html EMsg
showIf flag el =
    case flag of
        True ->
            el

        False ->
            Html.div [] []
