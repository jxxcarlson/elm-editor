module View.Widget exposing
    ( aboutButton
    , acceptLocalButton
    , acceptOneLocalButton
    , acceptOneRemoteButton
    , acceptRemoteButton
    , button
    , cancelChangeMetadataButton
    , cancelSignInButton
    , changeMetadataButton
    , closePopupButton
    , createAuthorButton
    , documentTypeButton
    , exportFileButton
    , exportLaTeXFileButton
    , forcePushDocumentButton
    , getPreferencesButton
    , importFileButton
    , loadDocumentButton
    , newDocumentButton
    , openFileListPopupButton
    , openFilePopupButton
    , openIndexButton
    , openNewFilePopupButton
    , openPreferencesPopupButton
    , openSyncPopup
    , plainButton
    , publishFileButton
    , rejectOneLocalButton
    , rejectOneRemoteButton
    , saveFileToStorageButton
    , searchInput
    , searchOptionsButton
    , serverStatus
    , setDocumentDirectoryButton
    , setUserNameButton
    , signInButton
    , signOutButton
    , signUpButton
    , syncDocumentButton
    , textField
    , toggleFileLocationButton
    )

import Document exposing (DocType(..))
import Element
    exposing
        ( Element
        , alignRight
        , el
        , height
        , padding
        , paddingXY
        , px
        , text
        , width
        )
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Helper.Server
import Html exposing (Attribute, Html)
import Html.Attributes as Attribute
import Html.Events as HE
import Types
    exposing
        ( DocumentStatus(..)
        , FileLocation(..)
        , MergeSite(..)
        , Model
        , Msg(..)
        , PopupStatus(..)
        , PopupWindow(..)
        , ResolveMergeConflict(..)
        , SearchOptions(..)
        , ServerStatus(..)
        )
import View.Helpers
import View.Style as Style
import Widget.Button as Button exposing (Size(..))
import Widget.TextField as TextField


searchOptionsButton model =
    button_ 120 (stringOfSearchOption model.searchOptions) CycleSearchOptions


stringOfSearchOption : SearchOptions -> String
stringOfSearchOption searchOptions =
    case searchOptions of
        ShowDeleted ->
            "Show deleted"

        ExcludeDeleted ->
            "Exclude deleted"

        ShowDeletedOnly ->
            "Deleted only"



-- AUTHOR


createAuthorButton =
    button_ 70 "Create" CreateAuthor


signUpButton =
    button_ 70 "Sign up" SignUp


signInButton =
    button_ 70 "Sign in" SignIn


signOutButton =
    button_ 70 "Sign out" SignOut


cancelSignInButton =
    button_ 70 "Sign in" SignIn



-- DOCUMENT


getPreferencesButton =
    button_ 170 "Get Preferences" GetPreferences


toggleFileLocationButton model =
    case model.fileLocation of
        FilesOnDisk ->
            button_ 70 "Disk" (ToggleFileLocation FilesOnServer)

        FilesOnServer ->
            button_ 70 "Server" (ToggleFileLocation FilesOnDisk)


aboutButton =
    button_ 50 "About" About


cancelChangeMetadataButton =
    button_ 70 "Cancel" (ManagePopup PopupClosed)


changeMetadataButton fileName =
    case
        ( Document.fileExtension fileName
        , String.length (Document.titleFromFileName fileName) > 0
        )
    of
        ( "md", True ) ->
            changeMetadataButton_ fileName

        ( "tex", True ) ->
            changeMetadataButton_ fileName

        ( "index", True ) ->
            changeMetadataButton_ fileName

        ( _, _ ) ->
            doNotChangeMetadataButton


changeMetadataButton_ fileName =
    button_ 70 "Change" (ChangeMetadata fileName)


doNotChangeMetadataButton =
    button_ 70 "Change" (ManagePopup PopupClosed)



-- [ Font.color (Element.rgb 0.7 0.7 0.7) ]


openSyncPopup =
    buttonWithTitle 30 "S" (ManagePopup (PopupOpen SyncPopup)) "Sync local and remote docs"


syncDocumentButton =
    altButtonWithTitle 110 "Sync" GetDocumentToSync "Sync local and remote docs"


forcePushDocumentButton =
    altButtonWithTitle 110 "Force Push" ForcePush "Force: local > remote"


