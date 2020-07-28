module View.Widget exposing
    ( aboutButton
    , acceptLocalButton
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
    , setDownloadDirectoryButton
    , setUserNameButton
    , signInButton
    , signOutButton
    , signUpButton
    , syncDocumentButton
    , textField
    , toggleFileLocationButton
    , acceptOneLocalButton)

import Document exposing (DocType(..))
import Element
    exposing
        ( el
        , height
        , paddingXY
        , px
        , text
        , width
        , Element
        )
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Html
import Html.Attributes as Attribute
import Html.Events as HE
import Types
    exposing
        ( DocumentStatus(..)
        , FileLocation(..)
        , MergeSite(..)
        , Msg(..)
        , PopupStatus(..)
        , PopupWindow(..)
        , ResolveMergeConflict(..)
        , SearchOptions(..)
        , ServerStatus(..)
        , Model
        )

import View.Helpers
import View.Style as Style
import Widget.Button as Button exposing (Size(..))
import Widget.TextField as TextField


searchOptionsButton : Model -> Element Msg
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


createAuthorButton : Element Msg
createAuthorButton =
    button_ 70 "Create" CreateAuthor


signUpButton : Element Msg
signUpButton =
    button_ 70 "Sign up" SignUp


signInButton : Element Msg
signInButton =
    button_ 70 "Sign in" SignIn


signOutButton : Element Msg
signOutButton =
    button_ 70 "Sign out" SignOut


cancelSignInButton : Element Msg
cancelSignInButton =
    button_ 70 "Sign in" SignIn



-- DOCUMENT


getPreferencesButton : Element Msg
getPreferencesButton =
    button_ 170 "Get Preferences" GetPreferences


toggleFileLocationButton : Model -> Element Msg
toggleFileLocationButton model =
    case model.fileLocation of
        FilesOnDisk ->
            button_ 70 "Disk" (ToggleFileLocation FilesOnServer)

        FilesOnServer ->
            button_ 70 "Server" (ToggleFileLocation FilesOnDisk)


aboutButton : Element Msg
aboutButton =
    button_ 50 "About" About


cancelChangeMetadataButton : Element Msg
cancelChangeMetadataButton =
    button_ 70 "Cancel" (ManagePopup PopupClosed)


changeMetadataButton : String -> Element Msg
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


changeMetadataButton_ : String -> Element Msg
changeMetadataButton_ fileName =
    button_ 70 "Change" (ChangeMetadata fileName)


doNotChangeMetadataButton : Element Msg
doNotChangeMetadataButton =
    button_ 70 "Change" (ManagePopup PopupClosed)



-- [ Font.color (Element.rgb 0.7 0.7 0.7) ]


openSyncPopup : Element Msg
openSyncPopup =
    buttonWithTitle 30 "S" (ManagePopup (PopupOpen SyncPopup)) "Sync local and remote docs"


syncDocumentButton : Element Msg
syncDocumentButton =
    altButtonWithTitle 110 "Sync" GetDocumentToSync "Sync local and remote docs"


forcePushDocumentButton : Element Msg
forcePushDocumentButton =
    altButtonWithTitle 110 "Force Push" ForcePush "Force: local > remote"


acceptLocalButton : Element Msg
acceptLocalButton =
    altButtonWithTitle 110 "Accept Local" (AcceptLocal ResolveAll) "Accept local revisions"


acceptRemoteButton : Element Msg
acceptRemoteButton =
    altButtonWithTitle 110 "Accept Remote" (AcceptRemote ResolveAll) "Accept remote revisions"


acceptOneLocalButton : Element Msg
acceptOneLocalButton =
    altButtonWithTitle 140 "Accept One Local" (AcceptLocal ResolveOne) "Accept one local revision"


acceptOneRemoteButton : Element Msg
acceptOneRemoteButton =
    altButtonWithTitle 150 "Accept One Remote" (AcceptRemote ResolveOne) "Accept one remote revision"


rejectOneLocalButton : Element Msg
rejectOneLocalButton =
    altButtonWithTitle 140 "Reject One Local" (RejectOne LocalSite) "Reject one local revision"


rejectOneRemoteButton : Element Msg
rejectOneRemoteButton =
    altButtonWithTitle 150 "Reject One Remote" (RejectOne RemoteSite) "Reject one remote revision"


setDocumentDirectoryButton : Element Msg
setDocumentDirectoryButton =
    button_ 170 "Set Document Directory" SetDocumentDirectory


setDownloadDirectoryButton : Element Msg
setDownloadDirectoryButton =
    button_ 170 "Set Download Directory" SetDownloadDirectory


setUserNameButton : Element Msg
setUserNameButton =
    button_ 170 "Set User Name" SetUserName_


serverStatus : Model -> Element Msg
serverStatus model =
    View.Helpers.showIf (model.fileLocation == FilesOnServer) (serverStatus_ model)


serverStatus_ : Model -> Element msg
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


saveFileToStorageButton : Model -> Element msg
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


closePopupButton : Element msg
closePopupButton =
    altButton "X" (ManagePopup PopupClosed) [ Font.size 14 ]


