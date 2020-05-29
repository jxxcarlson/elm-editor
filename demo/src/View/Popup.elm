module View.Popup exposing (view)

import Element
    exposing
        ( Element
        , alignBottom
        , alignRight
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
                [ width (px 400)
                , height (px <| round <| Helper.Common.windowHeight model.height + 28)
                , paddingXY 30 30
                , Background.color (Element.rgba 1.0 0.75 0.75 0.8)
                , spacing 16
                ]
                [ text "Files"
                , column
                    [ spacing 8
                    , height (px 400)
                    , scrollbarY
                    ]
                    (List.map viewFileName model.fileList)

                -- , el [ alignBottom ] (Widget.closePopupButton model)
                ]


viewFileName : String -> Element Msg
viewFileName fileName =
    Widget.plainButton 120 fileName (SendRequestForFile fileName) []
