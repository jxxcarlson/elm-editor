module Render exposing
    ( MDData
    , MLData
    , RenderingData(..)
    , RenderingOption(..)
    , get
    , getFullAst
    , incrementVersion
    , load
    , loadFast
    , render
    , update
    , updateFromAstWithId
    )

-- import Html exposing (Attribute, Html)

import BiDict exposing (BiDict)
import Html exposing (Html)
import Html.Attributes as Attribute
import Markdown.Option exposing (MarkdownOption(..), OutputOption(..))
import Markdown.Parse
import Markdown.Render exposing (MarkdownMsg(..), MarkdownOutput(..))
import MiniLatex
import MiniLatex.Edit exposing (LaTeXMsg(..))
import MiniLatex.Render exposing (MathJaxRenderOption(..))
import Render.Markdown
import Render.Types exposing (RenderMsg(..), RenderedText)
import Tree exposing (Tree)


{-|

    MD =
        Markdown

    ML =
        MiniLatex

-}
type RenderingData
    = MD MDData
    | ML MLData


type alias MLData =
    { fullText : Maybe String
    , editRecord : MiniLatex.Edit.Data (Html MiniLatex.Edit.LaTeXMsg)
    }


type alias MDData =
    { option : MarkdownOption
    , renderedText : MarkdownOutput
    , initialAst : Tree Markdown.Parse.MDBlockWithId
    , fullAst : Tree Markdown.Parse.MDBlockWithId
    , sourceMap : BiDict String String
    }


type RenderingOption
    = OMarkdown MarkdownOption
    | OMiniLatex


getFullAst : RenderingData -> Maybe (Tree Markdown.Parse.MDBlockWithId)
getFullAst rd =
    case rd of
        ML _ ->
            Nothing

        MD data ->
            Just data.fullAst


load : ( Int, Int ) -> Int -> RenderingOption -> String -> RenderingData
load selectedId counter option source =
    case option of
        OMarkdown opt ->
            loadMarkdown selectedId counter opt source

        OMiniLatex ->
            loadMiniLatex counter source


loadFast : ( Int, Int ) -> Int -> RenderingOption -> String -> RenderingData
loadFast selectedId counter option source =
    case option of
        OMarkdown opt ->
            loadMarkdownFast selectedId counter opt source

        OMiniLatex ->
            loadMiniLatexFast counter source


render : ( Int, Int ) -> RenderingData -> RenderingData
render selectedId rd =
    case rd of
        MD data ->
            MD
                { data | renderedText = Render.Markdown.render selectedId data.fullAst }

        ML data ->
            case data.fullText of
                Nothing ->
                    ML data

                Just fullText ->
                    loadMiniLatex 0 fullText


update : ( Int, Int ) -> Int -> String -> RenderingData -> RenderingData
update selectedId version source rd =
    case rd of
        MD data ->
            let
                newAst =
                    Render.Markdown.diffUpdateAst data.option version source data.fullAst
            in
            MD
                { data
                    | fullAst = newAst

                    -- , renderedText = Markdown.ElmWithId.renderHtmlWithExternalTOC selectedId "Topics" newAst
                    , renderedText = Render.Markdown.render selectedId newAst
                    , initialAst = newAst
                    , sourceMap = Markdown.Parse.sourceMap newAst
                }

        ML data ->
            ML { data | editRecord = MiniLatex.Edit.update NoDelay version source data.editRecord }


get : String -> RenderingData -> RenderedText
get selectedId rd =
    case rd of
        MD data ->
            data.renderedText
                |> fixMD

        ML data ->
            { document = MiniLatex.Edit.get selectedId data.editRecord |> Html.div [ Attribute.attribute "id" "__RENDERED_TEXT__" ]
            , title = Html.span [ Attribute.style "font-size" "24px" ] [ Html.text (getTitle data.editRecord) ]
            , toc = innerTableOfContents data.editRecord.latexState
            }
                |> fixML


