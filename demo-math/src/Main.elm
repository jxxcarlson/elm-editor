module Main exposing (main)

--

import Browser
import Config
import Debounce exposing (Debounce)
import Editor exposing (Editor)
import Element exposing (Element, centerX, centerY, column, el, fill, px, row, text)
import Element.Background as Background
import Element.Events
import Element.Font as Font
import Element.Input as Input
import Helper.File
import Helper.LaTeX
import Helper.Load as Load
import Helper.Update
import Html exposing (..)
import MiniLatex.EditSimple
import Model exposing (..)
import Process
import Random
import Style.Element
import Task
import Text
import UI exposing (..)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Flags =
    { seed : Int
    , width : Int
    , height : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        config =
            Load.makeConfig flags.width (flags.height - 200)

        newEditor =
            Editor.initWithContent Text.start config

        editRecord =
            MiniLatex.EditSimple.init flags.seed Text.start Nothing

        model =
            { windowWidth = flags.width
            , windowHeight = flags.height
            , config = config
            , editor = newEditor
            , sourceText = Text.start
            , macroText = ""
            , renderedText = MiniLatex.EditSimple.get "" editRecord |> Html.div [] |> Html.map LaTeXMsg
            , editRecord = editRecord
            , debounce = Debounce.init
            , counter = 0
            , seed = flags.seed
            , selectedId = ""
            , message = "No message yet ..."
            , images = []
            , imageUrl = ""
            , fileName = "announcement.tex"
            , printingState = PrintWaiting
            , docId = ""
            }

        -- Editor.initWithContent Text.test1 Load.config
    in
    ( model, Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GetContent str ->
            Helper.Update.getContent model str

        DebounceMsg msg_ ->
            Helper.Update.debounceMsg model msg_

        GetMacroText str ->
            ( { model | macroText = str }, Cmd.none )

        Render str ->
            Helper.Update.render model str

        GenerateSeed ->
            ( model, Random.generate NewSeed (Random.int 1 10000) )

        NewSeed newSeed ->
            ( { model | seed = newSeed }, Cmd.none )

        FullRender ->
            Helper.Update.fullRender model

        RestoreText ->
            Helper.Update.restoreText model

        ExampleText ->
            Helper.Update.exampleText model

        SetViewPortForElement result ->
            Helper.Update.setViewPortForElement model result

        LaTeXMsg laTeXMsg ->
            -- TODO: re-implement this
            ( model, Cmd.none )

        MyEditorMsg editorMsg ->
            -- Handle messages from the Editor.  The messages CopyPasteClipboard, ... GotViewportForSync
            -- require special handling.  The others are passed to a default handler
            Helper.Update.handleEditorMsg model msg editorMsg

        Export ->
            ( model, Helper.File.export model )

        SaveFile ->
            ( model, Helper.File.save model )

        FileRequested ->
            Helper.Update.fileRequested model

        FileSelected file ->
            Helper.Update.fileSelected model file

        FileLoaded contents ->
            Helper.Update.load_ contents model

        Clear ->
            -- TODO: handle this!
            ( model, Cmd.none )

        PrintToPDF ->
            Helper.LaTeX.printToPDF model

        ChangePrintingState printingState ->
            let
                cmd =
                    if printingState == PrintWaiting then
                        Process.sleep 1000 |> Task.perform (always (FinallyDoCleanPrintArtefacts model.docId))

                    else
                        Cmd.none
            in
            ( { model | printingState = printingState }, cmd )

        GotPdfLink result ->
            Helper.LaTeX.gotPdfLink model result

        FinallyDoCleanPrintArtefacts _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    Element.layoutWith { options = [ Element.focusStyle Style.Element.noFocus ] }
        [ Background.color (Style.Element.gray 0.4), Element.width fill, Element.height fill ]
    <|
        column [ centerX, centerY ]
            [ row [ Element.spacing 0 ]
                [ el [ Element.alignTop ] (viewEditor model)

                -- TODO: fix the below (round) --- (round Load.config.width)
                , el [ Element.alignTop ]
                    (UI.renderedSource
                        (model.config.width - 40)
                        (model.config.height + 22)
                        (render model.editRecord)
                    )
                ]
            , footer model
            ]


footer : Model -> Element Msg
footer model =
    row
        [ Element.spacing 12
        , Font.size 14
        , Element.height (px 30)

        -- , Element.width (px (model.windowWidth - 108))
        , Element.width (px (round <| 2 * model.config.width - 7))
        , Background.color (Style.Element.gray 0.2)
        , Font.color (Style.Element.gray 0.9)
        , Element.paddingXY 12 0
        ]
        [ UI.openFileButton 100
        , UI.exportButton 100
        , UI.saveFileButton 100
        , printToPDF model
        , el [] (Element.text ("File: " ++ model.fileName))
        ]


render : MiniLatex.EditSimple.Data -> Html Msg
render editRecord =
    editRecord
        |> MiniLatex.EditSimple.get ""
        |> Html.div []
        |> Html.map LaTeXMsg


viewEditor : Model -> Element Msg
viewEditor model =
    Editor.view model.editor |> Html.map MyEditorMsg |> Element.html


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
                { url = Config.pdfServer ++ "/pdf/" ++ Config.testUuid, label = el [] (Element.text "Click for PDF") }



-- HELPERS


normalize : String -> String
normalize str =
    str |> String.lines |> List.filter (\x -> x /= "") |> String.join "\n"
