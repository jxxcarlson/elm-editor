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
import Markdown.ElmWithId
import Markdown.Option exposing (Option(..))
import Markdown.Parse
import Model exposing (Msg(..))
import Render exposing (MDData, MLData, RenderingData(..), RenderingOption(..))
import Style
import Sync
import Task exposing (Task)
import Tree.Diff


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
    , renderingData : RenderingData Msg
    , counter : Int
    , width : Float
    , height : Float
    , docTitle : String
    , docType : DocType
    , fileName : Maybe String
    , selectedId : ( Int, Int )
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
    | SyncLR


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
    , message = ""
    }
        |> Cmd.Extra.withCmds
            [ Dom.focus "editor" |> Task.attempt (always NoOp)
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

        _ ->
            model


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
                , editor = Editor.initWithContent source (config { width = model.width, height = model.height })
                , docTitle = title
                , docType = MarkdownDoc
            }

        MiniLaTeXDoc ->
            let
                renderingData =
                    Render.load ( 0, 0 ) model.counter OMiniLatex source

                fileName =
                    title ++ ".tex"
            in
            { model
                | renderingData = renderingData
                , fileName = Just fileName
                , counter = model.counter + 1
                , editor = Editor.initWithContent source (config { width = model.width, height = model.height })
                , docTitle = title
                , docType = MiniLaTeXDoc
            }


config flags =
    { width = proportions.width * flags.width
    , height = proportions.height * (flags.height - 40)
    , fontSize = 16
    , verticalScrollOffset = 3
    , debugOn = False
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ ContextMenu.subscriptions (Editor.getContextMenu model.editor)
            |> Sub.map ContextMenuMsg
            |> Sub.map EditorMsg
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
                    ( { model | message = "synced" }, setViewPortForSelectedLineInRenderedText verticalOffsetInRenderedText element viewport )

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

                                "tex" ->
                                    MiniLaTeXDoc

                                _ ->
                                    MarkdownDoc
                    in
                    loadDocument fileName source docType model
                        |> (\m -> { m | docType = docType })
                        |> withCmds [ scrollRendredTextToTop, scrollEditorToTop ]

        SaveFile ->
            ( model, saveFile model )

        SyncLR ->
            let
                ( newEditor, cmd ) =
                    Editor.sendLine model.editor
            in
            ( { model | editor = newEditor }, Cmd.map EditorMsg cmd )



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
        , loadDocumentButton model 50 "markdownExample" "Sample"
        , loadDocumentButton model 50 "mathExample" "Math"
        , loadDocumentButton model 50 "astro" "Astro"
        ]


latexDocumentLoader model =
    row [ spacing 12 ]
        [ el [] (text "LaTeX Docs: ")
        , loadDocumentButton model 50 "aboutMiniLaTeX" "About"
        , loadDocumentButton model 50 "miniLaTeXExample" "Sample"
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
        ]
        [ showIf (model.docType == MarkdownDoc) ((Render.get model.renderingData).title |> Element.html)
        , (Render.get model.renderingData).document |> Element.html
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
    Select.file [ "text/markdown" ] RequestedFile


saveFile : Model -> Cmd msg
saveFile model =
    case ( model.docType, model.fileName ) of
        ( MarkdownDoc, Just fileName ) ->
            Download.string fileName "text/markdown" (Editor.getContent model.editor)

        ( MiniLaTeXDoc, Just fileName ) ->
            Download.string fileName "text/tex" (Editor.getContent model.editor)

        ( _, _ ) ->
            Cmd.none



-- HELPERS: LOAD, RENDER, SYNC


syncAndHighlightRenderedText : String -> Cmd Msg -> Model -> ( Model, Cmd Msg )
syncAndHighlightRenderedText str cmd model =
    case ( model.docType, model.renderingData ) of
        ( MarkdownDoc, MD data ) ->
            syncAndHighlightRenderedMarkdownText str cmd model data

        ( MiniLaTeXDoc, ML data ) ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


syncAndHighlightRenderedMarkdownText : String -> Cmd Msg -> Model -> MDData msg -> ( Model, Cmd Msg )
syncAndHighlightRenderedMarkdownText str cmd model data =
    -- TODO: make this work
    let
        str2 =
            Markdown.Parse.toMDBlockTree 0 ExtendedMath str
                |> Markdown.Parse.getLeadingTextFromAST

        id_ =
            Sync.get str2 data.sourceMap
                |> Maybe.withDefault "0v0"

        id : ( Int, Int )
        id =
            Markdown.Parse.idFromString id_
                |> (\( id__, version ) -> ( id__, version ))
    in
    ( -- processMarkdownContentForHighlighting (Editor.getContent model.editor) data { model | selectedId = id }
      { model | selectedId = id }
    , Cmd.batch [ cmd, setViewportForElement (Markdown.Parse.stringFromId id) ]
    )


processMarkdownContentForHighlighting : String -> MDData msg -> Model -> Model
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

        newRenderingData : RenderingData Msg
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


load : Int -> ( Int, Int ) -> RenderingOption -> String -> RenderingData Msg
load counter selectedId renderingOption str =
    Render.load selectedId counter renderingOption str



-- SCROLLING


setViewportForElement : String -> Cmd Msg
setViewportForElement id =
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


setViewPortForSelectedLineInRenderedText : Float -> Dom.Element -> Dom.Viewport -> Cmd Msg
setViewPortForSelectedLineInRenderedText offset element viewport =
    let
        y =
            viewport.viewport.y + element.element.y - verticalOffsetInRenderedText
    in
    Task.attempt (\_ -> NoOp) (Dom.setViewportOf "__RENDERED_TEXT__" 0 y)


verticalOffsetInRenderedText =
    160
