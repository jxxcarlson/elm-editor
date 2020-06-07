module View.Style exposing
    ( blackColor
    , brightRedColor
    , grayColor
    , redColor
    , whiteColor
    )

import Element


redColor =
    Element.rgb255 120 30 30


brightRedColor =
    Element.rgb255 255 100 30


whiteColor =
    Element.rgb255 200 200 200


blackColor =
    Element.rgb255 30 30 30


grayColor =
    Element.rgb255 90 90 100


px : Float -> String
px p =
    String.fromFloat p ++ "px"
