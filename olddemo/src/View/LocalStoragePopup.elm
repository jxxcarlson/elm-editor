module View.LocalStoragePopup exposing (view)

import Document exposing (Metadata)
import Element
    exposing
        ( Element
        , alignRight
        , column
        , el
        , height
        , paddingXY
        , px
        , row
        , scrollbarY
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Helper.Common
import Types exposing (Model, Msg(..), PopupStatus(..), PopupWindow(..))
import View.Widget as Widget


view : Model -> Element Msg
view model =
    case model.popupStatus of
        PopupClosed ->
            Element.none

        PopupOpen LocalStoragePopup ->
            column
                [ width (px 500)
                , height (px <| round <| Helper.Common.windowHeight model.height + 28)
                , paddingXY 30 30
                , Background.color (Element.rgba 1.0 0.75 0.75 0.8)
                , spacing 16
                ]
                [ row [ width (px 450) ] [ text "Files", el [ alignRight ] Widget.closePopupButton ]
                , column
                    [ spacing 8
                    , height (px 400)
                    , scrollbarY
                    ]
                    (List.map viewFileName (List.sortBy .fileName model.fileList))
                ]

        PopupOpen _ ->
            Element.none


viewFileName : Metadata -> Element Msg
viewFileName record =
    row []
        [ Widget.plainButton 200 record.fileName (SendRequestForFile record.id) []
        , Widget.plainButton 55
            "delete!!"
            (DeleteFileFromLocalStorage record.id)
            [ Background.color (Element.rgba 0.7 0.7 1.0 0.9) ]
        ]
