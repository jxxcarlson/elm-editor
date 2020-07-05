module View.Style exposing
    ( blackColor
    , blueColor
    , brightRedColor
    , grayColor
    , lightBlueColor
    , lightGrayColor
    , paleBlueColor
    , redColor
    , whiteColor
    )

import Element


redColor =
    Element.rgb255 120 30 30


blueColor =
    Element.rgb255 30 30 120


lightBlueColor =
    Element.rgba 0.1 0.1 1.0 0.7


paleBlueColor =
    Element.rgba 0.8 0.8 1.0 0.8


brightRedColor =
    Element.rgb255 255 100 30


whiteColor =
    Element.rgb255 200 200 200


blackColor =
    Element.rgb255 30 30 30


grayColor =
    Element.rgb255 90 90 100


lightGrayColor =
    Element.rgb 0.5 0.5 0.5


px : Float -> String
px p =
    String.fromFloat p ++ "px"
