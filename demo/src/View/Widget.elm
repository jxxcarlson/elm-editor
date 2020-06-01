module View.Widget exposing
    ( aboutButton
    , askForRemoteDocumentsButton
    , button
    , cancelChangeFileNameButton
    , changeFileNameButton
    , closePopupButton
    , documentTypeButton
    , example1Button
    , exportFileButton
    , inputFileName
    , loadDocumentButton
    , newDocumentButton
    , openAuthorPopupButton
    , openFileButton
    , openFileListPopupButton
    , openRemoteFileListPopupButton
    , plainButton
    , saveFileButton
    , saveFileToLocalStorageButton
    , textField
    )

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
import Helper.File
import Html exposing (Attribute, Html)
import Html.Attributes as Attribute
import Html.Events as HE
import Types
    exposing
        ( DocType(..)
        , DocumentStatus(..)
        , Model
        , Msg(..)
        , PopupStatus(..)
        , PopupWindow(..)
        )
import View.Style as Style


inputFileName model =
    textField 180
        model.newFileName
        InputFileName
        []
        [ Attribute.style "height" "30px", Attribute.style "font-size" "14px" ]
        |> Element.html


example1Button =
    button 60 "Example 1" (AskForRemoteDocument "quantum.md") []


askForRemoteDocumentsButton =
    button 60 "Remote Files" AskForRemoteDocuments []


aboutButton =
    button 50 "About" About []


cancelChangeFileNameButton =
    button 90 "Cancel" CancelChangeFileName []


changeFileNameButton model =
    case
        ( Helper.File.fileExtension model.newFileName
        , String.length (Helper.File.titleFromFileName model.newFileName) > 0
        )
    of
        ( "md", True ) ->
            changeFileNameButton_ model

        ( "tex", True ) ->
            changeFileNameButton_ model

        ( _, _ ) ->
            doNotChangeFileNameButton


changeFileNameButton_ model =
    button 90 "Change file name" ChangeFileName []


doNotChangeFileNameButton =
    button 90 "Change file name" NoOp [ Font.color (Element.rgb 0.7 0.7 0.7) ]


saveFileToLocalStorageButton model =
    case model.documentStatus of
        DocumentDirty ->
            plainButton 20
                ""
                SaveFileToLocalStorage
                [ height (px 20)
                , Background.color (Element.rgb 0.55 0 0)
                ]

        DocumentSaved ->
            plainButton 20
                ""
                SaveFileToLocalStorage
                [ height (px 20)
                , Background.color (Element.rgb 0.0 0.7 0)
                ]


closePopupButton model =
    altButton 20 "X" (ManagePopup PopupClosed) [ Font.size 14 ]


openAuthorPopupButton model =
    case model.popupStatus of
        PopupOpen AuthorPopup ->
            button 90 "Close" (ManagePopup PopupClosed) []

        PopupOpen _ ->
            button 90 "Close" (ManagePopup PopupClosed) []

        PopupClosed ->
            button 90 "Author" (ManagePopup (PopupOpen AuthorPopup)) []


openFileListPopupButton model =
    case model.popupStatus of
        PopupOpen FileListPopup ->
            button 90 "Close" (ManagePopup PopupClosed) []

        PopupOpen _ ->
            button 90 "Close" (ManagePopup PopupClosed) []

        PopupClosed ->
            button 90 "Files" (ManagePopup (PopupOpen FileListPopup)) []


openRemoteFileListPopupButton model =
    case model.popupStatus of
        PopupOpen RemoteFileListPopup ->
            button 90 "Close" (ManagePopup PopupClosed) []

        PopupOpen _ ->
            button 90 "Close" (ManagePopup PopupClosed) []

        PopupClosed ->
            button 120 "Remote Files" (ManagePopup (PopupOpen RemoteFileListPopup)) []


openFileButton model =
    button 90 "Open" RequestFile []


saveFileButton model =
    button 90 "Save" SaveFile []


exportFileButton model =
    case model.docType of
        MarkdownDoc ->
            Element.none

        MiniLaTeXDoc ->
            button 90 "Export" ExportFile []


newDocumentButton model =
    button 90 "New" NewDocument []


documentTypeButton model =
    let
        title =
            case model.docType of
                MarkdownDoc ->
                    "Markdown"

                MiniLaTeXDoc ->
                    "LaTeX"
    in
    button width title ToggleDocType [ Background.color Style.redColor ]


loadDocumentButton model width docTitle buttonLabel =
    let
        bgColor =
            case model.docTitle == docTitle of
                True ->
                    Style.redColor

                False ->
                    Style.grayColor
    in
    button width buttonLabel (Load docTitle) [ Background.color bgColor ]


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
