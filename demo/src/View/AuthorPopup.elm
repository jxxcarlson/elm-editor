module View.AuthorPopup exposing (..)

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
import Element.Font as Font
import Helper.Common
import Types exposing (Model, Msg(..), PopupStatus(..), PopupWindow(..))
import View.Widget as Widget
import Widget.TextField as TextField exposing (LabelPosition(..))


view : Model -> Element Msg
view model =
    case model.popupStatus of
        PopupClosed ->
            Element.none

        PopupOpen AuthorPopup ->
            column
                [ width (px 500)
                , height (px <| round <| Helper.Common.windowHeight model.height + 28)
                , paddingXY 30 30
                , Background.color (Element.rgba 1.0 0.75 0.75 0.8)
                , spacing 16
                ]
                [ titleLine model
                , authorNameInput model
                , el [ Font.size 14 ] (text model.uuid)
                ]

        PopupOpen _ ->
            Element.none


titleLine model =
    row [ width (px 450) ] [ text "Author", el [ alignRight ] (Widget.closePopupButton model) ]


authorInput msg text label =
    TextField.make msg text label
        |> TextField.withHeight 30
        |> TextField.withWidth 150
        |> TextField.withLabelWidth 70
        |> TextField.withLabelPosition LabelAbove
        |> TextField.toElement


authorNameInput model =
    authorInput InputAuthorname model.authorName "Name"