openPreferencesPopupButton : Model -> Element Msg
openPreferencesPopupButton model =
    case model.popupStatus of
        PopupOpen PreferencesPopup ->
            button_ 60 "Close" (ManagePopup PopupClosed)

        PopupOpen _ ->
            button_ 90 "Preferences" (ManagePopup PopupClosed)

        PopupClosed ->
            button_ 90 "Preferences" (ManagePopup (PopupOpen PreferencesPopup))


openFileListPopupButton : Model -> Element Msg
openFileListPopupButton model =
    case model.popupStatus of
        PopupOpen FileListPopup ->
            Button.make (ManagePopup PopupClosed) "Close"
                |> Button.withWidth (Bounded 60)
                |> Button.withSelected False
                |> Button.withBackgroundColor Style.redColor
                |> Button.toElement

        PopupOpen _ ->
            button "Files" (ManagePopup (PopupOpen FileListPopup)) []

        PopupClosed ->
            button "Files" (ManagePopup (PopupOpen FileListPopup)) []


openIndexButton : Model -> Element Msg
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


openFilePopupButton : Model -> Element Msg
openFilePopupButton model =
    case model.popupStatus of
        PopupOpen FilePopup ->
            Button.make (ManagePopup PopupClosed) "Close"
                |> Button.withWidth (Bounded 100)
                |> Button.withSelected False
                |> Button.withBackgroundColor Style.redColor
                |> Button.toElement

        PopupOpen _ ->
            button "info" (ManagePopup (PopupOpen FilePopup)) []

        PopupClosed ->
            button "Info " (ManagePopup (PopupOpen FilePopup)) []


openNewFilePopupButton : Model -> Element Msg
openNewFilePopupButton model =
    case model.popupStatus of
        PopupOpen NewFilePopup ->
            Button.make (ManagePopup PopupClosed) "Cancel"
                |> Button.withWidth (Bounded 90)
                |> Button.withSelected False
                |> Button.withBackgroundColor Style.redColor
                |> Button.toElement

        PopupOpen _ ->
            button "New" (ManagePopup (PopupOpen NewFilePopup)) []

        PopupClosed ->
            button "New" (ManagePopup (PopupOpen NewFilePopup)) []


importFileButton : Element Msg
importFileButton =
    button_ 60 "Import" GetFileToImport


exportFileButton : Element Msg
exportFileButton =
    button_ 60 "Export" SaveFile


publishFileButton : Element Msg
publishFileButton =
    button_ 60 "Publish" Publish


exportLaTeXFileButton : Model -> Element Msg
exportLaTeXFileButton model =
    case model.docType of
        MarkdownDoc ->
            Element.none

        MiniLaTeXDoc ->
            button_ 120 "LaTeX Export" ExportFile

        IndexDoc ->
            Element.none


newDocumentButton : Element Msg
newDocumentButton =
    button_ 70 "Create" CreateDocument


documentTypeButton : Model -> Element msg
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
    button
        title
        ToggleDocType
        [ Background.color Style.redColor
        , Element.htmlAttribute (Attribute.title "Cycle document type")
        ]


loadDocumentButton : Model -> String -> String -> Element msg
loadDocumentButton model docTitle buttonLabel =
    let
        bgColor =
            if model.docTitle == docTitle then
                Style.redColor
            else
                Style.grayColor
    in
    button buttonLabel LoadAboutDocument [ Background.color bgColor ]


button_ : Int -> String -> msg -> Element msg
button_ width str msg =
    Button.make msg str
        |> Button.withWidth (Bounded width)
        |> Button.withSelected False
        |> Button.toElement


buttonWithTitle : Int -> String -> msg -> String -> Element msg
buttonWithTitle width str msg title =
    Button.make msg str
        |> Button.withWidth (Bounded width)
        |> Button.withSelected False
        |> Button.withTitle title
        |> Button.toElement


altButtonWithTitle : Int -> String -> msg -> String -> Element msg
altButtonWithTitle width str msg title =
    Button.make msg str
        |> Button.withWidth (Bounded width)
        |> Button.withSelected False
        |> Button.withBackgroundColor Style.lightBlueColor
        |> Button.withTitle title
        |> Button.toElement


searchInput : Model -> Element Msg
searchInput model =
    input InputSearch model.searchText_ "" 300 0


input : (String -> msg) -> String -> String -> Int -> Int -> Element msg
input msg text label width labelWidth =
    TextField.make msg text label
        |> TextField.withHeight 30
        |> TextField.withWidth width
        |> TextField.withLabelWidth labelWidth
        |> TextField.toElement


button : String -> b -> List (Element.Attribute msg) -> Element msg
button str msg attr =
    Input.button
        ([ paddingXY 8 8
         , Background.color (Element.rgb255 90 90 100)
         ]
            ++ attr
        )
        { onPress = Just msg
        , label = el attr (text str)
        }


altButton : String -> b -> List (Element.Attribute msg) -> Element msg
altButton str msg attr =
    Input.button
        ([ paddingXY 8 8
         , Font.color (Element.rgb255 30 30 30)
         ]
            ++ attr
        )
        { onPress = Just msg
        , label = el attr (text str)
        }


plainButton : Int -> String -> c -> List (Element.Attribute msg) -> Element msg
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


textField : Int -> String -> (String -> msg) -> List (Html.Attribute a) -> List (Html.Attribute b) -> Html.Html c
textField width str msg attr innerAttr =
    Html.div (Attribute.style "margin-bottom" "10px" :: attr)
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
