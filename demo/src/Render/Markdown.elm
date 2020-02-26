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
import Markdown.Option exposing (..)
import Markdown.Parse as Parse
import Markdown.Render exposing (DocumentParts, MarkdownMsg, MarkdownOutput)
import Render.Types exposing (RenderMsg(..))
import Tree exposing (Tree)
import Tree.Diff as Diff


emptyAst : Tree Parse.MDBlockWithId
emptyAst =
    Parse.toMDBlockTree -1 ExtendedMath ""


emptyRenderedText : MarkdownOutput
emptyRenderedText =
    Markdown.Render.withOptionsFromAST ExtendedMath (ExternalTOC "Topics") ( 0, 0 ) emptyAst


parse : MarkdownOption -> Int -> String -> Tree Parse.MDBlockWithId
parse flavor counter str =
    Parse.toMDBlockTree counter flavor str


{-| compute a new AST from an old one and some text, preserving the ids of unchanged blocs.
The counter is used for the version number in the block ids.
-}
diffUpdateAst : MarkdownOption -> Int -> String -> Tree Parse.MDBlockWithId -> Tree Parse.MDBlockWithId
diffUpdateAst option counter text lastAst =
    let
        newAst : Tree Parse.MDBlockWithId
        newAst =
            parse option counter text
    in
    Diff.mergeWith Parse.equalContent lastAst newAst


render : ( Int, Int ) -> Tree Parse.MDBlockWithId -> MarkdownOutput
render selectedId ast =
    Markdown.Render.withOptionsFromAST ExtendedMath (ExternalTOC "Topics") selectedId ast



-- |> fix
-- MarkdownOption -> OutputOption -> Id -> Int -> String


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
--type alias DocumentParts =
--    { title : Html RenderMsg, toc : Html RenderMsg, document : Html RenderMsg }


getFirstPart : String -> String
getFirstPart str =
    String.left 2000 str
