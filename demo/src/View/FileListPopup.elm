module View.FileListPopup exposing (view)

import Document exposing (MiniFileRecord)
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
import Types exposing (FileLocation(..), Model, Msg(..), PopupStatus(..), PopupWindow(..))
import View.Widget as Widget


view : Model -> Element Msg
view model =
    case model.popupStatus of
        PopupClosed ->
            Element.none

        PopupOpen RemoteFileListPopup ->
            let
                title =
                    case model.fileLocation of
                        LocalFiles ->
                            "Local Files"

                        RemoteFiles ->
                            "Remote Files"
            in
            column
                [ width (px 500)
                , height (px <| round <| Helper.Common.windowHeight model.height + 28)
                , paddingXY 30 30
                , Background.color (Element.rgba 1.0 0.75 0.75 0.8)
                , spacing 16
                ]
                [ row [ width (px 450) ] [ text title, el [ alignRight ] (Widget.closePopupButton model) ]
                , column
                    [ spacing 8
                    , height (px 400)
                    , scrollbarY
                    ]
                    (model.fileList |> prepareFileList |> List.map viewFileName)
                ]

        PopupOpen _ ->
            Element.none


prepareFileList : List MiniFileRecord -> List MiniFileRecord
prepareFileList fileList =
    fileList
        |> List.filter (\r -> not (String.contains "deleted" r.fileName))
        |> List.sortBy .fileName


viewFileName : MiniFileRecord -> Element Msg
viewFileName record =
    row []
        [ Widget.plainButton 200 record.fileName (AskForDocument record.fileName) []
        , Widget.plainButton 55
            "delete"
            (SoftDelete record)
            [ Background.color (Element.rgba 0.7 0.7 1.0 0.9) ]
        ]
