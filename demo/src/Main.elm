module Main exposing (main)

-- import View.LocalStoragePopup as FileListPopup

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
import Helper.Server
import Helper.Sync
import Html exposing (Attribute, Html)
import Html.Attributes as Attribute
import Json.Encode
import Markdown.Option exposing (..)
import Outside
import Random
import Render exposing (MDData, MLData, RenderingData(..), RenderingOption(..))
import Render.Types exposing (RenderMsg(..))
import Task exposing (Task)
import Time
import Types
    exposing
        ( Authorization(..)
        , ChangingFileNameState(..)
        , DocumentStatus(..)
        , FileLocation(..)
        , Model
        , Msg(..)
        , PopupStatus(..)
        , PopupWindow(..)
        , SignInMode(..)
        )
import Update.Document
import Update.Helper
import Update.System
import Update.UI
import Update.User
import UuidHelper
import View.AuthorPopup as AuthorPopup
import View.FileListPopup as RemoteFileListPopup
import View.FilePopup as FilePopup
import View.Footer
import View.Helpers
import View.NewFilePopup as NewFilePopup
import View.Scroll


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
            Editor.initWithContent Data.about.content (Helper.Load.config flags)
    in
    { editor = newEditor
    , renderingData = load 0 ( 0, 0 ) (OMarkdown ExtendedMath) Data.about.content
    , counter = 1
    , currentTime = Time.millisToPosix 0
    , preferences = Nothing
    , appMode = Config.appMode
    , messageLife = 0
    , width = flags.width
    , height = flags.height
    , docTitle = "about"
    , docType = MarkdownDoc
    , fileName = "about.md"
    , fileName_ = ""
    , tags_ = ""
    , categories_ = ""
    , title_ = ""
    , subtitle_ = ""
    , abstract_ = ""
    , belongsTo_ = ""
    , changingFileNameState = FileNameOK
    , fileList = []
    , fileLocation = Config.fileLocation
    , documentStatus = DocumentSaved
    , selectedId = ( 0, 0 )
    , selectedId_ = ""
    , message = ""
    , tickCount = 0
    , popupStatus = PopupClosed
    , authorName = ""
    , document = Data.about
    , randomSeed = Random.initialSeed 1727485
    , uuid = ""
    , serverURL = Config.serverURL

    -- Author
    , userName = ""
    , email = ""
    , password = ""
    , passwordAgain = ""
    , signInMode = SetupAuthor
    , currentUser = Nothing
    }
        |> Helper.Sync.syncModel newEditor
        |> Cmd.Extra.withCmds
            [ Dom.focus "editor" |> Task.attempt (always NoOp)
            , View.Scroll.toEditorTop
            , View.Scroll.toRenderedTextTop
            , UuidHelper.getRandomNumber
            , preferencesCmd Config.fileLocation
            ]


