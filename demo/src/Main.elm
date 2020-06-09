module Main exposing (main)

import Browser
import Browser.Dom as Dom
import Browser.Events
import Cmd.Extra exposing (withCmd, withCmds, withNoCmd)
import Config
import ContextMenu exposing (Item(..))
import Data
import Document exposing (DocType(..))
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
import Helper.Author
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
        , DocumentStatus(..)
        , FileLocation(..)
        , Model
        , Msg(..)
        , PopupStatus(..)
        , PopupWindow(..)
        )
import UuidHelper
import View.AuthorPopup as AuthorPopup
import View.FileListPopup as RemoteFileListPopup
import View.FilePopup as FilePopup
import View.LocalStoragePopup as FileListPopup
import View.NewFilePopup as NewFilePopup
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
    , currentTime = Time.millisToPosix 0
    , messageLife = 0
    , width = flags.width
    , height = flags.height
    , docTitle = "about"
    , docType = MarkdownDoc
    , fileName = "about.md"
    , fileName_ = ""
    , changingFileNameState = FileNameOK
    , fileList = []
    , fileLocation = LocalFiles
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
    , fileStorageUrl = Config.localServerUrl

    -- Author
    , userName = ""
    , email = ""
    , password = ""
    , passwordAgain = ""
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
        , Time.every Config.tickInterval Tick
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
                , fileName = Helper.File.updateDocType newDocType model.fileName
              }
            , Cmd.none
            )

        CreateDocument ->
            let
                newModel =
                    case model.docType of
                        MarkdownDoc ->
                            Helper.Load.loadDocument_ model.fileName_ "" MarkdownDoc model

                        MiniLaTeXDoc ->
                            Helper.Load.loadDocument_ model.fileName_ "" MiniLaTeXDoc model

                doc =
                    newModel.document
            in
            { newModel | popupStatus = PopupClosed }
                |> Helper.Sync.syncModel2
                |> withCmd
                    (Cmd.batch
                        [ View.Scroll.toEditorTop
                        , View.Scroll.toRenderedTextTop
                        , Helper.File.createDocument model.fileStorageUrl doc
                        ]
                    )

        --
        --|> Helper.Sync.syncModel2
        --|> withCmd
        --    (Cmd.batch
        --        [ View.Scroll.toEditorTop
        --        , View.Scroll.toRenderedTextTop
        --        ]
        --    )
        SetViewPortForElement result ->
            case result of
                Ok ( element, viewport ) ->
                    model
                        |> postMessage "synced"
                        |> withCmd (View.Scroll.setViewPortForSelectedLineInRenderedText element viewport)

                Err _ ->
                    model
                        |> postMessage "sync error"
                        |> withNoCmd

        RequestFile ->
            ( model, Helper.File.requestFile )

        RequestedFile file ->
            ( { model | fileName = File.name file }, Helper.File.read file )

        DocumentLoaded source ->
            let
                docType =
                    case Helper.File.fileExtension model.fileName of
                        "md" ->
                            MarkdownDoc

                        "latex" ->
                            MiniLaTeXDoc

                        "tex" ->
                            MiniLaTeXDoc

                        _ ->
                            MarkdownDoc

                newModel =
                    Helper.Load.loadDocument_ (Helper.File.titleFromFileName model.fileName) source docType model
                        |> (\m -> { m | docType = docType })
                        |> Helper.Sync.syncModel2

                newDocument =
                    newModel.document
            in
            newModel
                |> withCmds
                    [ View.Scroll.toRenderedTextTop
                    , View.Scroll.toEditorTop
                    , Helper.File.updateDocument model.fileStorageUrl newDocument
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
                    Helper.Load.loadDocument file model
                        |> (\m -> m |> withCmd (Helper.File.updateDocument m.fileStorageUrl m.document))

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

        Tick t ->
            { model | currentTime = t }
                |> updateMessageLife
                |> saveFileToStorage

        ManagePopup status ->
            case status of
                PopupOpen LocalStoragePopup ->
                    -- TODO: needs to be eliminated
                    { model | popupStatus = status }
                        |> withCmd (Helper.File.getDocumentList model.fileStorageUrl)

                PopupOpen FilePopup ->
                    { model | popupStatus = status } |> withNoCmd

                PopupOpen NewFilePopup ->
                    { model | popupStatus = status } |> withNoCmd

                PopupOpen RemoteFileListPopup ->
                    { model | popupStatus = status, documentStatus = DocumentSaved }
                        |> withCmds
                            [ Helper.File.getDocumentList model.fileStorageUrl
                            , Helper.File.updateDocument model.fileStorageUrl model.document
                            ]

                PopupOpen _ ->
                    { model | popupStatus = status } |> withNoCmd

                PopupClosed ->
                    { model | popupStatus = status } |> withNoCmd

        -- LOCAL STORAGE
        SendRequestForFile fileName ->
            { model
                | fileName = fileName
            }
                --, Outside.sendInfo (Outside.AskForFile fileName)
                |> withNoCmd

        DeleteFileFromLocalStorage fileName ->
            model
                -- Outside.sendInfo (Outside.DeleteFileFromLocalStorage fileName)
                |> withNoCmd

        SaveFileToStorage ->
            { model | documentStatus = DocumentSaved }
                |> withCmd (Helper.File.updateDocument model.fileStorageUrl model.document)

        InputFileName str ->
            ( { model | fileName_ = str, changingFileNameState = ChangingFileName }, Cmd.none )

        ChangeFileName fileName ->
            let
                oldDocument =
                    model.document

                newDocument =
                    { oldDocument | fileName = fileName }
            in
            ( { model
                | fileName = model.fileName_
                , docType = Helper.File.docType model.fileName_
                , changingFileNameState = FileNameOK
                , popupStatus = PopupClosed
                , document = newDocument
                , fileList = Helper.File.updateFileList (Document.miniFileRecord newDocument) model.fileList
              }
            , Helper.File.updateDocument model.fileStorageUrl newDocument
            )

        SoftDelete record ->
            let
                newRecord =
                    { record | fileName = Helper.File.addPostfix "deleted" record.fileName }
            in
            { model
                | fileList = Helper.File.updateFileList newRecord model.fileList
            }
                |> withCmd (Helper.File.updateDocumentList model.fileStorageUrl newRecord)

        CancelChangeFileName ->
            ( { model | fileName_ = model.fileName, changingFileNameState = FileNameOK }, Cmd.none )

        About ->
            ( Helper.Load.loadDocumentByTitle "about" model, Cmd.none )

        InputAuthorname str ->
            { model | authorName = str } |> withNoCmd

        GotAtmosphericRandomNumber result ->
            UuidHelper.handleResponseFromRandomDotOrg model result
                |> withNoCmd

        AskForDocument fileName ->
            { model | popupStatus = PopupClosed } |> withCmd (Helper.File.getDocument model.fileStorageUrl fileName)

        GotDocument result ->
            case result of
                Ok document ->
                    Helper.Load.loadDocument document model
                        |> withNoCmd

                Err _ ->
                    model
                        |> postMessage "Error getting remote document"
                        |> withNoCmd

        AskForRemoteDocuments ->
            model |> withCmd (Helper.File.getDocumentList model.fileStorageUrl)

        GotDocuments result ->
            case result of
                Ok documents ->
                    { model | fileList = documents } |> withNoCmd

                Err _ ->
                    model
                        |> postMessage "Error getting remote documents"
                        |> withNoCmd

        Message result ->
            case result of
                Ok str ->
                    model
                        |> postMessage str
                        |> withNoCmd

                Err _ ->
                    model
                        |> postMessage "Unknown error"
                        |> withNoCmd

        ToggleFileLocation fileLocation ->
            let
                fileStorageUrl =
                    case fileLocation of
                        LocalFiles ->
                            Config.localServerUrl

                        RemoteFiles ->
                            Config.remoteServerUrl
            in
            { model
                | fileLocation = fileLocation
                , fileStorageUrl = fileStorageUrl
            }
                |> withNoCmd

        InputUsername str ->
            { model | userName = str } |> withNoCmd

        InputEmail str ->
            { model | email = str } |> withNoCmd

        InputPassword str ->
            { model | password = str } |> withNoCmd

        InputPasswordAgain str ->
            { model | passwordAgain = str } |> withNoCmd

        CreateAuthor ->
            let
                ( uuid, seed ) =
                    UuidHelper.generate model.randomSeed

                newAuthor =
                    Helper.Author.createAuthor model.currentTime
                        uuid
                        model.password
                        model.authorName
                        model.userName
                        model.email
            in
            { model | randomSeed = seed }
                |> postMessage ("Created: " ++ model.userName)
                |> withCmd (Helper.Author.persist model.fileStorageUrl newAuthor)



-- HELPER


postMessage : String -> Model -> Model
postMessage msg model =
    { model | message = msg, messageLife = Config.messageLifeTime }


updateMessageLife : Model -> Model
updateMessageLife model =
    case model.messageLife > 0 of
        True ->
            { model | messageLife = model.messageLife - 1 }

        False ->
            model


saveFileToStorage_ : Model -> ( Model, Cmd Msg )
saveFileToStorage_ model =
    case model.documentStatus of
        DocumentDirty ->
            ( { model
                | tickCount = model.tickCount + 1
                , documentStatus = DocumentSaved
              }
            , Cmd.batch
                [ Helper.File.updateDocument model.fileStorageUrl model.document
                ]
            )

        DocumentSaved ->
            ( { model | tickCount = model.tickCount + 1 }
            , Cmd.none
            )


saveFileToStorage : Model -> ( Model, Cmd Msg )
saveFileToStorage model =
    case modBy 15 model.tickCount == 14 of
        True ->
            saveFileToStorage_ model

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
    Element.layoutWith { options = [ Element.focusStyle myFocusStyle ] }
        [ Background.color <| gray 55 ]
        (mainColumn model)


myFocusStyle =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }


