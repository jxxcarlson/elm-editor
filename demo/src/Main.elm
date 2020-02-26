module Main exposing (main)

import Array exposing (Array)
import Browser
import Browser.Dom as Dom
import Browser.Events
import Cmd.Extra exposing (withCmd, withCmds)
import ContextMenu exposing (Item(..))
import Data
import Editor exposing (Editor, EditorMsg)
import Element
    exposing
        ( Element
        , alignRight
        , centerX
        , centerY
        , column
        , el
        , fill
        , height
        , padding
        , paddingXY
        , px
        , rgb255
        , row
        , scrollbarY
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import File exposing (File)
import File.Download as Download
import File.Select as Select
import Html exposing (Attribute, Html)
import Html.Attributes as Attribute
import Html.Events as HE
import Json.Encode
import Markdown.Option exposing (..)
import Markdown.Parse
import Markdown.Render exposing (MarkdownMsg(..))
import MiniLatex.Edit as MLE
import MiniLatex.Export
import Model exposing (Msg(..))
import Outside
import Render exposing (MDData, MLData, RenderingData(..), RenderingOption(..))
import Render.Types exposing (RenderMsg(..))
import Style
import Sync
import Task exposing (Task)
import Tree.Diff
import Update.Function
import Wrap exposing (WrapOption(..))


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



-- MODEL


type alias Model =
    { editor : Editor
    , renderingData : RenderingData
    , counter : Int
    , width : Float
    , height : Float
    , docTitle : String
    , docType : DocType
    , fileName : Maybe String
    , selectedId : ( Int, Int )
    , selectedId_ : String
    , message : String
    }


type DocType
    = MarkdownDoc
    | MiniLaTeXDoc


proportions : { width : Float, height : Float }
proportions =
    { width = 0.35, height = 0.8 }



-- MSG


type Msg
    = NoOp
    | EditorMsg Editor.EditorMsg
    | WindowSize Int Int
    | Load String
    | ToggleDocType
    | NewDocument
    | SetViewPortForElement (Result Dom.Error ( Dom.Element, Dom.Viewport ))
    | RequestFile
    | RequestedFile File
    | DocumentLoaded String
    | SaveFile
    | ExportFile
    | SyncLR
    | Outside Outside.InfoForElm
    | LogErr String
    | RenderMsg RenderMsg


init : Flags -> ( Model, Cmd Msg )
init flags =
    { editor = Editor.initWithContent Data.about (config flags)
    , renderingData = load 0 ( 0, 0 ) (OMarkdown ExtendedMath) Data.about
    , counter = 1
    , width = flags.width
    , height = flags.height
    , docTitle = "about"
    , docType = MarkdownDoc
    , fileName = Just "about.md"
    , selectedId = ( 0, 0 )
    , selectedId_ = ""
    , message = ""
    }
        |> Cmd.Extra.withCmds
            [ Dom.focus "editor" |> Task.attempt (always NoOp)
            , scrollEditorToTop
            , scrollRendredTextToTop
            ]


loadDocumentByTitle : String -> Model -> Model
loadDocumentByTitle docTitle model =
    case docTitle of
        "about" ->
            loadDocument docTitle Data.about MarkdownDoc model

        "markdownExample" ->
            loadDocument docTitle Data.markdownExample MarkdownDoc model

        "mathExample" ->
            loadDocument docTitle Data.mathExample MarkdownDoc model

        "astro" ->
            loadDocument docTitle Data.astro MarkdownDoc model

        "aboutMiniLaTeX" ->
            loadDocument docTitle Data.aboutMiniLaTeX MiniLaTeXDoc model

        "miniLaTeXExample" ->
            loadDocument docTitle Data.miniLaTeXExample MiniLaTeXDoc model

        "aboutMiniLaTeX2" ->
            loadDocument docTitle Data.aboutMiniLaTeX2 MiniLaTeXDoc model

        _ ->
            model


titleFromFileName : String -> String
titleFromFileName fileName =
    fileName
        |> String.split "."
        |> List.reverse
        |> List.drop 1
        |> List.reverse
        |> String.join "."


loadDocument : String -> String -> DocType -> Model -> Model
loadDocument title source docType model =
    case docType of
        MarkdownDoc ->
            let
                renderingData =
                    Render.load ( 0, 0 ) model.counter (OMarkdown ExtendedMath) source

                fileName =
                    title ++ ".md"
            in
            { model
                | renderingData = renderingData
                , fileName = Just fileName
                , counter = model.counter + 1
                , editor =
                    Editor.initWithContent source
                        (config { width = model.width, height = model.height, wrapOption = DontWrap })
                , docTitle = title
                , docType = MarkdownDoc
            }

        MiniLaTeXDoc ->
            let
                renderingData =
                    Render.load ( 0, 0 ) model.counter OMiniLatex source

                fileName =
                    title ++ ".latex"
            in
            { model
                | renderingData = renderingData
                , fileName = Just fileName
                , counter = model.counter + 1
                , editor =
                    Editor.initWithContent source
                        (config { width = model.width, height = model.height, wrapOption = DontWrap })
                , docTitle = title
                , docType = MiniLaTeXDoc
            }


config flags =
    { width = proportions.width * flags.width
    , height = proportions.height * (flags.height - 40)
    , fontSize = 16
    , verticalScrollOffset = 3
    , debugOn = False
    , wrapOption = DontWrap
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ ContextMenu.subscriptions (Editor.getContextMenu model.editor)
            |> Sub.map ContextMenuMsg
            |> Sub.map EditorMsg
        , Outside.getInfo Outside LogErr
        , Browser.Events.onResize WindowSize
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        EditorMsg editorMsg ->
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
                        |> syncModel newEditor
                        |> withCmds [ clipBoardCmd, Cmd.map EditorMsg cmd ]

                WriteToSystemClipBoard ->
                    ( { model | editor = newEditor }, Outside.sendInfo (Outside.WriteToClipBoard (Editor.getSelectedString newEditor |> Maybe.withDefault "Nothing!!")) )

                Unload _ ->
                    sync newEditor cmd model

                InsertChar _ ->
                    sync newEditor cmd model

                MarkdownLoaded _ ->
                    sync newEditor cmd model

                SendLine ->
                    syncAndHighlightRenderedText (Editor.lineAtCursor newEditor) (Cmd.map EditorMsg cmd) { model | editor = newEditor }

                GotViewportForSync currentLine _ _ ->
                    case currentLine of
                        Nothing ->
                            ( model, Cmd.none )

                        Just str ->
                            syncAndHighlightRenderedText str Cmd.none model

                _ ->
                    case List.member msg (List.map EditorMsg Editor.syncMessages) of
                        True ->
                            sync newEditor cmd model

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
                , editor = Editor.resize (proportions.width * w) (proportions.height * h) model.editor
              }
            , Cmd.none
            )

        Load title ->
            loadDocumentByTitle title model
                |> withCmd (Cmd.batch [ scrollEditorToTop, scrollRendredTextToTop ])

        ToggleDocType ->
            let
                newDocType =
                    case model.docType of
                        MarkdownDoc ->
                            MiniLaTeXDoc

                        MiniLaTeXDoc ->
                            MarkdownDoc
            in
            ( { model | docType = newDocType }, Cmd.none )

        NewDocument ->
            case model.docType of
                MarkdownDoc ->
                    loadDocument "newFile" "" MarkdownDoc model
                        |> withCmd (Cmd.batch [ scrollEditorToTop, scrollRendredTextToTop ])

                MiniLaTeXDoc ->
                    loadDocument "newFile" "" MiniLaTeXDoc model
                        |> withCmd (Cmd.batch [ scrollEditorToTop, scrollRendredTextToTop ])

        SetViewPortForElement result ->
            case result of
                Ok ( element, viewport ) ->
                    ( { model | message = "synced" }, setViewPortForSelectedLineInRenderedText element viewport )

                Err _ ->
                    ( { model | message = "sync error" }, Cmd.none )

        RequestFile ->
            ( model, requestFile )

        RequestedFile file ->
            ( { model | fileName = Just (File.name file) }, read file )

        DocumentLoaded source ->
            case model.fileName of
                Nothing ->
                    ( model, Cmd.none )

                Just fileName ->
                    let
                        docType =
                            case fileExtension fileName of
                                "md" ->
                                    MarkdownDoc

                                "latex" ->
                                    MiniLaTeXDoc

                                _ ->
                                    MarkdownDoc
                    in
                    loadDocument (titleFromFileName fileName) source docType model
                        |> (\m -> { m | docType = docType })
                        |> withCmds [ scrollRendredTextToTop, scrollEditorToTop ]

        SaveFile ->
            ( model, saveFile model )

        ExportFile ->
            ( model, exportFile model )

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

        LogErr _ ->
            ( model, Cmd.none )

        RenderMsg renderMsg ->
            case renderMsg of
                LaTeXMsg latexMsg ->
                    case latexMsg of
                        MLE.IDClicked id ->
                            syncOnId id model

                MarkdownMsg markdownMsg ->
                    case markdownMsg of
                        IDClicked id ->
                            syncOnId id model


