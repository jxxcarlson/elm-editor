module View.FilePopup exposing (view, infoPanel, changePanel, item, inputItem, titleLine, fileInput, fileNameInput)

import Document exposing (Document)
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
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Element.Font as Font
import Helper.Common
import Types exposing (Model, Msg(..), PopupStatus(..), PopupWindow(..))
import View.Widget as Widget
import Widget.TextField as TextField exposing (LabelPosition(..))


view : Model -> Element Msg
view model =
    case ( model.popupStatus, model.currentDocument ) of
        ( PopupClosed, _ ) ->
            Element.none

        ( _, Nothing ) ->
            Element.none

        ( PopupOpen FilePopup, Just doc ) ->
            column
                [ width (px 500)
                , height (px <| round <| Helper.Common.windowHeight model.height + 28)
                , paddingXY 30 30
                , Background.color (Element.rgba 1.0 0.75 0.75 0.8)
                , spacing 24
                ]
                [ titleLine doc
                , column [ spacing 36 ]
                    [ infoPanel doc
                    , changePanel model
                    ]
                ]

        ( PopupOpen _, _ ) ->
            Element.none


infoPanel : Document -> Element msg
infoPanel doc =
    column [ spacing 12 ]
        [ item "id" doc.id
        , item "Author" doc.author
        , item "Created" (Helper.Common.dateStringFromPosix doc.timeCreated)
        , item "Modified" (Helper.Common.dateStringFromPosix doc.timeUpdated)
        , item "Synced" (Helper.Common.maybeDateStringFromPosix doc.timeSynced)
        , item "DocType" (Document.stringOfDocType doc.docType)
        ]


changePanel : Model -> Element Msg
changePanel model =
    column [ spacing 12 ]
        [ inputItem "File name" InputFileName model.fileName_ 300
        , inputItem "Tags" InputTags model.tags_ 300
        , inputItem "Categories" InputCategories model.categories_ 300
        , inputItem "Title" InputTitle model.title_ 300
        , inputItem "Subtitle" InputSubtitle model.subtitle_ 300
        , inputItem "Belongs to" InputBelongsTo model.belongsTo_ 300
        , row [ spacing 12 ]
            [ Widget.changeMetadataButton model.fileName_
            , Widget.cancelChangeMetadataButton
            ]
        , item "Message" model.message
        ]


item : String -> String -> Element msg
item label str =
    row [ Font.size 14, spacing 12 ]
        [ el [ Font.bold, width (px 65) ] (el [ alignRight ] (text label))
        , el [] (text str)
        ]


inputItem : String -> (String -> Msg) -> String -> Int -> Element Msg
inputItem label msg inputText width_ =
    row [ Font.size 14, spacing 12 ]
        [ el [ Font.bold, width (px 65) ] (el [ alignRight ] (text label))
        , fileInput msg inputText "" width_
        ]


titleLine : Document -> Element Msg
titleLine doc =
    row [ width (px 450) ] [ text ("File info: " ++ doc.fileName), el [ alignRight ] Widget.closePopupButton ]


fileInput : (String -> Msg) -> String -> String -> Int -> Element Msg
fileInput msg text label width_ =
    TextField.make msg text label
        |> TextField.withHeight 30
        |> TextField.withWidth width_
        |> TextField.withLabelWidth 0
        |> TextField.withLabelPosition LabelLeft
        |> TextField.toElement


fileNameInput : Model -> Int -> Element Msg
fileNameInput model =
    fileInput InputFileName model.fileName_ ""