acceptLocalButton =
    altButtonWithTitle 110 "Accept Local" (AcceptLocal ResolveAll) "Accept local revisions"


acceptRemoteButton =
    altButtonWithTitle 110 "Accept Remote" (AcceptRemote ResolveAll) "Accept remote revisions"


acceptOneLocalButton =
    altButtonWithTitle 140 "Accept One Local" (AcceptLocal ResolveOne) "Accept one local revision"


acceptOneRemoteButton =
    altButtonWithTitle 150 "Accept One Remote" (AcceptRemote ResolveOne) "Accept one remote revision"


rejectOneLocalButton =
    altButtonWithTitle 140 "Reject One Local" (RejectOne LocalSite) "Reject one local revision"


rejectOneRemoteButton =
    altButtonWithTitle 150 "Reject One Remote" (RejectOne RemoteSite) "Reject one remote revision"


setDocumentDirectoryButton =
    button_ 170 "Set Document Directory" SetDocumentDirectory


setUserNameButton =
    button_ 170 "Set User Name" SetUserName_


serverStatus model =
    View.Helpers.showIf (model.fileLocation == FilesOnServer) (serverStatus_ model)


serverStatus_ model =
    case model.serverStatus of
        ServerOffline ->
            el [ width (px 20), height (px 20), Background.color (Element.rgb 0.55 0 0) ]
                (text "")

        ServerOnline ->
            el [ width (px 10), height (px 10), Background.color (Element.rgb 0.2 0.55 0.2) ]
                (text "")

        ServerStatusUnknown ->
            el [ width (px 20), height (px 20), Background.color (Element.rgb 0.55 0.55 0.55) ]
                (text "")


saveFileToStorageButton model =
    case model.documentStatus of
        DocumentDirty ->
            plainButton 20
                ""
                SaveFileToStorage
                [ height (px 20)
                , Background.color (Element.rgb 0.55 0 0)
                , Element.htmlAttribute (Attribute.title "Save file now")
                ]

        DocumentSaved ->
            plainButton 20
                ""
                NoOp
                [ height (px 20)
                , Background.color (Element.rgb 0.0 0.7 0)
                , Element.htmlAttribute (Attribute.title "Save file (its OK now)")
                ]


closePopupButton =
    altButton 20 "X" (ManagePopup PopupClosed) [ Font.size 14 ]


openPreferencesPopupButton model =
    case model.popupStatus of
        PopupOpen PreferencesPopup ->
            button_ 60 "Close" (ManagePopup PopupClosed)

        PopupOpen _ ->
            button_ 90 "Preferences" (ManagePopup PopupClosed)

        PopupClosed ->
            button_ 90 "Preferences" (ManagePopup (PopupOpen PreferencesPopup))


openFileListPopupButton model =
    case model.popupStatus of
        PopupOpen FileListPopup ->
            Button.make (ManagePopup PopupClosed) "Close"
                |> Button.withWidth (Bounded 60)
                |> Button.withSelected False
                |> Button.withBackgroundColor Style.redColor
                |> Button.toElement

        PopupOpen _ ->
            button 60 "Files" (ManagePopup (PopupOpen FileListPopup)) []

        PopupClosed ->
            button 60 "Files" (ManagePopup (PopupOpen FileListPopup)) []


openIndexButton model =
    case model.popupStatus of
        PopupOpen IndexPopup ->
            Button.make (ManagePopup PopupClosed) "Close"
                |> Button.withWidth (Bounded 60)
                |> Button.withSelected False
                |> Button.withBackgroundColor Style.blueColor
                |> Button.toElement

        PopupOpen _ ->
            Button.make (ManagePopup (PopupOpen IndexPopup)) "Index"
                |> Button.withWidth (Bounded 60)
                |> Button.withSelected False
                |> Button.withBackgroundColor Style.blueColor
                |> Button.toElement

        --   button 60 "Index" (ManagePopup (PopupOpen IndexPopup)) []
        PopupClosed ->
            Button.make (ManagePopup (PopupOpen IndexPopup)) "Index"
                |> Button.withWidth (Bounded 60)
                |> Button.withSelected False
                |> Button.withBackgroundColor Style.blueColor
                |> Button.toElement


