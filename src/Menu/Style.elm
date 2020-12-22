module Menu.Style exposing
    ( Style
    , annotation
    , backgroundStyles
    , borderColor
    , container
    , icon
    , objectStyles
    , partition
    , px
    , row
    , shortcut
    , text
    )

import Html exposing (Attribute)
import Html.Attributes exposing (style)


type alias Color =
    String


type alias Style msg =
    List (Attribute msg)


borderColor : String
borderColor =
    "#ccc"


container : Color -> Float -> Float -> Bool -> Float -> Float -> Float -> String -> Float -> Style msg
container containerColor borderWidth padding rounded width left top fontFamily fontSize =
    [ style "border-style" "solid"
    , style "border-width" (px borderWidth)
    , style "border-color" borderColor
    , style "position" "fixed"
    , style "top" (px top)
    , style "left" (px left)
    , style "width" (px width)
    , style "z-index" (String.fromFloat (2147483647 - 10))
    , style "background-color" containerColor
    , style "cursor" "default"
    , style "box-shadow" "0px 3px 8px 0px rgba(0,0,0,0.3)"
    , style "padding" (px padding ++ " 0")
    , style "border-radius"
        (if rounded then
            px padding

         else
            ""
        )
    , style "font-family" fontFamily
    , style "font-size" (px fontSize)
    ]


row : Color -> Color -> Bool -> Bool -> Float -> Bool -> Bool -> Bool -> Style msg
row hoverColor disabledTextColor invertText usePointer lineHeight hovered disabled hasShortCut =
    [ style "position" "relative"
    , style "padding" "0 18px 0 28px"
    , style "background-color"
        (if hovered then
            hoverColor

         else
            ""
        )
    , style "height" (px lineHeight)
    , style "color"
        (if disabled then
            disabledTextColor

         else if hovered && invertText then
            "#fff"

         else
            ""
        )
    , style "cursor"
        (if not disabled && usePointer then
            "pointer"

         else
            ""
        )
    , style "display" "flex"
    , style "justify-content"
        (if hasShortCut then
            "space-between"

         else
            ""
        )
    ]


text : Float -> Style msg
text lineHeight =
    [ style "line-height" (px lineHeight)
    , style "text-overflow" "ellipsis"
    , style "overflow" "hidden"
    , style "white-space" "nowrap"
    ]


annotation : Color -> Float -> Float -> Style msg
annotation color annotationHeight fontSize =
    [ style "margin-top" "-2px"
    , style "line-height" (px annotationHeight)
    , style "font-size" (px fontSize)
    , style "color" color
    ]


shortcut : Color -> Float -> Bool -> Style msg
shortcut color lineHeight hovered =
    [ style "line-height" (px lineHeight)
    , style "color"
        (if hovered then
            ""

         else
            color
        )
    ]


partition : Float -> Style msg
partition margin =
    [ style "border-bottom-style" "solid"
    , style "border-bottom-width" (px 1)
    , style "border-bottom-color" borderColor
    , style "border-top" "none"
    , style "margin" (px margin ++ " 0")
    ]


icon : Float -> Style msg
icon size =
    [ style "position" "absolute"
    , style "margin-left" (px (-size - 4))
    , style "top" "2px"
    ]



----


px : Float -> String
px n =
    String.fromFloat n ++ "px"



-- XXX


backgroundStyles : List (Attribute msg)
backgroundStyles =
    [ style "top" "0"
    , style "left" "0"
    , style "width" "40px"
    , style "height" "15px"
    , style "position" "relative"
    , style "background-color" "#77b"
    ]


objectStyles : Float -> List (Attribute msg)
objectStyles width =
    [ style "position" "relative"
    , style "top" "0"
    , style "left" "40px"
    , style "width" (px <| width - 40)
    , style "height" "15px"
    , style "background-color" "#8aa"
    ]