syncOnId : String -> Model -> ( Model, Cmd Msg )
syncOnId id model =
    let
        ( index, line ) =
            case model.renderingData of
                MD data ->
                    Sync.getText id data.sourceMap
                        |> Maybe.map (shorten 5)
                        |> Maybe.andThen (Editor.indexOf model.editor)
                        |> Maybe.withDefault ( -1, "error" )

                ML data ->
                    Sync.getText id data.editRecord.sourceMap
                        |> Maybe.andThen leadingLine
                        |> Maybe.andThen (Editor.indexOf model.editor)
                        |> Maybe.withDefault ( -1, "error" )

        ( newEditor, cmd ) =
            Editor.sendLine (Editor.setCursor { line = index, column = 0 } model.editor)
    in
    -- TODO: issue command to sync id and line
    ( { model | editor = newEditor, message = "Clicked: (" ++ id ++ ", " ++ String.fromInt (index + 1) ++ ")" }
    , Cmd.batch [ cmd |> Cmd.map EditorMsg, setViewportForElementInRenderedText id ]
    )



-- scrollEditorToLine model index


shorten : Int -> String -> String
shorten n str =
    str
        |> String.words
        |> List.take n
        |> String.join " "


leadingLine : String -> Maybe String
leadingLine str =
    str
        |> String.lines
        |> List.filter goodLine
        |> List.head


