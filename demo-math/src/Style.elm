module Style exposing (..)

-- import Html exposing (..)

import Html
import Html.Attributes exposing (style)



-- import Html.Events exposing (onClick, onInput)
-- import Html.Keyed as Keyed


colorBlue =
    "rgb(100,100,200)"


colorLight =
    "#88a"


colorDark =
    "#444"


buttonStyle : String -> Int -> List (Html.Attribute msg)
buttonStyle color width =
    let
        realWidth =
            width + 0 |> String.fromInt |> (\x -> x ++ "px")
    in
    [ style "backgroundColor" color
    , style "color" "white"
    , style "width" realWidth
    , style "height" "25px"
    , style "margin-top" "20px"
    , style "margin-right" "12px"
    , style "font-size" "9pt"
    , style "text-align" "center"
    , style "border" "none"
    ]



-- STYLE FUNCTIONS


outerStyle =
    [ style "margin-top" "20px"
    , style "background-color" "#e1e6e8"
    , style "padding" "20px"
    , style "width" "1430px"
    , style "height" "710px"
    ]


editorTextStyle =
    textStyle "400px" "450px" "#fff"


macroPanelStyle =
    textStyle "300px" "450px" "#fff"


renderedSourceStyle =
    textStyle "400px" "610px" "#fff"


textStyle width height color =
    [ style "width" width
    , style "height" height
    , style "padding" "15px"
    , style "margin-left" "20px"
    , style "background-color" color
    , style "overflow" "scroll"
    , style "float" "left"
    , style "margin-right" "20px"
    ]


labelStyle =
    [ style "margin-top" "5px"
    , style "margin-bottom" "0px"
    , style "margin-left" "20px"
    , style "font-weight" "bold"
    ]
