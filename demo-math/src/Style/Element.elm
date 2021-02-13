module Style.Element exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font


gray g =
    rgb g g g


noFocus : Element.FocusStyle
noFocus =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }


blue =
    Element.rgb 0.15 0.15 1.0


white =
    Element.rgb 1 1 1


black =
    Element.rgb 0.1 0.1 0.1


headerButtonStyle : List (Element.Attr () msg)
headerButtonStyle =
    [ Background.color white, Font.color black, Element.paddingXY 10 6 ] ++ basicButtonsStyle


simpleButtonStyle : List (Element.Attr () msg)
simpleButtonStyle =
    [ Background.color (gray 0.2), Font.color (gray 0.8), Element.paddingXY 10 6 ] ++ basicButtonsStyle


basicButtonsStyle =
    [ buttonFontSize
    , pointer
    , mouseDown [ buttonFontSize, Background.color mouseDownColor ]
    ]


mouseDownColor =
    Element.rgb 0.7 0.1 0.1


buttonFontSize =
    Font.size 16