goodLine str =
    not
        (String.contains "$$" str
            || String.contains "\\begin" str
            || String.contains "\\end" str
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



-- VIEW


view : Model -> Html Msg
view model =
    Element.layout [ Background.color <| gray 10 ]
        (mainColumn model)


mainColumn model =
    column [ centerX, centerY ]
        [ column []
            [ viewEditorAndRenderedText model
            , viewFooter model model.width 40
            , viewFooter2 model model.width 40
            ]
        ]


viewEditorAndRenderedText model =
    row []
        [ viewEditor model
        , viewRenderedText
            model
            (proportions.width * model.width - 40)
            (proportions.height * model.height + 40)
        ]


viewFooter model width_ height_ =
    row
        [ width (pxFloat (2 * proportions.width * width_ - 40))
        , height (pxFloat height_)
        , Background.color (Element.rgb255 130 130 140)
        , Font.color (gray 240)
        , Font.size 14
        , paddingXY 10 0
        , Element.moveUp 19
        , spacing 12
        ]
        [ documentTypeButton model
        , newDocumentButton model
        , openFileButton model
        , saveFileButton model
        , exportFileButton model
        , displayFilename model
        , syncLRButton model
        , el [ alignRight, width (px 100) ] (text model.message)
        ]


syncLRButton model =
    button 50 "Sync L > R" SyncLR [ alignRight ]


separator model width_ height_ =
    row
        [ width (pxFloat (2 * proportions.width * width_ - 40))
        , height (pxFloat height_)
        , Background.color (gray 200)
        , Element.moveUp 19
        ]
        []


viewFooter2 model width_ height_ =
    row
        [ width (pxFloat (2 * proportions.width * width_ - 40))
        , height (pxFloat height_)
        , Background.color (Element.rgb255 80 80 90)
        , Font.color (gray 240)
        , Font.size 14
        , paddingXY 10 0
        , Element.moveUp 19
        , spacing 36
        ]
        [ markdownDocumentLoader model
        , latexDocumentLoader model
        ]


displayFilename : Model -> Element Msg
displayFilename model =
    let
        message =
            case model.fileName of
                Nothing ->
                    "No file"

                Just fn ->
                    "File: " ++ fn
    in
    el [] (text message)


markdownDocumentLoader model =
    row [ spacing 12 ]
        [ el [] (text "Markdown Docs: ")
        , loadDocumentButton model 50 "about" "About"
        , loadDocumentButton model 50 "markdownExample" "M1"
        , loadDocumentButton model 50 "mathExample" "M2"
        , loadDocumentButton model 50 "astro" "M3"
        ]


latexDocumentLoader model =
    row [ spacing 12 ]
        [ el [] (text "LaTeX Docs: ")
        , loadDocumentButton model 50 "aboutMiniLaTeX" "About"
        , loadDocumentButton model 50 "aboutMiniLaTeX2" "L1"
        , loadDocumentButton model 50 "miniLaTeXExample" "L2"
        ]


gray g =
    rgb255 g g g


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
        , Background.color <| gray 240

        -- , Element.htmlAttribute (Attribute.id model.selectedId_ (Html.style "background-color" "#cce"))
        ]
        [ showIf (model.docType == MarkdownDoc)
            ((Render.get model.renderingData).title |> Html.map RenderMsg |> Element.html)
        , (Render.get model.renderingData).document |> Html.map RenderMsg |> Element.html
        ]


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



