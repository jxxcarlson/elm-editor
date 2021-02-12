module Main exposing (main)

--

import Browser
import Debounce exposing (Debounce)
import Editor exposing (Editor)
import EditorMsg
import Element exposing (Element, centerX, centerY, column, el, fill, px, row, text)
import Element.Background as Background
import Element.Font as Font
import Helper.File
import Helper.Load as Load
import Helper.Sync
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import MiniLatex.EditSimple
import Model exposing (..)
import Random
import Style.Element
import Task exposing (Task)
import Text
import UI exposing (..)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Flags =
    { seed : Int
    , width : Int
    , height : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        newEditor =
            Editor.initWithContent Text.start Load.config

        editRecord =
            MiniLatex.EditSimple.init flags.seed Text.start Nothing

        model =
            { windowWidth = flags.width
            , windowHeight = flags.height
            , editor = newEditor
            , sourceText = Text.start
            , macroText = ""
            , renderedText = MiniLatex.EditSimple.get "" editRecord |> Html.div [] |> Html.map LaTeXMsg
            , editRecord = editRecord
            , debounce = Debounce.init
            , counter = 0
            , seed = flags.seed
            , selectedId = ""
            , message = "No message yet ..."
            , images = []
            , imageUrl = ""
            , fileName = "mydocument.tex"
            }

        -- Editor.initWithContent Text.test1 Load.config
    in
    ( model, Cmd.none )



-- UPDATE


debounceConfig : Debounce.Config Msg
debounceConfig =
    { strategy = Debounce.later 250
    , transform = DebounceMsg
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- MyEditorMsg editorMsg ->
        --     let
        --         ( newEditor, cmd ) =
        --             Editor.update editorMsg model.editor
        --     in
        --     ( { model | editor = newEditor }, Cmd.map MyEditorMsg cmd )
        NoOp ->
            ( model, Cmd.none )

        GetContent str ->
            let
                ( debounce, cmd ) =
                    Debounce.push debounceConfig str model.debounce
            in
            ( { model
                | sourceText = str
                , debounce = debounce
              }
            , cmd
            )

        DebounceMsg msg_ ->
            let
                ( debounce, cmd ) =
                    Debounce.update
                        debounceConfig
                        (Debounce.takeLast render_)
                        msg_
                        model.debounce
            in
            ( { model | debounce = debounce }, cmd )

        GetMacroText str ->
            ( { model | macroText = str }, Cmd.none )

        Render str ->
            let
                n =
                    String.fromInt model.counter

                newEditRecord =
                    MiniLatex.EditSimple.update model.seed str Nothing model.editRecord
            in
            ( { model
                | editRecord = newEditRecord
                , renderedText = renderFromEditRecord model.selectedId model.counter newEditRecord
                , counter = model.counter + 2
              }
            , Random.generate NewSeed (Random.int 1 10000)
            )

        GenerateSeed ->
            ( model, Random.generate NewSeed (Random.int 1 10000) )

        NewSeed newSeed ->
            ( { model | seed = newSeed }, Cmd.none )

        Clear ->
            let
                editRecord =
                    MiniLatex.EditSimple.init 0 "" Nothing
            in
            ( { model
                | sourceText = ""
                , editRecord = editRecord
                , renderedText = renderFromEditRecord model.selectedId model.counter editRecord
                , counter = model.counter + 1
              }
            , Cmd.none
            )

        FullRender ->
            let
                editRecord =
                    MiniLatex.EditSimple.init model.seed model.sourceText Nothing
            in
            ( { model
                | counter = model.counter + 1
                , editRecord = editRecord
                , renderedText = renderFromEditRecord model.selectedId model.counter editRecord
              }
            , Cmd.none
            )

        RestoreText ->
            let
                editRecord =
                    MiniLatex.EditSimple.init model.seed Text.start Nothing
            in
            ( { model
                | counter = model.counter + 1
                , editRecord = editRecord
                , sourceText = Text.start
                , renderedText = MiniLatex.EditSimple.get "" editRecord |> Html.div [] |> Html.map LaTeXMsg
              }
            , Cmd.none
            )

        ExampleText ->
            let
                editRecord =
                    MiniLatex.EditSimple.init model.seed Text.start Nothing
            in
            ( { model
                | counter = model.counter + 1
                , editRecord = editRecord
                , sourceText = Text.start
                , renderedText = renderFromEditRecord model.selectedId model.counter editRecord
              }
            , Cmd.none
            )

        SetViewPortForElement result ->
            case result of
                Ok ( element, viewport ) ->
                    ( model, setViewPortForSelectedLine element viewport )

                Err _ ->
                    ( model, Cmd.none )

        LaTeXMsg laTeXMsg ->
            -- TODO: re-implement this
            ( model, Cmd.none )

        MyEditorMsg editorMsg ->
            -- Handle messages from the Editor.  The messages CopyPasteClipboard, ... GotViewportForSync
            -- require special handling.  The others are passed to a default handler
            let
                ( newEditor, cmd ) =
                    Editor.update editorMsg model.editor
            in
            case editorMsg of
                EditorMsg.InsertChar c ->
                    Helper.Sync.sync newEditor cmd model

                _ ->
                    -- Handle the default cases
                    if List.member msg (List.map MyEditorMsg Editor.syncMessages) then
                        Helper.Sync.sync newEditor cmd model

                    else
                        case editorMsg of
                            EditorMsg.Clear ->
                                ( { model | editor = newEditor, editRecord = MiniLatex.EditSimple.emptyData }, Cmd.map MyEditorMsg cmd )

                            _ ->
                                ( { model | editor = newEditor }, Cmd.map MyEditorMsg cmd )

        -- FILE I/O
        --ImportFile file ->
        --    ( { model | fileName = File.name file }, Helper.File.load file )
        Export ->
            ( model, Helper.File.export model )



--DocumentLoaded content ->
--     Update.Document.loadDocument content model
--SaveFile ->
--     ( model, Helper.File.save model )
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    Element.layoutWith { options = [ Element.focusStyle Style.Element.noFocus ] }
        [ Background.color (Style.Element.gray 0.4), Element.width fill, Element.height fill ]
    <|
        column [ centerY, centerX ]
            [ row [ Element.spacing 0 ]
                [ el [ Element.alignTop ] (viewEditor model)

                -- TODO: fix the below (round) --- (round Load.config.width)
                , el [ Element.alignTop ]
                    (UI.renderedSource
                        (Load.config.width - 40)
                        (Load.config.height + 22)
                        (render model.editRecord)
                    )
                ]
            , footer model
            ]


footer : Model -> Element Msg
footer model =
    row
        [ Element.spacing 12
        , Font.size 14
        , Element.height (px 30)
        , Element.width (px (model.windowWidth - 8))
        , Background.color (Style.Element.gray 0.2)
        , Font.color (Style.Element.gray 0.9)
        , Element.paddingXY 12 0
        ]
        [ UI.exportButton 100 ]


render : MiniLatex.EditSimple.Data -> Html Msg
render editRecord =
    editRecord
        |> MiniLatex.EditSimple.get ""
        |> Html.div []
        |> Html.map LaTeXMsg


viewEditor : Model -> Element Msg
viewEditor model =
    Editor.view model.editor |> Html.map MyEditorMsg |> Element.html



-- HELPERS


normalize : String -> String
normalize str =
    str |> String.lines |> List.filter (\x -> x /= "") |> String.join "\n"


prependMacros : String -> String -> String
prependMacros macros_ sourceText_ =
    "$$\n" ++ (macros_ |> normalize) ++ "\n$$\n\n" ++ sourceText_


renderFromEditRecord : String -> Int -> MiniLatex.EditSimple.Data -> Html Msg
renderFromEditRecord selectedId counter editRecord =
    MiniLatex.EditSimple.get selectedId editRecord
        |> List.map (Html.map LaTeXMsg)
        |> List.map (\x -> Html.div [ HA.style "margin-bottom" "0.65em" ] [ x ])
        |> Html.div []


render_ : String -> Cmd Msg
render_ str =
    Task.perform Render (Task.succeed str)
