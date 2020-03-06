module Helper.Sync exposing (onId, sync, syncAndHighlightRenderedText, syncModel)

import Array exposing (Array)
import Cmd.Extra exposing (withCmd)
import Editor exposing (Editor, EditorMsg)
import Markdown.Option exposing (MarkdownOption(..))
import Markdown.Parse
import Render
    exposing
        ( MDData
        , MLData
        , RenderingData(..)
        )
import Sync
import Tree.Diff
import Types exposing (DocType(..), Model, Msg(..))
import View.Scroll


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


syncAndHighlightRenderedText : String -> Cmd Msg -> Model -> ( Model, Cmd Msg )
syncAndHighlightRenderedText str cmd model =
    {- DOC sync RL -}
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

        idString =
            Sync.getId str2 data.sourceMap
                |> Maybe.withDefault "0v0"

        targetId =
            Sync.getIdFromString idString |> Maybe.withDefault ( 0, -1 )

        ( i, v ) =
            targetId

        newId =
            ( i, v + 1 )

        newRendingData =
            model.renderingData
                |> Render.incrementVersion targetId
                |> Render.updateFromAstWithId newId

        newIdString =
            Sync.stringFromId newId
    in
    ( { model | selectedId_ = idString, renderingData = newRendingData }
    , Cmd.batch [ cmd, View.Scroll.setViewportForElementInRenderedText newIdString ]
    )


syncAndHighlightRenderedMiniLaTeXText : String -> Cmd Msg -> Model -> MLData -> ( Model, Cmd Msg )
syncAndHighlightRenderedMiniLaTeXText str cmd model data =
    let
        id =
            Sync.getId str data.editRecord.sourceMap
                |> Maybe.withDefault "0v0"
    in
    ( model
    , Cmd.batch [ cmd, View.Scroll.setViewportForElementInRenderedText id ]
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


onId : String -> Model -> ( Model, Cmd Msg )
onId id model =
    {- DOC sync RL: (1) Given the id received after clicking on the rendered text,
       look up the corresponding text using a source map; (2) Use that text
        to find the index in the string array of the leading line of the paragraph
        corresponding to the leading leading line; (3) send that index to the
        Editor so that it can highlight/raise that line (or its paragraph)
    -}
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
    , Cmd.batch [ cmd |> Cmd.map EditorMsg, View.Scroll.setViewportForElementInRenderedText id ]
    )


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
