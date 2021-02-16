module Helper.Update exposing (..)

import Array
import Debounce exposing (Debounce)
import Editor exposing (Editor)
import EditorMsg
import File
import File.Select as Select
import Helper.Sync
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import MiniLatex.EditSimple
import Model exposing (..)
import Random
import Task exposing (Task)
import UI exposing (..)
import Umuli


getContent model str =
    let
        ( debounce, cmd ) =
            Debounce.push debounceConfig str model.debounce
    in
    ( { model
        | debounce = debounce
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

        newData =
            Umuli.update model.counter str Nothing model.data

        renderedText : Html Msg
        renderedText =
            Umuli.render "" newData |> Html.div [] |> Html.map Umuli
    in
    ( { model
        | data = newData
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
        content =
            Editor.getLines model.editor
                |> Array.toList
                |> String.join "\n"

        newData =
            Umuli.init (umuliLang model.documentType) model.counter content Nothing
    in
    ( { model
        | counter = model.counter + 1
        , data = newData
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
    , Select.file [ "text/tex", "text/md", "text/md" ] FileSelected
    )


fileSelected model fileName file =
    ( { model | fileName = fileName }
    , Task.perform FileLoaded (File.toString file)
    )


loadEmpty : Int -> Model -> Model
loadEmpty n model =
    let
        content =
            String.repeat n "\n"

        fileName =
            "doc" ++ fileExtension model.documentType
    in
    load fileName content model


loadDocument : String -> String -> Model -> Model
loadDocument fileName content model =
    let
        newEditor =
            Editor.initWithContent content model.config

        documentType =
            findDocumentType fileName

        data =
            Umuli.init (umuliLang documentType) model.counter content Nothing
    in
    { model
        | editor = newEditor
        , documentType = documentType
        , data = data
        , fileName = fileName
        , counter = model.counter + 1
    }


load : String -> String -> Model -> Model
load fileName content model =
    let
        docType =
            findDocumentType fileName

        newEditor =
            Editor.initWithContent content model.config

        documentType =
            findDocumentType fileName

        data =
            Umuli.init (umuliLang docType) model.counter content Nothing
    in
    { model
        | editor = newEditor
        , documentType = documentType
        , data = data
        , counter = model.counter + 1
    }


findDocumentType : String -> DocumentType
findDocumentType fileName =
    let
        parts =
            String.split "." fileName

        mExtensionName =
            List.head (List.reverse parts)
    in
    case mExtensionName of
        Just "tex" ->
            MiniLaTeX

        Just "md" ->
            MathMarkdown

        Just "txt" ->
            PlainText

        _ ->
            PlainText


load_ fileName content model =
    ( load fileName content model, Cmd.none )


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
                        ( load (fileExtension model.documentType) (String.repeat 40 "\n") model
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
