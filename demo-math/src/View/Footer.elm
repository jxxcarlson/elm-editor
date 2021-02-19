module View.Footer exposing (view)

import Config
import Element exposing (Element, centerX, centerY, column, el, fill, px, row, text)
import Element.Background as Background
import Element.Events
import Element.Font as Font
import Element.Input as Input
import Model exposing (..)
import Style.Element
import UI exposing (..)


view : Model -> Element Msg
view model =
    row
        [ Element.spacing 12
        , Font.size 14
        , Element.height (px 35)

        -- , Element.width (px (model.windowWidth - 108))
        , Element.width (px (round <| 2 * model.config.width - 7))
        , Background.color (Style.Element.gray 0.2)
        , Font.color (Style.Element.gray 0.9)
        , Element.paddingXY 12 0
        ]
        [ UI.openFileButton 100
        , showIf (model.documentType == MiniLaTeX) (UI.exportButton 100)
        , UI.saveFileButton 100
        , printToPDF model
        , UI.fullRenderButton 100
        , row [ Element.paddingXY 24 0, Element.spacing 8 ]
            [ UI.newDocumentPopup model
            , el
                [ Font.color (Element.rgb 0.9 0.5 0.5) ]
                (Element.text ("File: " ++ model.fileName))
            , fileStatus model.documentDirty
            , fileArchive model.fileArchive
            ]
        , row [ Element.alignRight, Element.spacing 12 ]
            [ UI.loadDocumentButton "start.tex"
            , UI.loadDocumentButton "markdown.md"
            ]
        ]



-- HELPERS


fileArchive : FileArchive -> Element Msg
fileArchive fa =
    case fa of
        Server ->
            el [ Font.color (Style.Element.gray 0.5) ] (Element.text "Archive: server/data")

        Disk ->
            el [ Font.color (Style.Element.gray 0.5) ] (Element.text "Archive: Disk")


fileStatus : Bool -> Element Msg
fileStatus isDirty =
    let
        color =
            if isDirty then
                Element.rgb 0.7 0 0

            else
                Element.rgb 0 0.7 0
    in
    el [ Background.color color, centerX, centerY, Element.width (px 8), Element.height (px 8) ] (Element.text "")


printToPDF : Model -> Element Msg
printToPDF model =
    case model.printingState of
        PrintWaiting ->
            Input.button
                (UI.elementAttribute "title" "Generate PDF" :: Style.Element.simpleButtonStyle)
                { onPress = Just PrintToPDF
                , label = Element.text "PDF"
                }

        PrintProcessing ->
            el [ Font.size 14, Element.padding 8, Element.height (px 30), Background.color Style.Element.blue, Font.color Style.Element.white ]
                (Element.text "Please wait ...")

        PrintReady ->
            Element.link
                [ Font.size 14
                , Background.color (Style.Element.gray 0.2)
                , Element.paddingXY 8 8
                , Font.color (Style.Element.gray 0.8)
                , Element.Events.onClick (ChangePrintingState PrintWaiting)
                , UI.elementAttribute "target" "_blank"
                ]
                { url = Config.pdfServer ++ "/pdf/" ++ model.uuid, label = el [] (Element.text "Click for PDF") }


showIf : Bool -> Element Msg -> Element Msg
showIf flag el =
    if flag then
        el

    else
        Element.none
