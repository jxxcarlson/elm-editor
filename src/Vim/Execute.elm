module Vim.Execute exposing (innerProcessCommand)

import Array
import ArrayUtil
import Common
import EditDistance exposing (levenshteinOfStrings)
import EditorModel exposing (EditMode(..), EditorModel, VimMode(..))
import EditorMsg exposing (Selection(..))
import Vim exposing (..)


type alias ReplacementData =
    { k : String
    , r : String
    , deltaLine : Int
    , deltaColumn : Int
    , sel1 : Int
    , sel2 : Int
    }


innerProcessCommand : EditorModel -> EditorModel
innerProcessCommand model =
    case executeBuffer model.vimModel.buffer of
        Nothing ->
            { model | vimModel = Vim.init }

        Just replacementData ->
            if model.vimModel.buffer == "" then
                { model | vimModel = Vim.init }

            else
                doReplacement replacementData model


doReplacement : ReplacementData -> EditorModel -> EditorModel
doReplacement replacementData model =
    let
        linesToInsert =
            Array.fromList (String.lines replacementData.r)

        newLines =
            ArrayUtil.replaceLines model.cursor model.cursor linesToInsert model.lines

        line =
            model.cursor.line

        newSelection =
            Selection
                { line = line + replacementData.deltaLine, column = replacementData.sel1 }
                { line = line + replacementData.deltaLine, column = replacementData.sel2 }

        newCursor =
            { line = line + replacementData.deltaLine, column = model.cursor.column + replacementData.deltaColumn }

        vimModel =
            model.vimModel
                |> setState VNormal
                |> setBuffer ""
    in
    { model
        | vimModel = vimModel
        , lines = newLines
        , selection = newSelection
        , cursor = newCursor
    }
        |> Common.recordHistory_ model


executeBuffer : String -> Maybe ReplacementData
executeBuffer buffer_ =
    bestMatch buffer_ replacements


bestMatch : String -> List ReplacementData -> Maybe ReplacementData
bestMatch str data =
    data
        |> List.map (\datum -> ( distance str datum, datum ))
        |> List.filter (\( ds, s ) -> ds == 0)
        |> List.head
        |> Maybe.map Tuple.second


distance : String -> ReplacementData -> Int
distance word datum =
    let
        n1 =
            String.length word

        n2 =
            String.length datum.k

        n =
            min n1 n2
    in
    levenshteinOfStrings (String.left n datum.k) word


replacements : List ReplacementData
replacements =
    [ { k = "theorem", r = "\\begin{theorem}\nXXX\n\\end{theorem}\n", deltaLine = 1, deltaColumn = 0, sel1 = 0, sel2 = 3 }
    , { k = "equation", r = "\\begin{equation}\nXXX\n\\end{equation}\n\n", deltaLine = 1, deltaColumn = 0, sel1 = 0, sel2 = 3 }
    , { k = "colored", r = "\\begin{colored}[elm]\nXXX\n\\end{colored}\n\n", deltaLine = 1, deltaColumn = 0, sel1 = 0, sel2 = 3 }
    , { k = "env", r = "\\begin{env}\nXXX\n\\end{env}\n\n", deltaLine = 1, deltaColumn = 0, sel1 = 0, sel2 = 3 }
    , { k = "enumerate", r = "\\begin{enumerate}\n\n\\item X\n\n\\item Y\n\n\\end{enumerate}\n\n", deltaLine = 2, deltaColumn = 6, sel1 = 5, sel2 = 6 }
    , { k = "itemize", r = "\\begin{itemize}\n\n\\item X\n\n\\item Y\n\n\\end{itemize}\n\n", deltaLine = 2, deltaColumn = 6, sel1 = 5, sel2 = 6 }
    , { k = "$", r = "$\\pi$", deltaLine = 0, deltaColumn = 1, sel1 = 1, sel2 = 3 }
    , { k = "$$", r = "$$\n\\pi\n$$\n", deltaLine = 1, deltaColumn = 0, sel1 = 0, sel2 = 3 }
    ]


setBuffer str model =
    { model | buffer = str }


setState : VState -> VimModel -> VimModel
setState state model =
    { model | state = state }