-- BUTTONS


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



-- FILE I/O


fileExtension : String -> String
fileExtension str =
    str |> String.split "." |> List.reverse |> List.head |> Maybe.withDefault "md"


read : File -> Cmd Msg
read file =
    Task.perform DocumentLoaded (File.toString file)


requestFile : Cmd Msg
requestFile =
    Select.file [ "text/markdown", "application/x-latex" ] RequestedFile


saveFile : Model -> Cmd msg
saveFile model =
    case ( model.docType, model.fileName ) of
        ( MarkdownDoc, Just fileName ) ->
            Download.string fileName "text/markdown" (Editor.getContent model.editor)

        ( MiniLaTeXDoc, Just fileName ) ->
            Download.string fileName "application/x-latex" (Editor.getContent model.editor)

        ( _, _ ) ->
            Cmd.none


exportFile : Model -> Cmd msg
exportFile model =
    case ( model.docType, model.fileName ) of
        ( MarkdownDoc, Just fileName ) ->
            Cmd.none

        ( MiniLaTeXDoc, Just fileName ) ->
            let
                contentForExport =
                    Editor.getContent model.editor |> MiniLatex.Export.toLaTeX
            in
            Download.string fileName "application/x-latex" contentForExport

        ( _, _ ) ->
            Cmd.none



-- HELPERS: LOAD, RENDER, SYNC


syncAndHighlightRenderedText : String -> Cmd Msg -> Model -> ( Model, Cmd Msg )
syncAndHighlightRenderedText str cmd model =
    case ( model.docType, model.renderingData ) of
        ( MarkdownDoc, MD data ) ->
            syncAndHighlightRenderedMarkdownText str cmd model data

        ( MiniLaTeXDoc, ML data ) ->
            syncAndHighlightRenderedMiniLaTeXText str cmd model data

        _ ->
            ( model, Cmd.none )


