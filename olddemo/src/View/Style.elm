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


redColor : Element.Color
redColor =
    Element.rgb255 120 30 30


blueColor : Element.Color
blueColor =
    Element.rgb255 30 30 120


lightBlueColor : Element.Color
lightBlueColor =
    Element.rgba 0.1 0.1 1.0 0.7


paleBlueColor : Element.Color
paleBlueColor =
    Element.rgba 0.8 0.8 1.0 0.8


brightRedColor : Element.Color
brightRedColor =
    Element.rgb255 255 100 30


whiteColor : Element.Color
whiteColor =
    Element.rgb255 200 200 200


blackColor : Element.Color
blackColor =
    Element.rgb255 30 30 30


grayColor : Element.Color
grayColor =
    Element.rgb255 90 90 100


lightGrayColor : Element.Color
lightGrayColor =
    Element.rgb 0.5 0.5 0.5
