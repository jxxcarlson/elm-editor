module View.FileListPopup exposing (prettify, view)

import Data
import Document exposing (DocType(..), Metadata)
import Element
    exposing
        ( Element
        , alignRight
        , column
        , el
        , height
        , padding
        , paddingXY
        , px
        , row
        , scrollbarY
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Helper.Common
import Types exposing (FileLocation(..), HandleIndex(..), Model, Msg(..), PopupStatus(..), PopupWindow(..), SearchOptions(..))
import View.Helpers
import View.Style as Style
import View.Widget as Widget


view : Model -> Element Msg
view model =
    case model.popupStatus of
        PopupClosed ->
            Element.none

        PopupOpen FileListPopup ->
            let
                filesToDisplay =
                    case model.searchOptions of
                        ExcludeDeleted ->
                            model.fileList |> prepareFileList model.searchText_ "deleted"

                        ShowDeleted ->
                            model.fileList |> prepareFileList model.searchText_ "___"

                        ShowDeletedOnly ->
                            model.fileList |> prepareFileList "deleted" "___"

                n =
                    List.length filesToDisplay |> String.fromInt

                userName =
                    case model.preferences of
                        Nothing ->
                            "noUserName"

                        Just prefs ->
                            prefs.userName ++ "."

                documentDirectoryPhrase =
                    case Maybe.map .documentDirectory model.preferences of
                        Nothing ->
                            "Local files"

                        Just path ->
                            View.Helpers.shortPath 2 path

                url =
                    model.serverURL
                        |> String.replace "https://" ""
                        |> String.replace "http://" ""
                        |> String.split ":"
                        |> List.head
                        |> Maybe.withDefault "Server"

                title =
                    case model.fileLocation of
                        FilesOnDisk ->
                            documentDirectoryPhrase ++ " (" ++ n ++ ")"

                        FilesOnServer ->
                            "Documents at " ++ url ++ " (" ++ n ++ ")"

                metadataOfCurrentDocument =
                    case model.currentDocument of
                        Nothing ->
                            Data.dummyMetaData

                        Just doc ->
                            Document.toMetadata doc
            in
            column
                [ width (px 570)
                , height (px <| round <| Helper.Common.windowHeight model.height + 28)
                , paddingXY 30 30
                , Background.color (Element.rgba 1.0 0.75 0.75 0.8)
                , spacing 16
                ]
                [ row [ width (px 450), spacing 8 ] [ text title, Widget.serverStatus model, el [ alignRight ] Widget.closePopupButton ]
                , Widget.searchInput model
                , column
                    [ spacing 8
                    , height (px 400)
                    , scrollbarY
                    , padding 8
                    , Border.width 1
                    , Border.color Style.lightGrayColor
                    ]
                    (filesToDisplay |> List.map (viewFileName model.searchOptions userName metadataOfCurrentDocument))
                , row [] [ Widget.searchOptionsButton model ]
                ]

        PopupOpen _ ->
            Element.none


prepareFileList : String -> String -> List Metadata -> List Metadata
prepareFileList yesKey noKey fileList =
    fileList
        |> List.filter (\metadata -> predicate yesKey noKey metadata)
        |> List.sortBy .fileName


predicate yesKey noKey metadata =
    String.contains yesKey metadata.fileName && not (String.contains noKey metadata.fileName)


viewFileName : SearchOptions -> String -> Metadata -> Metadata -> Element Msg
viewFileName searchOptions userName metaDataOfCurrentDocument metadata =
    row [ spacing 8 ]
        [ documentLinkButton searchOptions userName metaDataOfCurrentDocument metadata
        , View.Helpers.showIf (metadata.docType == IndexDoc) (editIndexButton metadata.fileName)
        , View.Helpers.showIf (metadata.docType /= IndexDoc) placeholder
        , deleteDocumentButton searchOptions metadata
        ]


deleteDocumentButton : SearchOptions -> Metadata -> Element Msg
deleteDocumentButton searchOptions metadata =
    let
        msg =
            if List.member searchOptions [ ShowDeletedOnly, ShowDeleted ] then
                HardDelete metadata.fileName
            else
                SoftDelete metadata
    in
    el [ Element.padding 2, Background.color (Element.rgba 0.7 0.3 0.3 0.5) ]
        (Widget.plainButton 55
            "delete"
            msg
            []
        )


documentLinkButton : SearchOptions -> String -> Metadata -> Metadata -> Element Msg
documentLinkButton searchOptions userName metaDataOfCurrentDocument metadata =
    let
        bgColor =
            if metaDataOfCurrentDocument.id == metadata.id then
                Background.color (Element.rgba 0.7 0.7 1.0 0.5)
            else
                Background.color (Element.rgba 0 0 0 0)

        buttonTitle =
            if searchOptions == ExcludeDeleted then
                prettify userName metadata.fileName
            else
                metadata.fileName
    in
    Widget.plainButton 350
        buttonTitle
        (GetDocument UseIndex metadata.fileName)
        [ Font.color (Element.rgb 0 0 0.9), bgColor, Element.padding 2 ]


editIndexButton : String -> Element Msg
editIndexButton fileName =
    Widget.plainButton 90
        "Edit index"
        (GetDocument EditIndex fileName)
        [ Font.color (Element.rgb 0 0 0.9), Element.padding 2 ]


placeholder : Element Msg
placeholder =
    Element.el [ width (px 90) ] (text "")


prettify : String -> String -> String
prettify userName str =
    if List.length (String.split "-" str) > 2 then
        prettify_ userName str

    else
        str |> String.replace userName ""


prettify_ : String -> String -> String
prettify_ userName str =
    let
        parts =
            String.split "-" str

        n =
            List.length parts

        a =
            List.take (n - 2) parts
                |> String.join "-"

        b_ =
            List.drop (n - 1) parts
                |> List.head
                |> Maybe.withDefault "???"

        b =
            b_
                |> String.split "."
                |> List.drop 1
                |> List.head
                |> Maybe.withDefault "???"
    in
    a ++ "." ++ b |> String.replace userName ""
