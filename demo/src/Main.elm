module Main exposing (main)

import Array exposing (Array)
import Browser
import Browser.Dom as Dom
import Browser.Events
import Cmd.Extra exposing (withCmd)
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
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Html.Events as HE
import Markdown.Option exposing (Option(..))
import Model exposing (Msg(..))
import Render exposing (RenderingData, RenderingOption(..))
import Style
import Task


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


type alias Model =
    { editor : Editor
    , renderingData : RenderingData Msg
    , counter : Int
    , width : Float
    , height : Float
    , docTitle : String
    , docType : DocType
    }


type DocType
    = MarkdownDoc
    | MiniLaTeXDoc


proportions : { width : Float, height : Float }
proportions =
    { width = 0.35, height = 0.8 }


type Msg
    = NoOp
    | EditorMsg Editor.EditorMsg
    | WindowSize Int Int
    | Load String


init : Flags -> ( Model, Cmd Msg )
init flags =
    { editor = Editor.initWithContent Data.about (config flags)
    , renderingData = load 0 ( 0, 0 ) (OMarkdown ExtendedMath) Data.about
    , counter = 1
    , width = flags.width
    , height = flags.height
    , docTitle = "about"
    , docType = MarkdownDoc
    }
        |> Cmd.Extra.withCmds
            [ Dom.focus "editor" |> Task.attempt (always NoOp)
            ]


loadDocument : String -> Model -> ( Model, Cmd Msg )
loadDocument docTitle model =
    case docTitle of
        "about" ->
            ( loadDocument_ docTitle MarkdownDoc Data.about model, Cmd.none )

        "markdownExample" ->
            ( loadDocument_ docTitle MarkdownDoc Data.markdownExample model, Cmd.none )

        "mathExample" ->
            ( loadDocument_ docTitle MarkdownDoc Data.mathExample model, Cmd.none )

        "astro" ->
            ( loadDocument_ docTitle MarkdownDoc Data.astro model, Cmd.none )

        _ ->
            ( model, Cmd.none )


loadDocument_ : String -> DocType -> String -> Model -> Model
loadDocument_ title docType source model =
    case docType of
        MarkdownDoc ->
            let
                renderingData =
                    Render.load ( 0, 0 ) model.counter (OMarkdown ExtendedMath) source
            in
            { model
                | renderingData = renderingData
                , counter = model.counter + 1
                , editor = Editor.initWithContent source (config { width = model.width, height = model.height })
                , docTitle = title
                , docType = MarkdownDoc
            }

        MiniLaTeXDoc ->
            let
                renderingData =
                    Render.load ( 0, 0 ) model.counter OMiniLatex source
            in
            { model
                | renderingData = renderingData
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
            loadDocument title model



-- VIEW


view : Model -> Html Msg
view model =
    Element.layout []
        (mainColumn model)


mainColumn model =
    column [ centerX, centerY ]
        [ column []
            [ viewEditorAndRenderedText model
            , viewFooter model model.width 40
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
        , Background.color (Element.rgb255 130 130 150)
        , Font.color (gray 240)
        , Font.size 14
        , paddingXY 10 0
        , Element.moveUp 19
        , spacing 12
        ]
        [ loadDocumentButton model 50 "about" "About"
        , loadDocumentButton model 70 "markdownExample" "Markdown"
        , loadDocumentButton model 50 "mathExample" "Math"
        , loadDocumentButton model 50 "astro" "Astro"
        ]


gray g =
    rgb255 g g g


viewEditor model =
    Editor.view model.editor |> H.map EditorMsg |> Element.html


viewRenderedText : Model -> Float -> Float -> Element Msg
viewRenderedText model width_ height_ =
    column
        [ scrollbarY
        , width (pxFloat width_)
        , height (pxFloat height_)
        , Font.size 14
        , Element.htmlAttribute (HA.style "line-height" "20px")
        , paddingXY 14 0
        , Border.width 1
        ]
        [ (Render.get model.renderingData).title |> Element.html
        , (Render.get model.renderingData).document |> Element.html
        ]


pxFloat : Float -> Element.Length
pxFloat p =
    px (round p)



-- BUTTONS


loadDocumentButton model width docTitle buttonLabel =
    let
        bgColor =
            case model.docTitle == docTitle of
                True ->
                    Element.rgb255 150 40 40

                False ->
                    Element.rgb255 90 90 100
    in
    button width buttonLabel (Load docTitle) [ Background.color bgColor ]


button width str msg attr =
    Input.button
        ([ Border.width 1
         , Border.color (gray 200)
         , paddingXY 8 8
         , Background.color (Element.rgb255 90 90 100)
         ]
            ++ attr
        )
        { onPress = Just msg
        , label = el attr (text str)
        }


textField width str msg attr innerAttr =
    H.div ([ HA.style "margin-bottom" "10px" ] ++ attr)
        [ H.input
            ([ HA.style "height" "18px"
             , HA.style "width" (String.fromInt width ++ "px")
             , HA.type_ "text"
             , HA.placeholder str
             , HA.style "margin-right" "8px"
             , HE.onInput msg
             ]
                ++ innerAttr
            )
            []
        ]


rowButtonStyle =
    [ HA.style "font-size" "12px"
    , HA.style "border" "none"
    ]


rowButtonLabelStyle width =
    [ HA.style "font-size" "12px"
    , HA.style "background-color" "#666"
    , HA.style "color" "#eee"
    , HA.style "width" (String.fromInt width ++ "px")
    , HA.style "height" "24px"
    , HA.style "border" "none"
    ]


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