fixMD : MarkdownOutput -> RenderedText
fixMD markdownOutput =
    { title = Markdown.Render.title markdownOutput |> Html.map MarkdownMsg
    , toc = Markdown.Render.toc markdownOutput |> Html.map MarkdownMsg
    , document = Markdown.Render.document markdownOutput |> Html.map MarkdownMsg
    }


fixML :
    { a | title : Html.Html LaTeXMsg, toc : Html.Html LaTeXMsg, document : Html.Html LaTeXMsg }
    -> RenderedText
fixML r =
    { title = r.title |> Html.map LaTeXMsg
    , toc = r.toc |> Html.map LaTeXMsg
    , document = r.document |> Html.map LaTeXMsg
    }


getTitle : MiniLatex.Edit.Data (Html msg) -> String
getTitle data =
    data.latexState.tableOfContents
        |> List.head
        |> Maybe.map .name
        |> Maybe.withDefault "TITLE"



{- HIDDEN, MARKDOWN -}


loadMarkdown : ( Int, Int ) -> Int -> MarkdownOption -> String -> RenderingData
loadMarkdown selectedId counter option str =
    let
        ast =
            Markdown.Parse.toMDBlockTree counter ExtendedMath str
    in
    MD
        { option = option
        , initialAst = ast
        , fullAst = ast
        , renderedText = Render.Markdown.render selectedId ast
        , sourceMap = Markdown.Parse.sourceMap ast
        }


loadMarkdownFast : ( Int, Int ) -> Int -> MarkdownOption -> String -> RenderingData
loadMarkdownFast selectedId counter option str =
    let
        fullAst =
            Markdown.Parse.toMDBlockTree (counter + 1) ExtendedMath str

        initialAst =
            Markdown.Parse.toMDBlockTree counter option (getFirstPart str)
    in
    MD
        { option = option
        , initialAst = initialAst
        , fullAst = fullAst
        , renderedText = Render.Markdown.render selectedId initialAst
        , sourceMap = Markdown.Parse.sourceMap fullAst
        }



{- HIDDEN, MINILATEX -}


loadMiniLatex : Int -> String -> RenderingData
loadMiniLatex version str =
    ML { fullText = Nothing, editRecord = MiniLatex.Edit.init NoDelay version str }


loadMiniLatexFast : Int -> String -> RenderingData
loadMiniLatexFast version str =
    ML { fullText = Just str, editRecord = MiniLatex.Edit.init NoDelay version (getFirstPart str) }


{-| HELPERS
-}
getFirstPart : String -> String
getFirstPart str =
    String.left 4000 str



{- MiniLatex Table of contents -}


innerTableOfContents : MiniLatex.LatexState -> Html msg
innerTableOfContents latexState =
    Html.div [ Attribute.style "margin-top" "20px", Attribute.style "margin-left" "20px" ] (List.map innerTocItem (List.drop 1 latexState.tableOfContents))


innerTocItem : MiniLatex.TocEntry -> Html msg
innerTocItem tocEntry =
    let
        name =
            tocEntry.name |> String.replace " " "" |> String.toLower
    in
    Html.div [ Attribute.style "margin-bottom" "8px" ]
        [ Html.a [ Attribute.href <| "#_subsection_" ++ name, Attribute.style "font-size" "14px", Attribute.style "font-color" "blue" ]
            [ Html.text <| tocEntry.label ++ " " ++ tocEntry.name ]
        ]


incrementVersion : ( Int, Int ) -> RenderingData -> RenderingData
incrementVersion id renderingData =
    case renderingData of
        ML data ->
            ML data

        MD data ->
            MD { data | fullAst = Markdown.Parse.incrementVersion id data.fullAst }


updateFromAstWithId : ( Int, Int ) -> RenderingData -> RenderingData
updateFromAstWithId id renderingData =
    case renderingData of
        ML data ->
            ML data

        MD data ->
            MD { data | renderedText = Render.Markdown.render id data.fullAst }
