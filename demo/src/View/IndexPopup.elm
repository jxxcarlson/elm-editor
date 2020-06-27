module View.IndexPopup exposing (view)

import Document exposing (Metadata)
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
import Index
import Types exposing (FileLocation(..), Model, Msg(..), PopupStatus(..), PopupWindow(..))
import View.Widget as Widget


view : Model -> Element Msg
view model =
    case model.popupStatus of
        PopupClosed ->
            Element.none

        PopupOpen IndexPopup ->
            let
                userName =
                    case model.preferences of
                        Nothing ->
                            "noUserName"

                        Just prefs ->
                            prefs.userName ++ "."
            in
            Index.view model.height userName model.fileName model.index

        PopupOpen _ ->
            Element.none


prepareFileList : List Metadata -> List Metadata
prepareFileList fileList =
    fileList
        |> List.filter (\r -> not (String.contains "deleted" r.fileName))
        |> List.sortBy .fileName


viewFileName : String -> Metadata -> Metadata -> Element Msg
viewFileName userName metaDataOfCurrentDocument metadata =
    let
        bgColor =
            case metaDataOfCurrentDocument.id == metadata.id of
                True ->
                    Background.color (Element.rgba 0.7 0.7 1.0 0.5)

                False ->
                    Background.color (Element.rgba 0 0 0 0)
    in
    row [ spacing 8 ]
        [ Widget.plainButton 350
            (prettify userName metadata.fileName)
            (GetDocument metadata.fileName)
            [ Font.color (Element.rgb 0 0 0.9), bgColor, Element.padding 2 ]
        , el [ Element.padding 2, Background.color (Element.rgba 0.7 0.3 0.3 0.5) ]
            (Widget.plainButton 55
                "delete"
                (SoftDelete metadata)
                []
            )
        ]


prettify : String -> String -> String
prettify userName str =
    let
        parts =
            String.split "-" str
    in
    case List.length parts == 3 of
        False ->
            String.replace userName "" str

        True ->
            let
                a =
                    List.take 1 parts
                        |> List.head
                        |> Maybe.withDefault "???"

                b =
                    parts
                        |> List.drop 2
                        |> List.map (String.split ".")
                        |> List.concat
                        |> List.drop 1
                        |> List.head
                        |> Maybe.withDefault "???"
            in
            a ++ "." ++ b |> String.replace userName ""
