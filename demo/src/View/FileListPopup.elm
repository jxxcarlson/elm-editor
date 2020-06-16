module View.FileListPopup exposing (view)

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
import Element.Font as Font
import Helper.Common
import Outside
import Types exposing (FileLocation(..), Model, Msg(..), PopupStatus(..), PopupWindow(..))
import View.Widget as Widget


view : Model -> Element Msg
view model =
    case model.popupStatus of
        PopupClosed ->
            Element.none

        PopupOpen FileListPopup ->
            let
                filesToDisplay =
                    model.fileList |> prepareFileList

                n =
                    List.length filesToDisplay |> String.fromInt

                title =
                    case model.fileLocation of
                        LocalFiles ->
                            "Local Files (" ++ n ++ ")"

                        RemoteFiles ->
                            "Remote Files (" ++ n ++ ")"

                currentRecord =
                    Document.miniFileRecord model.document
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
                    (filesToDisplay |> List.map (viewFileName currentRecord))
                ]

        PopupOpen _ ->
            Element.none


prepareFileList : List Metadata -> List Metadata
prepareFileList fileList =
    fileList
        |> List.filter (\r -> not (String.contains "deleted" r.fileName))
        |> List.sortBy .fileName


viewFileName : Metadata -> Metadata -> Element Msg
viewFileName currentRecord record =
    let
        bgColor =
            case currentRecord.id == record.id of
                True ->
                    Background.color (Element.rgba 0.7 0.7 1.0 0.5)

                False ->
                    Background.color (Element.rgba 0 0 0 0)
    in
    Element.map OutsideInfo <|
        row [ spacing 8 ]
            [ Widget.plainButton 200
                record.fileName
                (Outside.AskForFile record.fileName)
                [ Font.color (Element.rgb 0 0 0.9), bgColor, Element.padding 2 ]

            --, el [ Element.padding 2, Background.color (Element.rgba 0.7 0.3 0.3 0.5) ]
            --    (Widget.plainButton 55
            --        "delete"
            --        (SoftDelete record)
            --        []
            --    )
            ]
