module View.FileListPopup exposing (prettify, view)

import Document exposing (DocType(..), Metadata)
import Element
    exposing
        ( Element
        , alignRight
        , column
        , el
        , height
        , paddingXY
        , px
        , row
        , scrollbarY
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Element.Font as Font
import Helper.Common
import Types exposing (FileLocation(..), HandleIndex(..), Model, Msg(..), PopupStatus(..), PopupWindow(..))
import View.Helpers
import View.Widget as Widget


view : Model -> Element Msg
view model =
    case model.popupStatus of
        PopupClosed ->
            Element.none

        PopupOpen FileListPopup ->
            let
                filesToDisplay =
                    model.fileList |> prepareFileList model.searchText_

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

                title =
                    case model.fileLocation of
                        FilesOnDisk ->
                            documentDirectoryPhrase ++ " (" ++ n ++ ")"

                        FilesOnServer ->
                            "Remote Files (" ++ n ++ ")"

                metadataOfCurrentDocument =
                    Document.toMetadata model.document
            in
            column
                [ width (px 570)
                , height (px <| round <| Helper.Common.windowHeight model.height + 28)
                , paddingXY 30 30
                , Background.color (Element.rgba 1.0 0.75 0.75 0.8)
                , spacing 16
                ]
                [ row [ width (px 450) ] [ text title, el [ alignRight ] Widget.closePopupButton ]
                , Widget.searchInput model
                , column
                    [ spacing 8
                    , height (px 400)
                    , scrollbarY
                    ]
                    (filesToDisplay |> List.map (viewFileName userName metadataOfCurrentDocument))
                ]

        PopupOpen _ ->
            Element.none


prepareFileList : String -> List Metadata -> List Metadata
prepareFileList searchKey fileList =
    fileList
        |> List.filter (\r -> not (String.contains "deleted" r.fileName))
        |> List.filter (\r -> String.contains searchKey r.fileName)
        |> List.sortBy .fileName


viewFileName : String -> Metadata -> Metadata -> Element Msg
viewFileName userName metaDataOfCurrentDocument metadata =
    row [ spacing 8 ]
        [ documentLinkButton userName metaDataOfCurrentDocument metadata
        , View.Helpers.showIf (metadata.docType == IndexDoc) (editIndexButton metadata)
        , View.Helpers.showIf (metadata.docType /= IndexDoc) placeholder
        , deleteDocumentButton metadata
        ]


deleteDocumentButton : Metadata -> Element Msg
deleteDocumentButton metadata =
    el [ Element.padding 2, Background.color (Element.rgba 0.7 0.3 0.3 0.5) ]
        (Widget.plainButton 55
            "delete"
            (SoftDelete metadata)
            []
        )


documentLinkButton : String -> Metadata -> Metadata -> Element Msg
documentLinkButton userName metaDataOfCurrentDocument metadata =
    let
        bgColor =
            case metaDataOfCurrentDocument.id == metadata.id of
                True ->
                    Background.color (Element.rgba 0.7 0.7 1.0 0.5)

                False ->
                    Background.color (Element.rgba 0 0 0 0)
    in
    Widget.plainButton 350
        (prettify userName metadata.fileName)
        (GetDocument UseIndex metadata.fileName)
        [ Font.color (Element.rgb 0 0 0.9), bgColor, Element.padding 2 ]


editIndexButton : Metadata -> Element Msg
editIndexButton metadata =
    Widget.plainButton 90
        "Edit index"
        (GetDocument EditIndex metadata.fileName)
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
