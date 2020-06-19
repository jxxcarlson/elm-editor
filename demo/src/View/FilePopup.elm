module View.FilePopup exposing (..)

import Date
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

        PopupOpen FilePopup ->
            column
                [ width (px 500)
                , height (px <| round <| Helper.Common.windowHeight model.height + 28)
                , paddingXY 30 30
                , Background.color (Element.rgba 1.0 0.75 0.75 0.8)
                , spacing 24
                ]
                [ titleLine model
                , column [ spacing 36 ]
                    [ infoPanel model
                    , changePanel model
                    ]
                ]

        PopupOpen _ ->
            Element.none


infoPanel model =
    column [ spacing 12 ]
        [ item "File name" model.document.fileName
        , item "id" model.document.id
        , item "Author" model.document.author
        , item "Created" (Helper.Common.dateStringFromPosix model.document.timeCreated)
        , item "Modified" (Helper.Common.dateStringFromPosix model.document.timeUpdated)
        , item "Tags" (String.join ", " model.document.tags)
        , item "Categories" (String.join ", " model.document.categories)
        ]


changePanel model =
    column [ spacing 12 ]
        [ fileNameInput model
        , row [ spacing 12 ]
            [ Widget.changeFileNameButton model.fileName_
            , Widget.cancelChangeFileNameButton
            ]
        ]


item : String -> String -> Element msg
item label str =
    row [ Font.size 14, spacing 12 ]
        [ el [ Font.bold, width (px 65) ] (el [ alignRight ] (text label))
        , el [] (text str)
        ]


titleLine model =
    row [ width (px 450) ] [ text "File info", el [ alignRight ] (Widget.closePopupButton model) ]


fileInput msg text label =
    TextField.make msg text label
        |> TextField.withHeight 30
        |> TextField.withWidth 150
        |> TextField.withLabelWidth 70
        |> TextField.withLabelPosition LabelAbove
        |> TextField.toElement


fileNameInput model =
    fileInput InputFileName model.fileName_ "File name"
