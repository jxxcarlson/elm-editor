module View.Widget exposing
    ( aboutButton
    , button
    , cancelChangeMetadataButton
    , cancelSignInButton
    , changeMetadataButton
    , closePopupButton
    , createAuthorButton
    , documentTypeButton
    , exportFileButton
    , exportLaTeXFileButton
    , importFileButton
    , loadDocumentButton
    , newDocumentButton
    , openAuthorPopupButton
    , openFileListPopupButton
    , openFilePopupButton
    , openNewFilePopupButton
    , plainButton
    , saveFileToStorageButton
    , setDocumentDirectoryButton
    , setUserNameButton
    , signInButton
    , signOutButton
    , signUpButton
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
        , Model
        , Msg(..)
        , PopupStatus(..)
        , PopupWindow(..)
        )
import View.Style as Style
import Widget.Button as Button exposing (Size(..))



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


toggleFileLocationButton model =
    case model.fileLocation of
        LocalFiles ->
            button_ 60 "Local" (ToggleFileLocation RemoteFiles)

        RemoteFiles ->
            button_ 60 "Remote" (ToggleFileLocation LocalFiles)


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

        ( _, _ ) ->
            doNotChangeMetadataButton


changeMetadataButton_ fileName =
    button_ 70 "Change" (ChangeMetadata fileName)


doNotChangeMetadataButton =
    button_ 70 "Change" (ManagePopup PopupClosed)



-- [ Font.color (Element.rgb 0.7 0.7 0.7) ]


setDocumentDirectoryButton =
    button_ 170 "Set Document Directory" SetDocumentDirectory


setUserNameButton =
    button_ 170 "Set User Name" SetUserName_


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
                SaveFileToStorage
                [ height (px 20)
                , Background.color (Element.rgb 0.0 0.7 0)
                , Element.htmlAttribute (Attribute.title "Save file (its OK now)")
                ]


closePopupButton model =
    altButton 20 "X" (ManagePopup PopupClosed) [ Font.size 14 ]


openAuthorPopupButton model =
    case model.popupStatus of
        PopupOpen AuthorPopup ->
            button_ 60 "Close" (ManagePopup PopupClosed)

        PopupOpen _ ->
            button_ 60 "Author" (ManagePopup PopupClosed)

        PopupClosed ->
            button_ 60 "Author" (ManagePopup (PopupOpen AuthorPopup))


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


openFilePopupButton model =
    case model.popupStatus of
        PopupOpen FilePopup ->
            Button.make (ManagePopup PopupClosed) "Close"
                |> Button.withWidth (Bounded 100)
                |> Button.withSelected False
                |> Button.withBackgroundColor Style.redColor
                |> Button.toElement

        PopupOpen _ ->
            button 100 "File info" (ManagePopup (PopupOpen FilePopup)) []

        PopupClosed ->
            button 100 "File info" (ManagePopup (PopupOpen FilePopup)) []


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
    button_ 60 "Import" RequestFile


exportFileButton model =
    button_ 60 "Export" SaveFile


exportLaTeXFileButton model =
    case model.docType of
        MarkdownDoc ->
            Element.none

        MiniLaTeXDoc ->
            button_ 120 "LaTeX Export" ExportFile


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
