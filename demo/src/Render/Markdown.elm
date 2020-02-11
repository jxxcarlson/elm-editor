module Render.Markdown exposing
    ( diffUpdateAst
    , emptyAst
    , emptyRenderedText
    , getFirstPart
    , parse
    , render
    )

-- import Cmd.Document

import Markdown.ElmWithId
import Markdown.Option exposing (..)
import Markdown.Parse as Parse
import Render.Types exposing (RenderedText)
import Tree exposing (Tree)
import Tree.Diff as Diff


emptyAst : Tree Parse.MDBlockWithId
emptyAst =
    Parse.toMDBlockTree -1 ExtendedMath ""


emptyRenderedText : RenderedText msg
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


render : ( Int, Int ) -> Tree Parse.MDBlockWithId -> RenderedText msg
render selectedId ast =
    Markdown.ElmWithId.renderHtmlWithExternaTOC selectedId "Topics" ast


getFirstPart : String -> String
getFirstPart str =
    String.left 2000 str