preferencesCmd : FileLocation -> Cmd Msg
preferencesCmd fileLocation =
    case fileLocation of
        FilesOnDisk ->
            Outside.sendInfo (Outside.GetPreferences Json.Encode.null)

        FilesOnServer ->
            Cmd.none


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

        -- SYSTEM
        Tick t ->
            { model | currentTime = t }
                |> Update.Helper.updateMessageLife
                |> saveFileToStorage

        GotAtmosphericRandomNumber result ->
            UuidHelper.handleResponseFromRandomDotOrg model result
                |> withNoCmd

        WindowSize width height ->
            Update.System.windowSize width height model

        Message result ->
            Update.System.handleMessage result model

        GetPreferences ->
            model |> withCmd (Outside.sendInfo (Outside.GetPreferences Json.Encode.null))

        GotPreferences preferences ->
            { model | preferences = Just preferences }
                |> Update.Helper.postMessage ("username: " ++ preferences.userName)
                |> withNoCmd

        -- OUTSIDE (JAVASCRIPT INTEROP)
        OutsideInfo msg_ ->
            model
                |> withCmd (Outside.sendInfo msg_)

        Outside infoForElm ->
            case infoForElm of
                Outside.GotClipboard clipboard ->
                    pasteToEditorAndClipboard model clipboard

                Outside.GotFileList fileList ->
                    ( { model | fileList = fileList }, Cmd.none )

                Outside.GotFile file ->
                    Helper.Load.load file model
                        |> (\m -> { m | popupStatus = PopupClosed })
                        -- |> (\m -> m |> withCmd (Helper.Server.updateDocument m.serverURL m.document))
                        -- TODO: fix the above
                        |> withNoCmd

                Outside.GotPreferences preferences ->
                    { model | preferences = Just preferences }
                        |> Update.Helper.postMessage ("username: " ++ preferences.userName)
                        |> withNoCmd

        -- EDITOR
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

        -- DOCUMENT
        LoadAboutDocument ->
            Helper.Load.loadAboutDocument model
                |> withCmd
                    (Cmd.batch
                        [ View.Scroll.toEditorTop
                        , View.Scroll.toRenderedTextTop
                        ]
                    )

        ToggleDocType ->
            Update.Document.toggleDocType model

        CreateDocument ->
            Update.Document.createDocument model

        Publish ->
            model
                |> withCmd (Helper.Server.createDocument model.serverURL model.document)

        GetDocument fileName ->
            { model | popupStatus = PopupClosed } |> withCmd (Update.Document.readDocumentCmd fileName model)

        SetViewPortForElement result ->
            Update.UI.setViewportForElement result model

        GetFileToImport ->
            model
                |> withCmds [ preferencesCmd Config.fileLocation, Helper.File.importFile ]

        ImportFile file ->
            ( { model | fileName = File.name file }, Helper.File.load file )

        DocumentLoaded content ->
            Update.Document.loadDocument content model

        SaveFile ->
            ( model, Helper.Server.saveFile model )

        ExportFile ->
            ( model, Helper.Server.exportFile model )

        -- DOCUMENT SYNC
        SyncLR ->
            Update.UI.syncLR model

        LogErr _ ->
            ( model, Cmd.none )

        RenderMsg renderMsg ->
            Update.UI.handleRenderMsg renderMsg model

        -- UI
        ManagePopup status ->
            Update.UI.managePopup status model

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
            Update.Document.updateDocument model

        InputFileName str ->
            ( { model | fileName_ = str, changingFileNameState = ChangingMetadata }, Cmd.none )

        InputTags str ->
            ( { model | tags_ = str, changingFileNameState = ChangingMetadata }, Cmd.none )

        InputCategories str ->
            ( { model | categories_ = str, changingFileNameState = ChangingMetadata }, Cmd.none )

        InputTitle str ->
            ( { model | title_ = str, changingFileNameState = ChangingMetadata }, Cmd.none )

        InputSubtitle str ->
            ( { model | subtitle_ = str, changingFileNameState = ChangingMetadata }, Cmd.none )

        InputBelongsTo str ->
            ( { model | belongsTo_ = str, changingFileNameState = ChangingMetadata }, Cmd.none )

        ChangeMetadata fileName ->
            Update.Document.changeMetaData model

        SetDocumentDirectory ->
            model
                |> withCmd (Outside.sendInfo (Outside.OpenFileDialog Json.Encode.null))

        SoftDelete record ->
            let
                -- TODO: review
                newRecord =
                    { record | fileName = Helper.Common.addPostfix "deleted" record.fileName }
            in
            { model
                | fileList = Helper.Server.updateFileList newRecord model.fileList
            }
                |> withCmd (Outside.sendInfo (Outside.WriteMetadata newRecord))

        CancelChangeFileName ->
            ( { model | fileName_ = model.fileName, changingFileNameState = FileNameOK }, Cmd.none )

        About ->
            ( Helper.Load.loadAboutDocument model, Cmd.none )

        InputAuthorname str ->
            { model | authorName = str } |> withNoCmd

        AskForDocument fileName ->
            { model | popupStatus = PopupClosed }
                |> withCmd (Helper.Server.getDocument model.serverURL fileName)

        GotDocument result ->
            case result of
                Ok document ->
                    Helper.Load.load document model
                        |> withNoCmd

                Err _ ->
                    model
                        |> Update.Helper.postMessage "Error getting remote document"
                        |> withNoCmd

        AskForRemoteDocuments ->
            model |> withCmd (Helper.Server.getDocumentList model.serverURL)

        GotDocuments result ->
            case result of
                Ok documents ->
                    { model | fileList = documents } |> withNoCmd

                Err e ->
                    model
                        |> Update.Helper.postMessage "GotDocuments: error"
                        |> withNoCmd

        ToggleFileLocation fileLocation ->
            let
                message =
                    case fileLocation of
                        FilesOnDisk ->
                            "# Notice!\n\n*Changing storage to your computer's hard disk.*"

                        FilesOnServer ->
                            "# Notice!\n\n*Changing storage to web server at* " ++ model.serverURL
            in
            { model
                | fileLocation = fileLocation
            }
                |> Helper.Load.load (Data.tmp message)
                |> withNoCmd

        -- AUTHOR / USER
        InputUsername str ->
            { model | userName = str } |> withNoCmd

        InputEmail str ->
            { model | email = str } |> withNoCmd

        InputPassword str ->
            { model | password = str } |> withNoCmd

        InputPasswordAgain str ->
            { model | passwordAgain = str } |> withNoCmd

        SetUserName_ ->
            model |> withCmd (Outside.sendInfo (Outside.SetUserName model.userName))

        CreateAuthor ->
            Update.User.createAuthor model

        SignUp ->
            { model | signInMode = SigningUp, currentUser = Nothing }
                |> withNoCmd

        SignIn ->
            model
                |> withCmd (Helper.Author.signInAuthor model.serverURL model.userName model.password)

        SignOut ->
            { model | signInMode = SigningIn, currentUser = Nothing, popupStatus = PopupClosed }
                |> Update.Helper.postMessage "Signed out"
                |> withNoCmd

        GotSigninReply result ->
            Update.User.gotSigninReply result model



