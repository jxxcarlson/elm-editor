module Style exposing (editor, main)

import Html.Attributes as HA


main =
    [ HA.style "margin" "50px"
    , HA.style "display" "flex"
    , HA.style "flex-direction" "column"
    ]


editor =
    [ HA.style "border" "solid"
    , HA.style "border-width" "0.5px"
    , HA.style "border-color" "#444"
    , HA.style "width" "800px"
    ]
