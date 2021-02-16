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


type Data
    = ML MiniLatex.EditSimple.Data
    | MD Markdown.MarkdownData
    | TT String


type Lang
    = LMiniLaTeX
    | LMarkdown
    | LText


type UmuliMsg
    = MLMsg MiniLatex.EditSimple.LaTeXMsg
    | MDMsg Markdown.Render.MarkdownMsg
    | TTMsg


init : Lang -> Int -> String -> Maybe String -> Data
init lang version content mpreamble =
    case lang of
        LMiniLaTeX ->
            ML (MiniLatex.EditSimple.init version content mpreamble)

        LMarkdown ->
            MD (Markdown.init version content)

        LText ->
            TT content


update : Int -> String -> Maybe String -> Data -> Data
update version content mpreamble data =
    case data of
        ML data_ ->
            ML (MiniLatex.EditSimple.update version content mpreamble data_)

        MD data_ ->
            MD (Markdown.update version content data_)

        TT data_ ->
            TT content


render : String -> Data -> List (Html UmuliMsg)
render selectedId data =
    case data of
        ML data_ ->
            MiniLatex.EditSimple.get selectedId data_
                |> List.map (Html.map MLMsg)

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
                    [ html |> Html.map MDMsg ]

                Markdown.Render.Composite docParts ->
                    [ docParts.title, docParts.toc, docParts.document ]
                        |> List.map (Html.map MDMsg)

        TT data_ ->
            [ Html.div [ HA.style "white-space" "pre" ] [ Html.text data_ ] ]


renderContent : Lang -> String -> String -> Maybe String -> List (Html UmuliMsg)
renderContent lang selectedId content mpreamble =
    render selectedId (init lang 0 content mpreamble)
