module Main exposing (main)

--

import Browser
import Config
import Debounce exposing (Debounce)
import Dict
import Editor exposing (Editor)
import Element exposing (Element, centerX, centerY, column, el, fill, px, row, text)
import Element.Background as Background
import File
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
import Time
import UI exposing (..)
import Umuli
import View.Footer as Footer



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

        -- Load.makeConfig 800 600
        newEditor =
            Editor.initWithContent Text.start config

        model =
            { windowWidth = flags.width
            , windowHeight = flags.height
            , config = config
            , editor = newEditor
            , data = Umuli.init Umuli.LMiniLaTeX 0 Text.start Nothing
            , macroText = ""
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
            , documentType = MiniLaTeX
            , filePopupOpen = False
            , randomSeed = Random.initialSeed 17319485
            , uuid = "axyadjfa;o2020394aklsd"
            , fileArchive = Server
            , tick = 0
            , currentTime = Time.millisToPosix 0
            , documentDirty = False
            , newFilename = ""
            }
    in
    ( model, Helper.File.checkServer )



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

        SetViewPortForElement result ->
            Helper.Update.setViewPortForElement model result

        LaTeXMsg laTeXMsg ->
            -- TODO: re-implement this
            ( model, Cmd.none )

        MyEditorMsg editorMsg ->
            -- Handle messages from the Editor.  The messages CopyPasteClipboard, ... GotViewportForSync
            -- require special handling.  The others are passed to a default handler
            Helper.Update.handleEditorMsg model msg editorMsg

        ToggleFilePopup ->
            ( { model | filePopupOpen = not model.filePopupOpen }, Cmd.none )

        Export ->
            ( model, Helper.File.export model )

        SaveFile ->
            case model.fileArchive of
                Disk ->
                    ( { model | documentDirty = False }, Helper.File.save model )

                Server ->
                    let
                        content =
                            Editor.getContent model.editor
                    in
                    ( { model | documentDirty = False }, Helper.File.postToServer model.fileName content )

        SavedToServer _ ->
            ( model, Cmd.none )

        ServerIsAlive result ->
            case result of
                Ok _ ->
                    ( { model | fileArchive = Server }, Cmd.none )

                Err _ ->
                    ( { model | fileArchive = Disk }, Cmd.none )

        FileRequested ->
            Helper.Update.fileRequested model

        FileSelected file ->
            Helper.Update.fileSelected model (File.name file) file

        FileLoaded contents ->
            Helper.Update.load_ model.fileName contents { model | documentDirty = True }

        LoadDocument fileName ->
            case Dict.get fileName Text.textDictionary of
                Nothing ->
                    ( model, Cmd.none )

                Just content ->
                    ( Helper.Update.loadDocument fileName content model, Cmd.none )

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

        Umuli _ ->
            ( { model | documentDirty = True }, Cmd.none )

        NewDocument documentType ->
            ( { model
                | documentType = documentType
                , editor = Editor.initWithContent "" model.config
                , data = Umuli.init (Model.umuliLang documentType) model.counter "" Nothing

                -- , fileName = "doc" ++ Model.fileExtension mode
                , filePopupOpen = False
                , documentDirty = False
              }
            , Helper.File.postToServer model.fileName " "
            )

        Tick newTime ->
            let
                ( documentDirty, cmd ) =
                    if modBy Config.saveFileInterval model.tick == 0 && model.documentDirty then
                        ( False, Helper.File.save model )

                    else
                        ( model.documentDirty, Cmd.none )
            in
            ( { model | currentTime = newTime, tick = model.tick + 1, documentDirty = documentDirty }, cmd )

        GotFilename str ->
            ( { model | newFilename = str }, Cmd.none )

        MakeNewfile ->
            let
                documentType =
                    findDocumentType model.newFilename
            in
            ( { model
                | documentType = documentType
                , editor = Editor.initWithContent "" model.config
                , data = Umuli.init (Model.umuliLang documentType) model.counter "" Nothing
                , fileName = model.newFilename
                , newFilename = ""
                , filePopupOpen = False
                , documentDirty = False
              }
            , Helper.File.postToServer model.newFilename ""
            )

        --( { model
        --    | documentType = docType
        --    , editor = Editor.initWithContent "" model.config
        --    , data = Umuli.init (Model.umuliLang docType) model.counter "" Nothing
        --    , fileName = model.newFilename
        --    , filePopupOpen = False
        --    , documentDirty = False
        --  }
        --, Cmd.none
        --)
        CancelNewfile ->
            ( { model | filePopupOpen = False }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



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
                        (Umuli.render "" model.data |> Html.div [] |> Html.map Umuli)
                    )
                ]
            , Footer.view model
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



-- HELPERS


normalize : String -> String
normalize str =
    str |> String.lines |> List.filter (\x -> x /= "") |> String.join "\n"
