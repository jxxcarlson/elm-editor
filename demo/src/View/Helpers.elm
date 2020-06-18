module View.Helpers exposing
    ( gray
    , pxFloat
    , showIf
    )

import Element exposing (Element, px, rgb255)
import Types exposing (Msg)


showIf : Bool -> Element Msg -> Element Msg
showIf flag el =
    case flag of
        True ->
            el

        False ->
            Element.none


pxFloat : Float -> Element.Length
pxFloat p =
    px (round p)


gray g =
    rgb255 g g g