mainColumn model =
    column [ centerX, centerY ]
        [ column [ Background.color <| gray 55 ]
            [ Element.el
                [ Element.inFront (AuthorPopup.view model)
                , Element.inFront (FileListPopup.view model)
                , Element.inFront (FilePopup.view model)
                , Element.inFront (RemoteFileListPopup.view model)
                , Element.inFront (NewFilePopup.view model)
                ]
                (viewEditorAndRenderedText model)
            , viewFooter model model.width 40
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
        [ View.Widget.openAuthorPopupButton model
        , View.Widget.openFileListPopupButton model
        , View.Widget.toggleFileLocationButton model
        , View.Widget.saveFileToStorageButton model
        , View.Widget.documentTypeButton model
        , View.Widget.openNewFilePopupButton model
        , View.Widget.openFilePopupButton model
        , View.Widget.importFileButton model
        , View.Widget.exportFileButton model
        , View.Widget.exportLaTeXFileButton model
        , displayFilename model
        , row [ alignRight, spacing 12 ]
            [ displayMessage model
            , View.Widget.aboutButton
            ]
        ]


displayMessage model =
    showIf (model.messageLife > 0)
        (el
            [ width (px 250)
            , paddingXY 8 8
            , Background.color Style.whiteColor
            , Font.color Style.blackColor
            ]
            (text model.message)
        )


displayFilename : Model -> Element Msg
displayFilename model =
    el [] (text model.fileName)


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
