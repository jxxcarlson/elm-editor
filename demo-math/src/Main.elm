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
import Helper.Update
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GetContent str ->
            Helper.Update.getContent model str

        DebounceMsg msg_ ->
            Helper.Update.debounceMsg model msg_

        GetMacroText str ->
            ( { model | macroText = str }, Cmd.none )

        Render str ->
            Helper.Update.render model str

        GenerateSeed ->
            ( model, Random.generate NewSeed (Random.int 1 10000) )

        NewSeed newSeed ->
            ( { model | seed = newSeed }, Cmd.none )

        Clear ->
            Helper.Update.clear model

        FullRender ->
            Helper.Update.fullRender model

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
            Helper.Update.exampleText model

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