openFilePopupButton model =
    case model.popupStatus of
        PopupOpen FilePopup ->
            Button.make (ManagePopup PopupClosed) "Close"
                |> Button.withWidth (Bounded 100)
                |> Button.withSelected False
                |> Button.withBackgroundColor Style.redColor
                |> Button.toElement

        PopupOpen _ ->
            button 60 "info" (ManagePopup (PopupOpen FilePopup)) []

        PopupClosed ->
            button 60 "Info " (ManagePopup (PopupOpen FilePopup)) []


openNewFilePopupButton model =
    case model.popupStatus of
        PopupOpen NewFilePopup ->
            Button.make (ManagePopup PopupClosed) "Cancel"
                |> Button.withWidth (Bounded 90)
                |> Button.withSelected False
                |> Button.withBackgroundColor Style.redColor
                |> Button.toElement

        PopupOpen _ ->
            button 90 "New" (ManagePopup (PopupOpen NewFilePopup)) []

        PopupClosed ->
            button 90 "New" (ManagePopup (PopupOpen NewFilePopup)) []


importFileButton model =
    button_ 60 "Import" GetFileToImport


exportFileButton model =
    button_ 60 "Export" SaveFile


publishFileButton model =
    button_ 60 "Publish" Publish


exportLaTeXFileButton model =
    case model.docType of
        MarkdownDoc ->
            Element.none

        MiniLaTeXDoc ->
            button_ 120 "LaTeX Export" ExportFile

        IndexDoc ->
            Element.none


newDocumentButton model =
    button_ 70 "Create" CreateDocument


documentTypeButton model =
    let
        title =
            case model.docType of
                MarkdownDoc ->
                    "Markdown"

                MiniLaTeXDoc ->
                    "LaTeX"

                IndexDoc ->
                    "Index"
    in
    button width
        title
        ToggleDocType
        [ Background.color Style.redColor
        , Element.htmlAttribute (Attribute.title "Cycle document type")
        ]


loadDocumentButton model width docTitle buttonLabel =
    let
        bgColor =
            case model.docTitle == docTitle of
                True ->
                    Style.redColor

                False ->
                    Style.grayColor
    in
    button width buttonLabel LoadAboutDocument [ Background.color bgColor ]


button_ width str msg =
    Button.make msg str
        |> Button.withWidth (Bounded width)
        |> Button.withSelected False
        |> Button.toElement


buttonWithTitle width str msg title =
    Button.make msg str
        |> Button.withWidth (Bounded width)
        |> Button.withSelected False
        |> Button.withTitle title
        |> Button.toElement


altButtonWithTitle width str msg title =
    Button.make msg str
        |> Button.withWidth (Bounded width)
        |> Button.withSelected False
        |> Button.withBackgroundColor Style.lightBlueColor
        |> Button.withTitle title
        |> Button.toElement


searchInput model =
    input InputSearch model.searchText_ "" 300 0


input msg text label width labelWidth =
    TextField.make msg text label
        |> TextField.withHeight 30
        |> TextField.withWidth width
        |> TextField.withLabelWidth labelWidth
        |> TextField.toElement


button width str msg attr =
    Input.button
        ([ paddingXY 8 8
         , Background.color (Element.rgb255 90 90 100)
         ]
            ++ attr
        )
        { onPress = Just msg
        , label = el attr (text str)
        }


altButton width str msg attr =
    Input.button
        ([ paddingXY 8 8
         , Font.color (Element.rgb255 30 30 30)
         ]
            ++ attr
        )
        { onPress = Just msg
        , label = el attr (text str)
        }


plainButton width_ str msg attr =
    Input.button
        ([ paddingXY 8 0
         , Font.color (Element.rgb255 30 30 30)
         , Font.size 14
         , width (px width_)
         ]
            ++ attr
        )
        { onPress = Just msg
        , label = el attr (text str)
        }


textField width str msg attr innerAttr =
    Html.div ([ Attribute.style "margin-bottom" "10px" ] ++ attr)
        [ Html.input
            ([ Attribute.style "height" "18px"
             , Attribute.style "width" (String.fromInt width ++ "px")
             , Attribute.type_ "text"
             , Attribute.placeholder str
             , Attribute.style "margin-right" "8px"
             , HE.onInput msg
             ]
                ++ innerAttr
            )
            []
        ]
