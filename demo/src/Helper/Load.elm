module Helper.Load exposing (config, loadDocument, loadDocumentByTitle)

import Data
import Editor
import Helper.Common
import Markdown.Option exposing (MarkdownOption(..))
import Render exposing (RenderingOption(..))
import Types exposing (DocType(..), Model, Msg(..))
import Wrap exposing (WrapOption(..))


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

        "aboutMiniLaTeX2" ->
            loadDocument docTitle Data.aboutMiniLaTeX2 MiniLaTeXDoc model

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
                , editor =
                    Editor.initWithContent source
                        (config { width = model.width, height = model.height, wrapOption = DontWrap })
                , docTitle = title
                , docType = MarkdownDoc
            }

        MiniLaTeXDoc ->
            let
                _ =
                    Debug.log "loading" "MiniLaTeXDoc"

                renderingData =
                    Render.load ( 0, 0 ) (model.counter + 1) OMiniLatex source

                fileName =
                    title ++ ".latex"
            in
            { model
                | renderingData = renderingData
                , fileName = Just fileName
                , counter = model.counter + 2
                , editor =
                    Editor.initWithContent source
                        (config { width = model.width, height = model.height, wrapOption = DontWrap })
                , docTitle = title
                , docType = MiniLaTeXDoc
            }


config flags =
    { width = Helper.Common.windowWidth flags.width
    , height = Helper.Common.windowHeight (flags.height - 40)
    , fontSize = 16
    , verticalScrollOffset = 3
    , debugOn = False
    , wrapOption = DontWrap
    }
