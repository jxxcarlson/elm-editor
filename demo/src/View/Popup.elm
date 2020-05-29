module View.Popup exposing (view)

import Element
    exposing
        ( Element
        , alignBottom
        , alignRight
        , alignTop
        , centerX
        , centerY
        , column
        , el
        , height
        , paddingXY
        , px
        , rgb255
        , row
        , scrollbarY
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Helper.Common
import Outside
import Types exposing (Model, Msg(..), PopupStatus(..))
import View.Widget as Widget


view : Model -> Element Msg
view model =
    case model.popupStatus of
        PopupClosed ->
            Element.none

        PopupOpen ->
            column
                [ width (px 500)
                , height (px <| round <| Helper.Common.windowHeight model.height + 28)
                , paddingXY 30 30
                , Background.color (Element.rgba 1.0 0.75 0.75 0.8)
                , spacing 16
                ]
                [ row [ width (px 450) ] [ text "Files", el [ alignRight ] (Widget.closePopupButton model) ]
                , column
                    [ spacing 8
                    , height (px 400)
                    , scrollbarY
                    ]
                    (List.map viewFileName (List.sort model.fileList))
                ]


viewFileName : String -> Element Msg
viewFileName fileName =
    row []
        [ Widget.plainButton 200 fileName (SendRequestForFile fileName) []
        , Widget.plainButton 55
            "delete"
            (DeleteFileFromLocalStorage fileName)
            [ Background.color (Element.rgba 0.7 0.7 1.0 0.9) ]
        ]
