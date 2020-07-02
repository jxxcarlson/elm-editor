module Helper.Sync exposing
    ( onId
    , sync
    , syncAndHighlightRenderedText
    , syncModel
    , syncModel2
    )

import Array exposing (Array)
import Cmd.Extra exposing (withCmd)
import Document exposing (DocType(..), Document)
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
import Types exposing (DocumentStatus(..), Model, Msg(..))
import UuidHelper
import View.Scroll


sync : Editor -> Cmd EditorMsg -> Model -> ( Model, Cmd Msg )
sync newEditor cmd model =
    model
        |> updateRenderingData (Editor.getLines newEditor)
        |> updateDocument newEditor
        |> (\m -> { m | editor = newEditor, documentStatus = DocumentDirty })
        |> withCmd (Cmd.map EditorMsg cmd)


syncModel : Editor -> Model -> Model
syncModel newEditor model =
    model
        |> updateRenderingData (Editor.getLines newEditor)
        |> updateDocument newEditor
        |> (\m -> { m | editor = newEditor })


syncModel2 : Model -> Model
syncModel2 model =
    model
        |> updateRenderingData (Editor.getLines model.editor)
        |> updateDocument model.editor


updateDocument : Editor -> Model -> Model
updateDocument editor model =
    case model.currentDocument of
        Nothing ->
            model

        Just doc ->
            { model | currentDocument = Just { doc | content = Editor.getContent editor } }



--case model.document.id == "1234" || model.document.id == "" of
--    False ->
--        { model | document = updateDocument_ editor model.document }
--
--    True ->
--        { model | document = updateDocumentWithUuid_ model.uuid editor model.document }
--            |> UuidHelper.newUuid
--updateDocumentWithUuid_ : String -> Editor -> Document -> Document
--updateDocumentWithUuid_ uuid editor document =
--    { document | content = Editor.getContent editor, id = uuid }
--
--updateDocument_ : Editor -> Document -> Document
--updateDocument_ editor document =
--    { document | content = Editor.getContent editor }


syncAndHighlightRenderedText : String -> Cmd Msg -> Model -> ( Model, Cmd Msg )
syncAndHighlightRenderedText str cmd model =
    {- DOC sync RL and LR (4) -}
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

        newRenderingData =
            model.renderingData
                |> Render.incrementVersion targetId
                |> Render.updateFromAstWithId newId

        newIdString =
            Sync.stringFromId newId
    in
    ( { model | selectedId_ = newIdString, renderingData = newRenderingData }
    , Cmd.batch [ cmd, View.Scroll.setViewportForElementInRenderedText newIdString ]
    )


syncAndHighlightRenderedMiniLaTeXText : String -> Cmd Msg -> Model -> MLData -> ( Model, Cmd Msg )
syncAndHighlightRenderedMiniLaTeXText str cmd model data =
    let
        idString : String
        idString =
            Sync.getId str data.editRecord.sourceMap
                |> Maybe.withDefault "0v0"

        idStringSelected =
            "select:" ++ idString
    in
    ( { model | selectedId_ = idString }
    , Cmd.batch [ cmd, View.Scroll.setViewportForElementInRenderedText idStringSelected ]
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
    case getIndexAndText id model of
        Just indices ->
            case List.head indices of
                Nothing ->
                    ( { model | message = "Clicked: (" ++ id ++ " (sync error [2])" }, Cmd.none )

                Just index ->
                    let
                        ( newEditor, cmd ) =
                            Editor.sendLine (Editor.setCursor { line = index, column = 0 } model.editor)
                    in
                    ( { model | editor = newEditor, message = "Clicked: (" ++ id ++ ", " ++ String.fromInt (index + 1) ++ ")" }
                    , Cmd.batch [ cmd |> Cmd.map EditorMsg, View.Scroll.setViewportForElementInRenderedText id ]
                    )

        Nothing ->
            ( { model | message = "Clicked: (" ++ id ++ " (sync error [2])" }, Cmd.none )


getIndexAndText : String -> Model -> Maybe (List Int)
getIndexAndText id model =
    case model.renderingData of
        MD data ->
            Sync.getText id data.sourceMap
                |> Maybe.map (shorten 5)
                |> Maybe.map (Editor.indexOf model.editor)

        ML data ->
            Sync.getText id data.editRecord.sourceMap
                |> Maybe.andThen leadingLine
                |> Maybe.map (Editor.indexOf model.editor)



-- TODO: issue command to sync id and line


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
