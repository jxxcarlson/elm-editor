module Render.Types exposing (DocType(..), RenderMsg(..), RenderedText)

import Html exposing (Html)
import Markdown.Render exposing (MarkdownMsg(..))
import MiniLatex.Edit exposing (LaTeXMsg(..))


type RenderMsg
    = LaTeXMsg LaTeXMsg
    | MarkdownMsg MarkdownMsg


type alias RenderedText =
    { title : Html RenderMsg
    , toc : Html RenderMsg
    , document : Html RenderMsg }


type DocType
    = MarkdownDT
    | MiniLaTeXDT
