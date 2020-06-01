module Helper.Load exposing
    ( config
    , loadDocument
    , loadDocumentByTitle
    , loadDocument_
    )

import Data
import Document exposing (Document)
import Editor
import EditorMsg exposing (WrapOption(..))
import Helper.Common
import Helper.File
import List.Extra
import Markdown.Option exposing (MarkdownOption(..))
import Render exposing (RenderingOption(..))
import Types exposing (DocType(..), Model, Msg(..))
import UuidHelper


loadDocumentByTitle : String -> Model -> Model
loadDocumentByTitle docTitle model =
    case docTitle of
        "about" ->
            loadDocument_ docTitle Data.about MarkdownDoc model

        "markdownExample" ->
            loadDocument_ docTitle Data.markdownExample MarkdownDoc model

        "mathExample" ->
            loadDocument_ docTitle Data.mathExample MarkdownDoc model

        "astro" ->
            loadDocument_ docTitle Data.astro MarkdownDoc model

        "aboutMiniLaTeX" ->
            loadDocument_ docTitle Data.aboutMiniLaTeX MiniLaTeXDoc model

        "miniLaTeXExample" ->
            loadDocument_ docTitle Data.miniLaTeXExample MiniLaTeXDoc model

        "aboutMiniLaTeX2" ->
            loadDocument_ docTitle Data.aboutMiniLaTeX2 MiniLaTeXDoc model

        _ ->
            model


loadDocument : Document -> Model -> Model
loadDocument document model =
    let
        docType =
            Helper.File.docType document.fileName

        renderingOption =
            case docType of
                MarkdownDoc ->
                    OMarkdown ExtendedMath

                MiniLaTeXDoc ->
                    OMiniLatex
    in
    { model
        | renderingData = Render.load ( 0, 0 ) model.counter renderingOption document.content
        , fileName = Just document.fileName
        , newFileName = document.fileName
        , counter = model.counter + 1
        , editor =
            Editor.initWithContent document.content
                (config { width = model.width, height = model.height, wrapOption = DontWrap })
        , docTitle = document.fileName
        , docType = docType
        , document = document
    }


loadDocument_ : String -> String -> DocType -> Model -> Model
loadDocument_ title source_ docType model =
    let
        lines =
            String.lines source_

        source =
            List.drop 1 lines |> String.join "\n"

        uuid =
            List.head lines
                |> Maybe.withDefault ""
                |> String.split ": "
                |> List.Extra.getAt 1
                |> Maybe.withDefault model.uuid
    in
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
                , newFileName = fileName
                , counter = model.counter + 1
                , editor =
                    Editor.initWithContent source
                        (config { width = model.width, height = model.height, wrapOption = DontWrap })
                , docTitle = title
                , docType = MarkdownDoc
                , document = { fileName = fileName, id = uuid, content = source }
            }
                |> UuidHelper.newUuid

        MiniLaTeXDoc ->
            let
                renderingData =
                    Render.load ( 0, 0 ) (model.counter + 1) OMiniLatex source

                fileName =
                    title ++ ".tex"
            in
            { model
                | renderingData = renderingData
                , fileName = Just fileName
                , newFileName = fileName
                , counter = model.counter + 2
                , editor =
                    Editor.initWithContent source
                        (config { width = model.width, height = model.height, wrapOption = DontWrap })
                , docTitle = title
                , docType = MiniLaTeXDoc
                , document = { fileName = fileName, id = uuid, content = source }
            }
                |> UuidHelper.newUuid


config flags =
    { width = Helper.Common.windowWidth flags.width
    , height = Helper.Common.windowHeight (flags.height - 10)
    , fontSize = 16
    , verticalScrollOffset = 3
    , debugOn = False
    , wrapOption = DontWrap
    }
