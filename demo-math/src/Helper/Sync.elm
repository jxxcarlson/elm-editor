module Helper.Sync exposing (sync)

import Array exposing (Array)
import Cmd.Extra exposing (withCmd)
import Editor exposing (Editor, EditorMsg)
import MiniLatex.EditSimple
import Model exposing (Model, Msg)
import Umuli


sync : Editor -> Cmd EditorMsg -> Model -> ( Model, Cmd Msg )
sync newEditor cmd model =
    model
        |> updateRenderingData (Editor.getLines newEditor)
        -- |> updateDocument newEditor
        |> (\m -> { m | editor = newEditor })
        |> withCmd (Cmd.map Model.MyEditorMsg cmd)


updateRenderingData : Array String -> Model -> Model
updateRenderingData lines model =
    let
        source : String
        source =
            lines |> Array.toList |> String.join "\n"

        counter : Int
        counter =
            model.counter + 1

        newData =
            Umuli.update model.counter source Nothing model.data
    in
    { model | data = newData, counter = counter }



-- update :  Int -> String -> MiniLatex.EditSimple.Data -> MiniLatex.EditSimple.Data
-- update version source data =
--      MiniLatex.EditSimple.update version source data
-- updateDocument : Editor -> Model -> Model
-- updateDocument editor model =
--     case model.currentDocument of
--         Nothing ->
--             model
--         Just doc ->
--             { model | currentDocument = Just { doc | content = Editor.getContent editor } }
-- syncModel : Editor -> Model -> Model
-- syncModel newEditor model =
--     model
--         |> updateRenderingData (Editor.getLines newEditor)
--         |> updateDocument newEditor
--         |> (\m -> { m | editor = newEditor })
-- syncModel2 : Model -> Model
-- syncModel2 model =
--     model
--         |> updateRenderingData (Editor.getLines model.editor)
--         |> updateDocument model.editor
-- updateDocument : Editor -> Model -> Model
-- updateDocument editor model =
--     case model.currentDocument of
--         Nothing ->
--             model
--         Just doc ->
--             { model | currentDocument = Just { doc | content = Editor.getContent editor } }
-- syncAndHighlightRenderedText : String -> Cmd Msg -> Model -> ( Model, Cmd Msg )
-- syncAndHighlightRenderedText str cmd model =
--     {- DOC sync RL and LR (4) -}
--     case ( model.docType, model.renderingData ) of
--         ( MarkdownDoc, MD data ) ->
--             syncAndHighlightRenderedMarkdownText str cmd model data
--         ( MiniLaTeXDoc, ML data ) ->
--             syncAndHighlightRenderedMiniLaTeXText str cmd model data
--         _ ->
--             ( model, Cmd.none )
-- syncAndHighlightRenderedMiniLaTeXText : String -> Cmd Msg -> Model -> MLData -> ( Model, Cmd Msg )
-- syncAndHighlightRenderedMiniLaTeXText str cmd model data =
--     let
--         idString : String
--         idString =
--             Sync.getId str data.editRecord.sourceMap
--                 |> Maybe.withDefault "0v0"
--         idStringSelected =
--             "select:" ++ idString
--     in
--     ( { model | selectedId_ = idString }
--     , Cmd.batch [ cmd, View.Scroll.setViewportForElementInRenderedText idStringSelected ]
--     )
-- updateRenderingData : Array String -> Model -> Model
-- updateRenderingData lines model =
--     let
--         source =
--             lines |> Array.toList |> String.join "\n"
--         counter =
--             model.counter + 1
--         newRenderingData =
--             Render.update ( 0, 0 ) counter source model.renderingData
--     in
--     { model | renderingData = newRenderingData, counter = counter }
-- onId : String -> Model -> ( Model, Cmd Msg )
-- onId id model =
--     {- DOC sync RL: (1) Given the id received after clicking on the rendered text,
--        look up the corresponding text using a source map; (2) Use that text
--         to find the index in the string array of the leading line of the paragraph
--         corresponding to the leading leading line; (3) send that index to the
--         Editor so that it can highlight/raise that line (or its paragraph)
--     -}
--     case getIndexAndText id model of
--         Just indices ->
--             case List.head indices of
--                 Nothing ->
--                     ( { model | message = "Clicked: (" ++ id ++ " (sync error [2])" }, Cmd.none )
--                 Just index ->
--                     let
--                         ( newEditor, cmd ) =
--                             Editor.sendLine (Editor.setCursor { line = index, column = 0 } model.editor)
--                     in
--                     ( { model | editor = newEditor, message = "Clicked: (" ++ id ++ ", " ++ String.fromInt (index + 1) ++ ")" }
--                     , Cmd.batch [ cmd |> Cmd.map EditorMsg, View.Scroll.setViewportForElementInRenderedText id ]
--                     )
--         Nothing ->
--             ( { model | message = "Clicked: (" ++ id ++ " (sync error [2])" }, Cmd.none )
-- getIndexAndText : String -> Model -> Maybe (List Int)
-- getIndexAndText id model =
--     Sync.getText id  model.renderingData.editRecord.sourceMap
--         |> Maybe.andThen leadingLine
--         |> Maybe.map (Editor.indexOf model.editor)
-- -- TODO: issue command to sync id and line
-- shorten : Int -> String -> String
-- shorten n str =
--     str
--         |> String.words
--         |> List.take n
--         |> String.join " "
-- leadingLine : String -> Maybe String
-- leadingLine str =
--     str
--         |> String.lines
--         |> List.filter goodLine
--         |> List.head
-- goodLine : String -> Bool
-- goodLine str =
--     not
--         (String.contains "$$" str
--             || String.contains "\\begin" str
--             || String.contains "\\end" str
--         )
