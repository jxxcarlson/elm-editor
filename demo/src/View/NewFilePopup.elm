module View.NewFilePopup exposing (fileInput, fileNameInput, titleLine, view)

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
import Helper.Common
import Types exposing (Model, Msg(..), PopupStatus(..), PopupWindow(..))
import View.Widget as Widget
import Widget.TextField as TextField exposing (LabelPosition(..))


view : Model -> Element Msg
view model =
    case model.popupStatus of
        PopupClosed ->
            Element.none

        PopupOpen NewFilePopup ->
            column
                [ width (px 500)
                , height (px <| round <| Helper.Common.windowHeight model.height + 28)
                , paddingXY 30 30
                , Background.color (Element.rgba 1.0 0.75 0.75 0.8)
                , spacing 16
                ]
                [ titleLine
                , fileNameInput model
                , Widget.newDocumentButton
                ]

        PopupOpen _ ->
            Element.none


titleLine : Element Msg
titleLine =
    row [ width (px 450) ] [ text "New File", el [ alignRight ] Widget.closePopupButton ]


fileInput : (String -> msg) -> String -> String -> Element msg
fileInput msg text label =
    TextField.make msg text label
        |> TextField.withHeight 30
        |> TextField.withWidth 150
        |> TextField.withLabelWidth 70
        |> TextField.withLabelPosition LabelAbove
        |> TextField.toElement


fileNameInput : Model -> Element Msg
fileNameInput model =
    fileInput InputFileName model.fileName_ "File name"
