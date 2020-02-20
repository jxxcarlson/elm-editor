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

-- import Html exposing (Attribute, Html)

import BiDict exposing (BiDict)
import Html exposing (Html)
import Html.Attributes as Attribute
import Markdown.ElmWithId exposing (MarkdownMsg(..))
import Markdown.Option as MDOption
import Markdown.Parse as Parse
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
    { option : MDOption.Option
    , renderedText : RenderedText
    , initialAst : Tree Parse.MDBlockWithId
    , fullAst : Tree Parse.MDBlockWithId
    , sourceMap : BiDict String String
    }


type RenderingOption
    = OMarkdown MDOption.Option
    | OMiniLatex


getFullAst : RenderingData -> Maybe (Tree Parse.MDBlockWithId)
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
                    , sourceMap = Parse.sourceMap newAst
                }

        ML data ->
            ML { data | editRecord = MiniLatex.Edit.update NoDelay version source data.editRecord }


get : RenderingData -> RenderedText
get rd =
    case rd of
        MD data ->
            data.renderedText

        ML data ->
            { document = MiniLatex.Edit.get data.editRecord |> Html.div [ Attribute.attribute "id" "__RENDERED_TEXT__" ]
            , title = Html.span [ Attribute.style "font-size" "24px" ] [ Html.text (getTitle data.editRecord) ]
            , toc = innerTableOfContents data.editRecord.latexState
            }
                |> fixML


fixML :
    { a | title : Html.Html LaTeXMsg, toc : Html.Html LaTeXMsg, document : Html.Html LaTeXMsg }
    -> { title : Html.Html RenderMsg, toc : Html.Html RenderMsg, document : Html.Html RenderMsg }
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


loadMarkdown : ( Int, Int ) -> Int -> MDOption.Option -> String -> RenderingData
loadMarkdown selectedId counter option str =
    let
        ast =
            Parse.toMDBlockTree counter MDOption.ExtendedMath str
    in
    MD
        { option = option
        , initialAst = ast
        , fullAst = ast
        , renderedText = Render.Markdown.render selectedId ast
        , sourceMap = Parse.sourceMap ast
        }


loadMarkdownFast : ( Int, Int ) -> Int -> MDOption.Option -> String -> RenderingData
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
        , renderedText = Render.Markdown.render selectedId initialAst
        , sourceMap = Parse.sourceMap fullAst
        }



{- HIDDEN, MINILATEX -}


loadMiniLatex : Int -> String -> RenderingData
loadMiniLatex version str =
    ML { fullText = Nothing, editRecord = MiniLatex.Edit.init Delay version str }


loadMiniLatexFast : Int -> String -> RenderingData
loadMiniLatexFast version str =
    ML { fullText = Just str, editRecord = MiniLatex.Edit.init Delay version (getFirstPart str) }


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
