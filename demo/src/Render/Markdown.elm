module Render.Markdown exposing
    ( diffUpdateAst
    , emptyAst
    , emptyRenderedText
    , getFirstPart
    , parse
    , render
    )

-- import Cmd.Document

import Html
import Markdown.ElmWithId exposing (MarkdownMsg)
import Markdown.Option exposing (..)
import Markdown.Parse as Parse
import Render.Types exposing (RenderMsg(..), RenderedText)
import Tree exposing (Tree)
import Tree.Diff as Diff


emptyAst : Tree Parse.MDBlockWithId
emptyAst =
    Parse.toMDBlockTree -1 ExtendedMath ""


emptyRenderedText : RenderedText
emptyRenderedText =
    render ( 0, 0 ) emptyAst


parse : Option -> Int -> String -> Tree Parse.MDBlockWithId
parse flavor counter str =
    Parse.toMDBlockTree counter flavor str


{-| compute a new AST from an old one and some text, preserving the ids of unchanged blocs.
The counter is used for the version number in the block ids.
-}
diffUpdateAst : Option -> Int -> String -> Tree Parse.MDBlockWithId -> Tree Parse.MDBlockWithId
diffUpdateAst option counter text lastAst =
    let
        newAst : Tree Parse.MDBlockWithId
        newAst =
            parse option counter text
    in
    Diff.mergeWith Parse.equalContent lastAst newAst


render : ( Int, Int ) -> Tree Parse.MDBlockWithId -> RenderedText
render selectedId ast =
    Markdown.ElmWithId.renderHtmlWithExternalTOC selectedId "Topics" ast
        |> fix


fix :
    { a | title : Html.Html MarkdownMsg, toc : Html.Html MarkdownMsg, document : Html.Html MarkdownMsg }
    -> { title : Html.Html RenderMsg, toc : Html.Html RenderMsg, document : Html.Html RenderMsg }
fix r =
    { title = r.title |> Html.map MarkdownMsg
    , toc = r.toc |> Html.map MarkdownMsg
    , document = r.document |> Html.map MarkdownMsg
    }



--{ document : Html.Html MarkdownMsg
--, title : Html.Html MarkdownMsg
--, toc : Html.Html MarkdownMsg
--}



--
--type RenderMsg
--    = LaTeXMsg LaTeXMsg
--    | MarkdownMsg MarkdownMsg
--
--
--type alias RenderedText =
--    { title : Html RenderMsg, toc : Html RenderMsg, document : Html RenderMsg }


getFirstPart : String -> String
getFirstPart str =
    String.left 2000 str