syncAndHighlightRenderedMarkdownText : String -> Cmd Msg -> Model -> MDData -> ( Model, Cmd Msg )
syncAndHighlightRenderedMarkdownText str cmd model data =
    let
        str2 =
            Markdown.Parse.toMDBlockTree 0 ExtendedMath str
                |> Markdown.Parse.getLeadingTextFromAST

        id_ =
            Sync.getId str2 data.sourceMap
                |> Maybe.withDefault "0v0"
    in
    ( { model | selectedId_ = id_ }
    , Cmd.batch [ cmd, setViewportForElementInRenderedText id_ ]
    )


syncAndHighlightRenderedMiniLaTeXText : String -> Cmd Msg -> Model -> MLData -> ( Model, Cmd Msg )
syncAndHighlightRenderedMiniLaTeXText str cmd model data =
    let
        id =
            Sync.getId str data.editRecord.sourceMap
                |> Maybe.withDefault "0v0"
    in
    ( model
    , Cmd.batch [ cmd, setViewportForElementInRenderedText id ]
    )


processMarkdownContentForHighlighting : String -> MDData -> Model -> Model
processMarkdownContentForHighlighting str data model =
    let
        newAst_ =
            Markdown.Parse.toMDBlockTree model.counter ExtendedMath str

        newAst =
            Tree.Diff.mergeWith Markdown.Parse.equalIds data.fullAst newAst_
    in
    { model
        | counter = model.counter + 1
    }


updateRenderingData : Array String -> Model -> Model
updateRenderingData lines model =
    let
        source =
            lines |> Array.toList |> String.join "\n"

        counter =
            model.counter + 1

        newRenderingData =
            Render.update ( 0, 0 ) counter source model.renderingData
    in
    { model | renderingData = newRenderingData, counter = counter }


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


sync : Editor -> Cmd EditorMsg -> Model -> ( Model, Cmd Msg )
sync newEditor cmd model =
    model
        |> updateRenderingData (Editor.getLines newEditor)
        |> (\m -> { m | editor = newEditor })
        |> withCmd (Cmd.map EditorMsg cmd)


syncModel : Editor -> Model -> Model
syncModel newEditor model =
    model
        |> updateRenderingData (Editor.getLines newEditor)
        |> (\m -> { m | editor = newEditor })


load : Int -> ( Int, Int ) -> RenderingOption -> String -> RenderingData
load counter selectedId renderingOption str =
    Render.load selectedId counter renderingOption str



-- SCROLLING


setViewportForElementInRenderedText : String -> Cmd Msg
setViewportForElementInRenderedText id =
    Dom.getViewportOf "__RENDERED_TEXT__"
        |> Task.andThen (\vp -> getElementWithViewPort vp id)
        |> Task.attempt SetViewPortForElement


scrollEditorToTop =
    scrollToTopForElement "__editor__"


scrollRendredTextToTop =
    scrollToTopForElement "__RENDERED_TEXT__"


scrollToTopForElement : String -> Cmd Msg
scrollToTopForElement id =
    Task.attempt (\_ -> NoOp) (Dom.setViewportOf id 0 0)


getElementWithViewPort : Dom.Viewport -> String -> Task Dom.Error ( Dom.Element, Dom.Viewport )
getElementWithViewPort vp id =
    Dom.getElement id
        |> Task.map (\el -> ( el, vp ))


setViewPortForSelectedLineInRenderedText : Dom.Element -> Dom.Viewport -> Cmd Msg
setViewPortForSelectedLineInRenderedText element viewport =
    let
        y =
            viewport.viewport.y + element.element.y - verticalOffsetInRenderedText
    in
    Task.attempt (\_ -> NoOp) (Dom.setViewportOf "__RENDERED_TEXT__" 0 y)


scrollEditorToLine : Model -> Int -> Cmd Msg
scrollEditorToLine model line =
    let
        y =
            Editor.getLineHeight model.editor * toFloat line - verticalOffsetInRenderedText
    in
    Task.attempt (\_ -> NoOp) (Dom.setViewportOf "__editor__" 0 y)


verticalOffsetInRenderedText =
    140
