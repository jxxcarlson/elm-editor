module Helper.Update exposing (..)

import Debounce exposing (Debounce)
import Editor exposing (Editor)
import EditorMsg
import File
import File.Select as Select
import Helper.Load as Load
import Helper.Sync
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import MiniLatex.EditSimple
import Model exposing (..)
import Random
import Task exposing (Task)
import Text
import UI exposing (..)


getContent model str =
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


debounceMsg model msg_ =
    let
        ( debounce, cmd ) =
            Debounce.update
                debounceConfig
                (Debounce.takeLast render_)
                msg_
                model.debounce
    in
    ( { model | debounce = debounce }, cmd )


render model str =
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


clear model =
    let
        text_ =
            String.repeat 40 "x\n"

        newEditor =
            Editor.setCursor { line = 0, column = 0 } (Editor.initWithContent text_ model.config)

        editRecord =
            MiniLatex.EditSimple.init 0 text_ Nothing
    in
    ( { model
        | sourceText = text_
        , editRecord = editRecord
        , editor = newEditor
        , renderedText = renderFromEditRecord model.selectedId model.counter editRecord
        , counter = model.counter + 1
      }
    , Cmd.none
    )


fullRender model =
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


exampleText model =
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


restoreText model =
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


setViewPortForElement model result =
    case result of
        Ok ( element, viewport ) ->
            ( model, setViewPortForSelectedLine element viewport )

        Err _ ->
            ( model, Cmd.none )


fileRequested model =
    ( model
    , Select.file [ "text/tex" ] FileSelected
    )


fileSelected model file =
    ( { model | fileName = File.name file }
    , Task.perform FileLoaded (File.toString file)
    )


loadEmpty : Int -> Model -> Model
loadEmpty n model =
    let
        content =
            String.repeat n "\n"
    in
    load content model


load : String -> Model -> Model
load content model =
    let
        newEditor =
            Editor.initWithContent content model.config

        editRecord =
            MiniLatex.EditSimple.init model.counter content Nothing
    in
    { model
        | sourceText = content
        , editor = newEditor
        , editRecord = editRecord
        , counter = model.counter + 1
    }


load_ content model =
    ( load content model, Cmd.none )


{-| }
Handle messages from the Editor. The messages CopyPasteClipboard, ... GotViewportForSync
require special handling. The others are passed to a default handler
-}
handleEditorMsg model msg editorMsg =
    let
        ( newEditor, cmd ) =
            Editor.update editorMsg model.editor
    in
    case editorMsg of
        EditorMsg.InsertChar c ->
            Helper.Sync.sync newEditor cmd model

        EditorMsg.ToggleShortCutExecution ->
            Helper.Sync.sync newEditor cmd model

        _ ->
            -- Handle the default cases
            if List.member msg (List.map MyEditorMsg Editor.syncMessages) then
                Helper.Sync.sync newEditor cmd model

            else
                case editorMsg of
                    EditorMsg.Clear ->
                        ( load (String.repeat 40 "\n") model
                        , Cmd.map MyEditorMsg cmd
                        )

                    _ ->
                        ( { model | editor = newEditor }, Cmd.map MyEditorMsg cmd )



-- HELPERS


debounceConfig : Debounce.Config Msg
debounceConfig =
    { strategy = Debounce.later 250
    , transform = DebounceMsg
    }


render_ : String -> Cmd Msg
render_ str =
    Task.perform Render (Task.succeed str)


renderFromEditRecord : String -> Int -> MiniLatex.EditSimple.Data -> Html Msg
renderFromEditRecord selectedId counter editRecord =
    MiniLatex.EditSimple.get selectedId editRecord
        |> List.map (Html.map LaTeXMsg)
        |> List.map (\x -> Html.div [ HA.style "margin-bottom" "0.65em" ] [ x ])
        |> Html.div []
