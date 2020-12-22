module View.SyncPopup exposing (view)

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
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Element.Font as Font
import Types exposing (Model, Msg(..), PopupStatus(..), PopupWindow(..))
import View.Helpers
import View.Style as Style
import View.Widget as Widget


view : Model -> Element Msg
view model =
    case ( model.popupStatus, model.currentDocument ) of
        ( PopupClosed, _ ) ->
            Element.none

        ( _, Nothing ) ->
            Element.none

        ( PopupOpen SyncPopup, Just doc ) ->
            column
                [ width (px 550)
                , height (px 260)
                , paddingXY 30 30
                , Background.color (Element.rgba 0.75 0.75 1.0 0.6)
                , Element.alignBottom
                , spacing 18
                ]
                [ titleLine doc
                , row [ spacing 12 ]
                    [ Widget.syncDocumentButton
                    , Widget.forcePushDocumentButton
                    , Widget.acceptLocalButton
                    , Widget.acceptRemoteButton
                    ]
                , row [ spacing 12 ]
                    [ Widget.acceptOneLocalButton
                    , Widget.rejectOneLocalButton
                    ]
                , row [ spacing 12 ]
                    [ Widget.acceptOneRemoteButton
                    , Widget.rejectOneRemoteButton
                    ]
                , displayMessage model
                ]

        ( PopupOpen _, _ ) ->
            Element.none


titleLine : Model -> Element msg
titleLine doc =
    row [ width (px 450), Font.size 14, Font.color Style.blackColor ] [ text doc.fileName, el [ alignRight ] Widget.closePopupButton ]


displayMessage : Model -> Element Msg
displayMessage model =
    View.Helpers.showIf (model.messageLife > 0)
        (el
            [ width (px 450)
            , Font.size 14
            , Font.color Style.blackColor
            ]
            (text model.message)
        )
