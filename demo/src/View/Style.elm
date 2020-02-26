module View.Style exposing
    ( grayColor
    , redColor
    )

import Element


redColor =
    Element.rgb255 120 30 30


grayColor =
    Element.rgb255 90 90 100


px : Float -> String
px p =
    String.fromFloat p ++ "px"
