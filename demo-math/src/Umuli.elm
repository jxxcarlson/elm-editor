module Umuli exposing
    ( Data(..)
    , Lang(..)
    , UmuliMsg
    , init
    , render
    , renderContent
    , update
    )

import Html exposing (Html)
import Html.Attributes as HA
import Markdown.Data as Markdown
import Markdown.Option
import Markdown.Render
import MiniLatex.EditSimple
import CaYaTeX
import Element


type Data
    = ML MiniLatex.EditSimple.Data
    | MD Markdown.MarkdownData
    | CY CaYaTeX.Data
    | TT String


type Lang
    = LMiniLaTeX
    | LMarkdown
    | LCaYaTeX
    | LText


type UmuliMsg
    = MLMsg MiniLatex.EditSimple.LaTeXMsg
    | MDMsg Markdown.Render.MarkdownMsg
    | CYMsg CaYaTeX.CaYaTeXMsg
    | TTMsg


init : Lang -> Int -> String -> Maybe String -> Data
init lang version content mpreamble =
    case lang of
        LMiniLaTeX ->
            ML (MiniLatex.EditSimple.init version content mpreamble)

        LMarkdown ->
            MD (Markdown.init version content)

        LCaYaTeX ->
            CY (CaYaTeX.init version content)

        LText ->
            TT content


update : Int -> String -> Maybe String -> Data -> Data
update version content mpreamble data =
    case data of
        ML data_ ->
            ML (MiniLatex.EditSimple.update version content mpreamble data_)

        MD data_ ->
            MD (Markdown.update version content data_)

        CY data_ ->
            CY (CaYaTeX.update version content data_)

        TT data_ ->
            TT content


render : String -> Data -> List (Element.Element UmuliMsg)
render selectedId data =
    case data of
        ML data_ ->
            MiniLatex.EditSimple.get selectedId data_
                |> List.map (Html.map MLMsg)
                |> List.map Element.html

        MD data_ ->
            -- Markdown.render selectedId data_
            let
                output =
                    Markdown.Render.withOptions
                        Markdown.Option.ExtendedMath
                        (Markdown.Option.InternalTOC "Contents")
                        ( 0, 0 )
                        0
                        data_.source
            in
            case output of
                Markdown.Render.Simple html ->
                    [ html |> Html.map MDMsg |> Element.html]

                Markdown.Render.Composite docParts ->
                    [ docParts.title, docParts.toc, docParts.document ]
                        |> List.map (Html.map MDMsg)
                        |> List.map Element.html

        CY data_ ->
                CaYaTeX.render "_id_" data_  |>  List.map (Element.map CYMsg)

        TT data_ ->
            [ Html.div [ HA.style "white-space" "pre" ] [ Html.text data_ ] |> Element.html ]

renderContent : Lang -> String -> String -> Maybe String -> List (Element.Element UmuliMsg)
renderContent lang selectedId content mpreamble =
    render selectedId (init lang 0 content mpreamble)

