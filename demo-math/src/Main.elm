module Main exposing (main)

import Browser
import Editor exposing (Editor)
import Element exposing (Element, row, column, el, height, px, text)
import Helpers.Load as Load
import Html exposing (Html)
import Http
import Text
--
import Debounce exposing (Debounce)
import MiniLatex
import MiniLatex.Edit exposing (Data)
import MiniLatex.Export
import Browser.Dom as Dom
import Style exposing(..)
import Random
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events exposing (onClick, onInput)
import UI exposing(..)
import Msg exposing(..)
import Task exposing(Task)
import File.Download as Download


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


-- MODEL


type alias Model =
    { editor : Editor
    , sourceText : String
    , renderedText : Html Msg
    , macroText : String
    , editRecord : Data (Html MiniLatex.Edit.LaTeXMsg)
    , debounce : Debounce String
    , counter : Int
    , seed : Int
    , selectedId : String
    , message : String
    , images : List String
    , imageUrl : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        newEditor =
            Editor.initWithContent (Text.numbered Text.start) Load.config


        editRecord =
            MiniLatex.Edit.init flags.seed Text.start

        model =
            { editor = newEditor
            , sourceText = Text.start
            , macroText = ""
            , renderedText = render "" Text.start
            , editRecord = editRecord
            , debounce = Debounce.init
            , counter = 0
            , seed = flags.seed
            , selectedId = ""
            , message = "No message yet ..."
            , images = []
            , imageUrl = ""
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
        MyEditorMsg editorMsg ->
            let
                ( newEditor, cmd ) =
                    Editor.update editorMsg model.editor
            in
            ( { model | editor = newEditor }, Cmd.map MyEditorMsg cmd )

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
                    MiniLatex.Edit.update model.seed str model.editRecord
            in
            ( { model
                | editRecord = newEditRecord
                , renderedText = renderFromEditRecord model.selectedId model.counter newEditRecord
                , counter = model.counter + 2
              }
            , Random.generate NewSeed (Random.int 1 10000)
            )

        Export ->
            let
                ( contentForExport, images ) =
                    model.sourceText |> MiniLatex.Export.toLaTeXWithImages
            in
            ( { model | images = images }, Download.string "mydocument.tex" "text/x-tex" contentForExport )

        GenerateSeed ->
            ( model, Random.generate NewSeed (Random.int 1 10000) )

        NewSeed newSeed ->
            ( { model | seed = newSeed }, Cmd.none )

        Clear ->
            let
                editRecord =
                    MiniLatex.Edit.init 0 ""
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
                    MiniLatex.Edit.init model.seed model.sourceText
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
                    MiniLatex.Edit.init model.seed Text.start
            in
            ( { model
                | counter = model.counter + 1
                , editRecord = editRecord
                , sourceText = Text.start
                , renderedText = renderFromEditRecord model.selectedId model.counter editRecord
              }
            , Cmd.none
            )

        ExampleText ->
            let
                editRecord =
                    MiniLatex.Edit.init model.seed Text.start
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
            case laTeXMsg of
                MiniLatex.Edit.IDClicked id ->
                    ( { model
                        | message = "Clicked: " ++ id
                        , selectedId = id
                        , counter = model.counter + 2
                        , renderedText = renderFromEditRecord id model.counter model.editRecord
                      }
                    , Cmd.none
                    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    Element.layout [] <|
        column []
            [ row [] [
                  el [] (viewEditor model)
                , renderedSource model.renderedText |> Element.html
                ]
            ]


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


renderFromEditRecord : String -> Int -> Data (Html MiniLatex.Edit.LaTeXMsg) -> Html Msg
renderFromEditRecord selectedId counter editRecord =
    MiniLatex.Edit.get selectedId editRecord
        |> List.map (Html.map LaTeXMsg)
        |> List.map (\x -> Html.div [ HA.style "margin-bottom" "0.65em" ] [ x ])
        |> Html.div []


render_ : String -> Cmd Msg
render_ str =
    Task.perform Render (Task.succeed str)


render : String -> String -> Html Msg
render selectedId sourceText_ =
    MiniLatex.render selectedId sourceText_ |> Html.map LaTeXMsg

