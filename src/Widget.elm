module Widget exposing
    ( columnButton
    , columnButtonStyle
    , headingStyle
    , lightColumnButton
    , lightRowButton
    , rowButton
    , textField
    )

import EditorStyle
import Html exposing (button, div, input, text)
import Html.Attributes exposing (placeholder, style, type_)
import Html.Events exposing (onClick, onInput)


columnButtonStyle =
    [ style "margin-top" "10px"
    , style "font-size" "12px"
    , style "border" "none"
    , style "margin-right" "8px"
    ]


headingStyle =
    [ style "font-size" "14px"
    , style "margin-right" "12px"
    , style "float" "left"
    ]


rowButtonStyle =
    [ style "font-size" "12px"
    , style "border" "none"
    , style "margin-right" "8px"
    , style "float" "left"
    ]


buttonLabelStyle width =
    [ style "font-size" "12px"
    , style "background-color" EditorStyle.darkGray
    , style "color" "#eee"
    , style "width" (String.fromInt width ++ "px")
    , style "height" "24px"
    , style "border" "none"
    , style "text-align" "left"
    ]


lightButtonLabelStyle width =
    [ style "font-size" "12px"
    , style "color" "#444"
    , style "width" (String.fromInt width ++ "px")
    , style "height" "24px"
    , style "border" "none"
    , style "text-align" "left"
    ]


rowButtonLabelStyle width =
    [ style "font-size" "12px"
    , style "background-color" EditorStyle.darkGray
    , style "color" "#eee"
    , style "width" (String.fromInt width ++ "px")
    , style "height" "24px"
    , style "border" "none"
    ]


columnButton width msg str attr =
    div (columnButtonStyle ++ attr)
        [ button (onClick msg :: buttonLabelStyle width) [ text str ] ]


lightColumnButton width msg str attr =
    div (columnButtonStyle ++ attr)
        [ button ( onClick msg :: lightButtonLabelStyle width) [ text str ] ]


lightRowButton width msg str attr =
    div (rowButtonStyle ++ attr)
        [ button ( onClick msg :: lightButtonLabelStyle width) [ text str ] ]


rowButton width msg str attr =
    div (rowButtonStyle ++ attr)
        [ button (onClick msg :: rowButtonLabelStyle width) [ text str ] ]


textField width msg str attr innerAttr =
    div (style "margin-bottom" "10px" :: attr)
        [ input
            ([ -- style "height" "18px"
               style "width" (String.fromInt width ++ "px")
             , type_ "text"
             , placeholder str
             , style "margin-right" "8px"
             , onInput msg
             ]
                ++ innerAttr
            )
            []
        ]
