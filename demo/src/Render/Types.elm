module Render.Types exposing (DocType(..), RenderedText)

import Html exposing (Html)


type alias RenderedText msg =
    { title : Html msg, toc : Html msg, document : Html msg }


type DocType
    = MarkdownDT
    | MiniLaTeXDT
