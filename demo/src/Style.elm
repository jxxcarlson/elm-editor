module Style exposing
    ( grayColor
    , redColor
    )

import Element


redColor =
    Element.rgb255 150 40 40


grayColor =
    Element.rgb255 90 90 100


px : Float -> String
px p =
    String.fromFloat p ++ "px"
