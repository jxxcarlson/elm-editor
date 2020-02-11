module Style exposing (editor, footer, innerContainer, outerContainer, renderedText)

import Html.Attributes as HA


outerContainer width height =
    [ HA.style "padding-top" "0px"
    , HA.style "width" (px width)
    , HA.style "height" (px height)
    , HA.style "display" "flex"
    , HA.style "flex-direction" "column"
    , HA.style "justify-content" "center"
    , HA.style "overflow" "hidden"
    ]


innerContainer width height =
    [ HA.style "width" (px width)
    , HA.style "height" (px height)
    , HA.style "display" "flex"
    , HA.style "flex-direction" "row"
    , HA.style "justify-content" "center"
    , HA.style "overflow" "hidden"
    ]


footer width height =
    [ HA.style "width" (px width)
    , HA.style "height" (px height)
    , HA.style "display" "flex"
    , HA.style "flex-direction" "row"
    , HA.style "overflow" "hidden"
    , HA.style "background-color" "#666"
    ]


renderedText width height =
    [ HA.style "border" "solid"
    , HA.style "border-width" "0.5px"
    , HA.style "border-color" "#444"
    , HA.style "width" (px (width - 40))
    , HA.style "height" (px (height + 52))
    , HA.style "overflow-y" "scroll"
    , HA.style "padding-left" "18px"
    , HA.style "padding-right" "18px"
    ]


editor width =
    [ HA.style "border" "solid"
    , HA.style "border-width" "0.5px"
    , HA.style "border-color" "#444"
    ]


px : Float -> String
px p =
    String.fromFloat p ++ "px"
