module Style exposing (editor, editorColumn, mainRow, renderedText)

import Html.Attributes as HA


mainRow =
    [ HA.style "margin" "50px"
    , HA.style "display" "flex"
    , HA.style "flex-direction" "row"
    ]


editorColumn =
    [ HA.style "margin" "50px"
    , HA.style "display" "flex"
    , HA.style "flex-direction" "column"
    ]


renderedText =
    [ HA.style "border" "solid"
    , HA.style "border-width" "0.5px"
    , HA.style "border-color" "#444"
    , HA.style "width" "400px"
    , HA.style "height" "644px"
    , HA.style "overflow-y" "scroll"
    , HA.style "padding" "12px"
    ]


editor =
    [ HA.style "border" "solid"
    , HA.style "border-width" "0.5px"
    , HA.style "border-color" "#444"
    , HA.style "width" "800px"
    ]
