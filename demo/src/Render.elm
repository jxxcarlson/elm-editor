module Render exposing
    ( MDData
    , MLData
    , RenderingData(..)
    , RenderingOption(..)
    , get
    , getFullAst
    , load
    , loadFast
    , render
    , update
    )

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as HA
import Markdown.ElmWithId
import Markdown.Option as MDOption
import Markdown.Parse as Parse
import MiniLatex
import MiniLatex.Edit
import MiniLatex.Render exposing (MathJaxRenderOption(..))
import Render.Markdown
import Render.Types exposing (RenderedText)
import Tree exposing (Tree)


{-|

    MD =
        Markdown

    ML =
        MiniLatex

-}
type RenderingData msg
    = MD (MDData msg)
    | ML (MLData msg)


type alias MLData msg =
    { fullText : Maybe String
    , editRecord : MiniLatex.Edit.Data (Html msg)
    }


type alias MDData msg =
    { option : MDOption.Option
    , renderedText : RenderedText msg
    , initialAst : Tree Parse.MDBlockWithId
    , fullAst : Tree Parse.MDBlockWithId
    , sourceMap : Dict String String
    }


type RenderingOption
    = OMarkdown MDOption.Option
    | OMiniLatex


getFullAst : RenderingData msg -> Maybe (Tree Parse.MDBlockWithId)
getFullAst rd =
    case rd of
        ML _ ->
            Nothing

        MD data ->
            Just data.fullAst


load : ( Int, Int ) -> Int -> RenderingOption -> String -> RenderingData msg
load selectedId counter option source =
    case option of
        OMarkdown opt ->
            loadMarkdown selectedId counter opt source

        OMiniLatex ->
            loadMiniLatex counter source


loadFast : ( Int, Int ) -> Int -> RenderingOption -> String -> RenderingData msg
loadFast selectedId counter option source =
    case option of
        OMarkdown opt ->
            loadMarkdownFast selectedId counter opt source

        OMiniLatex ->
            loadMiniLatexFast counter source


render : ( Int, Int ) -> RenderingData msg -> RenderingData msg
render selectedId rd =
    case rd of
        MD data ->
            MD { data | renderedText = Markdown.ElmWithId.renderHtmlWithExternaTOC selectedId "Topics" data.fullAst }

        ML data ->
            case data.fullText of
                Nothing ->
                    ML data

                Just fullText ->
                    loadMiniLatex -2 fullText


update : ( Int, Int ) -> Int -> String -> RenderingData msg -> RenderingData msg
update selectedId version source rd =
    case rd of
        MD data ->
            let
                newAst =
                    Render.Markdown.diffUpdateAst data.option version source data.fullAst

                _ =
                    Debug.log "AST1" data.fullAst

                _ =
                    Debug.log "AST2" newAst
            in
            MD
                { data
                    | fullAst = newAst
                    , renderedText = Markdown.ElmWithId.renderHtmlWithExternaTOC selectedId "Topics" newAst
                    , sourceMap = Parse.sourceMap newAst
                }

        ML data ->
            ML { data | editRecord = MiniLatex.Edit.update NoDelay version source data.editRecord }


get : RenderingData msg -> RenderedText msg
get rd =
    case rd of
        MD data ->
            data.renderedText

        ML data ->
            { document = MiniLatex.Edit.get data.editRecord |> Html.div []
            , title = Html.span [ HA.style "font-size" "24px" ] [ Html.text (getTitle data.editRecord) ]
            , toc = innerTableOfContents data.editRecord.latexState
            }


getTitle : MiniLatex.Edit.Data (Html msg) -> String
getTitle data =
    data.latexState.tableOfContents
        |> List.head
        |> Maybe.map .name
        |> Maybe.withDefault "TITLE"



{- HIDDEN, MARKDOWN -}


loadMarkdown : ( Int, Int ) -> Int -> MDOption.Option -> String -> RenderingData msg
loadMarkdown selectedId counter option str =
    let
        ast =
            Parse.toMDBlockTree counter MDOption.ExtendedMath str
    in
    MD
        { option = option
        , initialAst = ast
        , fullAst = ast
        , renderedText = Markdown.ElmWithId.renderHtmlWithExternaTOC selectedId "Topics" ast
        , sourceMap = Parse.sourceMap ast
        }


loadMarkdownFast : ( Int, Int ) -> Int -> MDOption.Option -> String -> RenderingData msg
loadMarkdownFast selectedId counter option str =
    let
        fullAst =
            Parse.toMDBlockTree (counter + 1) MDOption.ExtendedMath str

        initialAst =
            Parse.toMDBlockTree counter option (getFirstPart str)
    in
    MD
        { option = option
        , initialAst = initialAst
        , fullAst = fullAst
        , renderedText = Markdown.ElmWithId.renderHtmlWithExternaTOC selectedId "Topics" initialAst
        , sourceMap = Parse.sourceMap fullAst
        }



{- HIDDEN, MINILATEX -}


loadMiniLatex : Int -> String -> RenderingData msg
loadMiniLatex version str =
    ML { fullText = Nothing, editRecord = MiniLatex.Edit.init Delay version str }


loadMiniLatexFast : Int -> String -> RenderingData msg
loadMiniLatexFast version str =
    ML { fullText = Just str, editRecord = MiniLatex.Edit.init Delay version (getFirstPart str) }



--    let
--        fullAst =
--            Parse.toMDBlockTree (counter + 1) MDOption.ExtendedMath str
--
--        initialAst =
--            Parse.toMDBlockTree counter option (getFirstPart str)
--    in
--    MD
--        { option = option
--        , initialAst = initialAst
--        , fullAst = fullAst
--        , renderedText = Markdown.ElmWithId.renderHtmlWithExternaTOC "Topics" initialAst
--        }


{-| HELPERS
-}
getFirstPart : String -> String
getFirstPart str =
    String.left 4000 str



{- MiniLatex Table of contents -}


innerTableOfContents : MiniLatex.LatexState -> Html msg
innerTableOfContents latexState =
    Html.div [ HA.style "margin-top" "20px", HA.style "margin-left" "20px" ] (List.map innerTocItem (List.drop 1 latexState.tableOfContents))


innerTocItem : MiniLatex.TocEntry -> Html msg
innerTocItem tocEntry =
    let
        name =
            tocEntry.name |> String.replace " " "" |> String.toLower
    in
    Html.div [ HA.style "margin-bottom" "8px" ]
        [ Html.a [ HA.href <| "#_subsection_" ++ name, HA.style "font-size" "14px", HA.style "font-color" "blue" ]
            [ Html.text <| tocEntry.label ++ " " ++ tocEntry.name ]
        ]
