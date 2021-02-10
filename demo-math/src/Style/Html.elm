module Style.Html exposing (..)

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


renderedSourceStyle width height =
    [ style "width" ((String.fromFloat width) ++ "px")
    , style "height" ((String.fromFloat height) ++ "px")
    , style "padding" "15px"
    , style "background-color" "#fff"
    , style "overflow" "scroll"
    , style "float" "left"
    , style "margin-right" "20px"
    , style "white-space" "normal"
    , style "font-size" "14px"
    , style "line-height" "1.3"
    ]



labelStyle =
    [ style "margin-top" "5px"
    , style "margin-bottom" "0px"
    , style "margin-left" "20px"
    , style "font-weight" "bold"
    ]