-- HELPER


saveFileToStorage : Model -> ( Model, Cmd Msg )
saveFileToStorage model =
    case modBy 15 model.tickCount == 14 of
        True ->
            Update.Document.updateDocument model

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
        [ Background.color <| View.Helpers.gray 55 ]
        (mainColumn model)


myFocusStyle =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }


mainColumn model =
    column [ centerX, centerY ]
        [ column [ Background.color <| View.Helpers.gray 55 ]
            [ Element.el
                [ Element.inFront (AuthorPopup.view model)
                , Element.inFront (FilePopup.view model)
                , Element.inFront (RemoteFileListPopup.view model)
                , Element.inFront (NewFilePopup.view model)
                ]
                (viewEditorAndRenderedText model)
            , View.Footer.view model model.width 40
            ]
        ]


viewEditorAndRenderedText model =
    row [ Background.color <| View.Helpers.gray 255 ]
        [ viewEditor model
        , viewRenderedText
            model
            (Helper.Common.windowWidth model.width - 40)
            (Helper.Common.windowHeight model.height + 40)
        ]


viewEditor model =
    Editor.view model.editor |> Html.map EditorMsg |> Element.html


viewRenderedText : Model -> Float -> Float -> Element Msg
viewRenderedText model width_ height_ =
    column
        [ width (View.Helpers.pxFloat width_)
        , height (View.Helpers.pxFloat height_)
        , Font.size 14
        , Element.htmlAttribute (Attribute.style "line-height" "20px")
        , Element.paddingEach { left = 14, top = 0, right = 14, bottom = 24 }
        , Border.width 1
        , Background.color <| View.Helpers.gray 255

        -- , Element.htmlAttribute (Attribute.id model.selectedId_ (Html.style "background-color" "#cce"))
        ]
        [ View.Helpers.showIf (model.docType == MarkdownDoc)
            ((Render.get model.selectedId_ model.renderingData).title |> Html.map RenderMsg |> Element.html)
        , (Render.get model.selectedId_ model.renderingData).document |> Html.map RenderMsg |> Element.html
        ]



-- VIEW HELPERS


setHtmlId : String -> Html.Attribute msg
setHtmlId id =
    Attribute.attribute "id" id


setElementId : String -> Element.Attribute msg
setElementId id =
    Element.htmlAttribute (setHtmlId id)
