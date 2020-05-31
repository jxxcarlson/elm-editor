module Main exposing (main)

import Browser
import Browser.Dom as Dom
import Browser.Events
import Cmd.Extra exposing (withCmd, withCmds, withNoCmd)
import ContextMenu exposing (Item(..))
import Data
import Editor exposing (Editor, EditorMsg)
import EditorMsg exposing (EMsg(..))
import Element
    exposing
        ( Element
        , alignRight
        , centerX
        , centerY
        , column
        , el
        , height
        , paddingXY
        , px
        , rgb255
        , row
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import File exposing (File)
import Helper.Common
import Helper.File
import Helper.Load
import Helper.Sync
import Html exposing (Attribute, Html)
import Html.Attributes as Attribute
import Json.Encode
import Markdown.Option exposing (..)
import Markdown.Render exposing (MarkdownMsg(..))
import MiniLatex.Edit as MLE
import Outside
import Random
import Render exposing (MDData, MLData, RenderingData(..), RenderingOption(..))
import Render.Types exposing (RenderMsg(..))
import Task exposing (Task)
import Time
import Types
    exposing
        ( ChangingFileNameState(..)
        , DocType(..)
        , DocumentStatus(..)
        , Model
        , Msg(..)
        , PopupStatus(..)
        , PopupWindow(..)
        )
import UUID
import UuidHelper
import View.AuthorPopup as AuthorPopup
import View.FileListPopup as FileListPopup
import View.Scroll
import View.Style as Style
import View.Widget


type alias Flags =
    { width : Float, height : Float }


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        newEditor =
            Editor.initWithContent Data.about (Helper.Load.config flags)
    in
    { editor = newEditor
    , renderingData = load 0 ( 0, 0 ) (OMarkdown ExtendedMath) Data.about
    , counter = 1
    , width = flags.width
    , height = flags.height
    , docTitle = "about"
    , docType = MarkdownDoc
    , fileName = Just "about.md"
    , newFileName = "about.md"
    , changingFileNameState = FileNameOK
    , fileList = []
    , documentStatus = DocumentSaved
    , selectedId = ( 0, 0 )
    , selectedId_ = ""
    , message = ""
    , tickCount = 0
    , popupStatus = PopupClosed
    , authorName = ""
    , document = { fileName = "untitled", id = "1234", content = "---" }
    , randomSeed = Random.initialSeed 1727485
    , uuid = ""
    }
        |> Helper.Sync.syncModel newEditor
        |> Cmd.Extra.withCmds
            [ Dom.focus "editor" |> Task.attempt (always NoOp)
            , View.Scroll.toEditorTop
            , View.Scroll.toRenderedTextTop
            , UuidHelper.getRandomNumber
            ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ ContextMenu.subscriptions (Editor.getContextMenu model.editor)
            |> Sub.map ContextMenuMsg
            |> Sub.map EditorMsg
        , Outside.getInfo Outside LogErr
        , Browser.Events.onResize WindowSize
        , Time.every 10000 Tick
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        EditorMsg editorMsg ->
            -- Handle messages from the Editor.  The messages CopyPasteClipboard, ... GotViewportForSync
            -- require special handling.  The others are passed to a default handler
            let
                ( newEditor, cmd ) =
                    Editor.update editorMsg model.editor
            in
            case editorMsg of
                CopyPasteClipboard ->
                    let
                        clipBoardCmd =
                            Outside.sendInfo (Outside.AskForClipBoard Json.Encode.null)
                    in
                    model
                        |> Helper.Sync.syncModel newEditor
                        |> withCmds [ clipBoardCmd, Cmd.map EditorMsg cmd ]

                WriteToSystemClipBoard ->
                    ( { model | editor = newEditor }, Outside.sendInfo (Outside.WriteToClipBoard (Editor.getSelectedString newEditor |> Maybe.withDefault "Nothing!!")) )

                Unload _ ->
                    Helper.Sync.sync newEditor cmd model

                InsertChar _ ->
                    Helper.Sync.sync newEditor cmd model

                MarkdownLoaded _ ->
                    Helper.Sync.sync newEditor cmd model

                SendLineForLRSync ->
                    {- DOC scroll LR (3) -}
                    Helper.Sync.syncAndHighlightRenderedText (Editor.lineAtCursor newEditor) (Cmd.map EditorMsg cmd) { model | editor = newEditor }

                GotViewportForSync currentLine _ _ ->
                    case currentLine of
                        Nothing ->
                            ( model, Cmd.none )

                        Just str ->
                            Helper.Sync.syncAndHighlightRenderedText str Cmd.none model

                _ ->
                    -- Handle the default cases
                    case List.member msg (List.map EditorMsg Editor.syncMessages) of
                        True ->
                            Helper.Sync.sync newEditor cmd model

                        False ->
                            ( { model | editor = newEditor }, Cmd.map EditorMsg cmd )

        WindowSize width height ->
            let
                w =
                    toFloat width

                h =
                    toFloat height
            in
            ( { model
                | width = w
                , height = h
                , editor = Editor.resize (Helper.Common.windowWidth w) (Helper.Common.windowHeight h) model.editor
              }
            , Cmd.none
            )

        Load title ->
            Helper.Load.loadDocumentByTitle title model
                |> withCmd
                    (Cmd.batch
                        [ View.Scroll.toEditorTop
                        , View.Scroll.toRenderedTextTop
                        ]
                    )

        ToggleDocType ->
            let
                newDocType =
                    case model.docType of
                        MarkdownDoc ->
                            MiniLaTeXDoc

                        MiniLaTeXDoc ->
                            MarkdownDoc
            in
            ( { model
                | docType = newDocType
                , fileName = Maybe.map (Helper.File.updateDocType newDocType) model.fileName
              }
            , Cmd.none
            )

        NewDocument ->
            case model.docType of
                MarkdownDoc ->
                    Helper.Load.loadDocument_ "newFile" "" MarkdownDoc model
                        |> Helper.Sync.syncModel2
                        |> withCmd (Cmd.batch [ View.Scroll.toEditorTop, View.Scroll.toRenderedTextTop ])

                MiniLaTeXDoc ->
                    Helper.Load.loadDocument_ "newFile" "" MiniLaTeXDoc model
                        |> Helper.Sync.syncModel2
                        |> withCmd (Cmd.batch [ View.Scroll.toEditorTop, View.Scroll.toRenderedTextTop ])

        SetViewPortForElement result ->
            case result of
                Ok ( element, viewport ) ->
                    ( { model | message = "synced" }, View.Scroll.setViewPortForSelectedLineInRenderedText element viewport )

                Err _ ->
                    ( { model | message = "sync error" }, Cmd.none )

        RequestFile ->
            ( model, Helper.File.requestFile )

        RequestedFile file ->
            ( { model | fileName = Just (File.name file) }, Helper.File.read file )

        DocumentLoaded source ->
            case model.fileName of
                Nothing ->
                    ( model, Cmd.none )

                Just fileName ->
                    let
                        docType =
                            case Helper.File.fileExtension fileName of
                                "md" ->
                                    MarkdownDoc

                                "latex" ->
                                    MiniLaTeXDoc

                                "tex" ->
                                    MiniLaTeXDoc

                                _ ->
                                    MarkdownDoc

                        newModel =
                            Helper.Load.loadDocument_ (Helper.File.titleFromFileName fileName) source docType model
                                |> (\m -> { m | docType = docType })
                                |> Helper.Sync.syncModel2

                        newDocument =
                            newModel.document
                    in
                    newModel
                        |> withCmds
                            [ View.Scroll.toRenderedTextTop
                            , View.Scroll.toEditorTop
                            , Helper.File.saveFileToLocalStorage_ newDocument
                            ]

        SaveFile ->
            ( model, Helper.File.saveFile model )

        ExportFile ->
            ( model, Helper.File.exportFile model )

        SyncLR ->
            let
                ( newEditor, cmd ) =
                    Editor.sendLine model.editor
            in
            ( { model | editor = newEditor }, Cmd.map EditorMsg cmd )

        Outside infoForElm ->
            case infoForElm of
                Outside.GotClipboard clipboard ->
                    pasteToEditorAndClipboard model clipboard

                Outside.GotFileList fileList ->
                    ( { model | fileList = fileList }, Cmd.none )

                Outside.GotFile file ->
                    ( Helper.Load.loadDocument file model, Cmd.none )

        LogErr _ ->
            ( model, Cmd.none )

        RenderMsg renderMsg ->
            {- DOC sync RL: renderMsg receives the id of the element clicked in
               the rendered text.  It is used highlight the corresponding
               source text (RL sync)
            -}
            case renderMsg of
                LaTeXMsg latexMsg ->
                    case latexMsg of
                        MLE.IDClicked id ->
                            Helper.Sync.onId id model

                Render.Types.MarkdownMsg markdownMsg ->
                    case markdownMsg of
                        IDClicked id ->
                            Helper.Sync.onId id model

        Tick _ ->
            saveFileToLocalStorage model

        ManagePopup status ->
            let
                cmd =
                    case status of
                        PopupOpen FileListPopup ->
                            Helper.File.getListOfFilesInLocalStorage

                        PopupOpen _ ->
                            Cmd.none

                        PopupClosed ->
                            Cmd.none
            in
            ( { model | popupStatus = status }, cmd )

        SendRequestForFile fileName ->
            ( { model
                | fileName = Just fileName
              }
            , Outside.sendInfo (Outside.AskForFile fileName)
            )

        DeleteFileFromLocalStorage fileName ->
            ( model, Outside.sendInfo (Outside.DeleteFileFromLocalStorage fileName) )

        SaveFileToLocalStorage ->
            saveFileToLocalStorage_ model

        InputFileName str ->
            ( { model | newFileName = str, changingFileNameState = ChangingFileName }, Cmd.none )

        ChangeFileName ->
            let
                oldDocument =
                    model.document

                newDocument =
                    { oldDocument | fileName = model.newFileName }
            in
            ( { model
                | fileName = Just model.newFileName
                , docType = Helper.File.docType model.newFileName
                , changingFileNameState = FileNameOK
                , document = newDocument
              }
            , Helper.File.saveFileToLocalStorage_ newDocument
            )

        CancelChangeFileName ->
            case model.fileName of
                Nothing ->
                    ( model, Cmd.none )

                Just fileName ->
                    ( { model | newFileName = fileName, changingFileNameState = FileNameOK }, Cmd.none )

        About ->
            ( Helper.Load.loadDocumentByTitle "about" model, Cmd.none )

        InputAuthorname str ->
            { model | authorName = str } |> withNoCmd

        GotAtmosphericRandomNumber result ->
            UuidHelper.handleResponseFromRandomDotOrg model result
                |> withNoCmd



-- HELPER


saveFileToLocalStorage_ : Model -> ( Model, Cmd Msg )
saveFileToLocalStorage_ model =
    case model.documentStatus of
        DocumentDirty ->
            ( { model
                | tickCount = model.tickCount + 1
                , documentStatus = DocumentSaved
              }
            , Helper.File.saveFileToLocalStorage model
            )

        DocumentSaved ->
            ( { model | tickCount = model.tickCount + 1 }
            , Cmd.none
            )


saveFileToLocalStorage : Model -> ( Model, Cmd Msg )
saveFileToLocalStorage model =
    case modBy 15 model.tickCount == 14 of
        True ->
            saveFileToLocalStorage_ model

        False ->
            ( { model | tickCount = model.tickCount + 1 }
            , Cmd.none
            )


pasteToEditorAndClipboard : Model -> String -> ( Model, Cmd msg )
pasteToEditorAndClipboard model str =
    let
        cursor =
            Editor.getCursor model.editor

        wrapOption =
            Editor.getWrapOption model.editor

        editor2 =
            Editor.placeInClipboard str model.editor
    in
    { model | editor = Editor.insertAtCursor str editor2 } |> withCmd Cmd.none


loadRenderingData : String -> Model -> Model
loadRenderingData source model =
    let
        counter =
            model.counter + 1

        newRenderingData : RenderingData
        newRenderingData =
            Render.update ( 0, 0 ) counter source model.renderingData
    in
    { model | renderingData = newRenderingData, counter = counter }


load : Int -> ( Int, Int ) -> RenderingOption -> String -> RenderingData
load counter selectedId renderingOption str =
    Render.load selectedId counter renderingOption str



-- VIEW


view : Model -> Html Msg
view model =
    Element.layout [ Background.color <| gray 55 ]
        (mainColumn model)


mainColumn model =
    column [ centerX, centerY ]
        [ column [ Background.color <| gray 55 ]
            [ Element.el [ Element.inFront (FileListPopup.view model), Element.inFront (AuthorPopup.view model) ]
                (viewEditorAndRenderedText model)
            , viewFooter model model.width 40

            -- , viewFooter2 model model.width 40
            ]
        ]


viewEditorAndRenderedText model =
    row [ Background.color <| gray 255 ]
        [ viewEditor model
        , viewRenderedText
            model
            (Helper.Common.windowWidth model.width - 40)
            (Helper.Common.windowHeight model.height + 40)
        ]


viewFooter model width_ height_ =
    row
        [ width (pxFloat (2 * Helper.Common.windowWidth width_ - 40))
        , height (pxFloat height_)
        , Background.color (Element.rgb255 130 130 140)
        , Font.color (gray 240)
        , Font.size 14
        , paddingXY 10 0
        , Element.moveUp 19
        , spacing 12
        ]
        [ -- View.Widget.openAuthorPopupButton model
          View.Widget.openFileListPopupButton model
        , View.Widget.saveFileToLocalStorageButton model
        , View.Widget.documentTypeButton model
        , View.Widget.newDocumentButton model
        , View.Widget.openFileButton model
        , View.Widget.saveFileButton model
        , View.Widget.exportFileButton model

        -- , displayFilename model
        , View.Widget.changeFileNameButton model
        , showIf (model.changingFileNameState == ChangingFileName) View.Widget.cancelChangeFileNameButton
        , el [ Element.paddingEach { top = 10, bottom = 0, left = 0, right = 0 } ] (View.Widget.inputFileName model)
        , View.Widget.aboutButton
        , el [ alignRight, width (px 100) ] (text model.message)
        ]


displayFilename : Model -> Element Msg
displayFilename model =
    let
        message =
            case model.fileName of
                Nothing ->
                    "No file"

                Just fn ->
                    "File: " ++ fn
    in
    el [] (text message)


viewEditor model =
    Editor.view model.editor |> Html.map EditorMsg |> Element.html


viewRenderedText : Model -> Float -> Float -> Element Msg
viewRenderedText model width_ height_ =
    column
        [ width (pxFloat width_)
        , height (pxFloat height_)
        , Font.size 14
        , Element.htmlAttribute (Attribute.style "line-height" "20px")
        , Element.paddingEach { left = 14, top = 0, right = 14, bottom = 24 }
        , Border.width 1
        , Background.color <| gray 255

        -- , Element.htmlAttribute (Attribute.id model.selectedId_ (Html.style "background-color" "#cce"))
        ]
        [ showIf (model.docType == MarkdownDoc)
            ((Render.get model.selectedId_ model.renderingData).title |> Html.map RenderMsg |> Element.html)
        , (Render.get model.selectedId_ model.renderingData).document |> Html.map RenderMsg |> Element.html
        ]



-- VIEW HELPERS


showIf : Bool -> Element Msg -> Element Msg
showIf flag el =
    case flag of
        True ->
            el

        False ->
            Element.none


setHtmlId : String -> Html.Attribute msg
setHtmlId id =
    Attribute.attribute "id" id


setElementId : String -> Element.Attribute msg
setElementId id =
    Element.htmlAttribute (setHtmlId id)


pxFloat : Float -> Element.Length
pxFloat p =
    px (round p)


gray g =
    rgb255 g g g
