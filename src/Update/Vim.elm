module Update.Vim exposing (innerProcessCommand, process, setState, toString, update)

import Action
import Array
import ArrayUtil
import Common
import EditDistance exposing (levenshteinOfStrings)
import EditorModel exposing (EditMode(..), EditorModel, VimMode(..))
import EditorMsg exposing (Selection(..))
import Vim exposing (..)


type alias ReplacementData =
    { k : String, r : String, deltaLine : Int, deltaColumn : Int }


update : VimMsg -> VimModel -> VimModel
update msg model =
    model



-- case (msg, model.state) of


toString : VState -> String
toString vstate =
    case vstate of
        VAccumulate ->
            "accumulate"

        VNormal ->
            ""


setState : VState -> VimModel -> VimModel
setState state model =
    { model | state = state }


appendBuffer : String -> VimModel -> VimModel
appendBuffer str model =
    { model | buffer = model.buffer ++ str }


setBuffer str model =
    { model | buffer = str }


process : String -> EditorModel -> EditorModel
process char model =
    case ( model.vimModel.state, char ) of
        ( VNormal, "=" ) ->
            -- TODO: link to option-=
            { model | vimModel = setState VAccumulate model.vimModel }

        ( VNormal, _ ) ->
            vimModeProcess char model

        ( VAccumulate, "=" ) ->
            innerProcessCommand model

        ( VAccumulate, _ ) ->
            { model | vimModel = appendBuffer char model.vimModel }


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
    [ { k = "theorem", r = "\\begin{theorem}\nXXX\n\\end{theorem}\n", deltaLine = 1, deltaColumn = 0 }
    , { k = "equation", r = "\\begin{equation}\nXXX\n\\end{equation}\n\n", deltaLine = 1, deltaColumn = 0 }
    , { k = "env", r = "\\begin{env}\nXXX\n\\end{env}\n\n", deltaLine = 1, deltaColumn = 0 }
    , { k = "enumerate", r = "\\begin{enumerate}\n\n\\item X\n\n\\item Y\n\n\\end{enumerate}\n\n", deltaLine = 2, deltaColumn = 6 }
    , { k = "itemize", r = "\\begin{itemize}\n\n\\item X\n\n\\item Y\n\n\\end{itemize}\n\n", deltaLine = 2, deltaColumn = 6 }
    , { k = "$", r = "$ $", deltaLine = 0, deltaColumn = 1 }
    , { k = "$$", r = "$$\n\\pi\n$$\n", deltaLine = 1, deltaColumn = 0 }
    ]


resetVimModel : VimModel -> VimModel
resetVimModel vm =
    vm
        |> setState VNormal
        |> setBuffer ""


innerProcessCommand : EditorModel -> EditorModel
innerProcessCommand model =
    case executeBuffer model.vimModel.buffer of
        Nothing ->
            { model | vimModel = Vim.init }

        Just replacementData ->
            let
                insertion =
                    replacementData.r

                linesToInsert =
                    Array.fromList (String.lines insertion)

                newLines =
                    ArrayUtil.replaceLines model.cursor model.cursor linesToInsert model.lines

                line =
                    model.cursor.line

                lineEnd_ =
                    Array.get line newLines
                        |> Maybe.map String.length
                        |> Maybe.withDefault 0
                        |> (\x -> x - 1)

                newSelection =
                    Selection
                        { line = line + 1, column = 0 }
                        { line = line + 1, column = lineEnd_ - 1 }

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

                --, selection = newSelection
                , cursor = newCursor
            }
                |> Common.recordHistory_ model


vimModeProcess : String -> EditorModel -> EditorModel
vimModeProcess char model =
    case char of
        "i" ->
            { model | editMode = VimEditor VimInsert }

        "h" ->
            Action.cursorLeft model

        "j" ->
            Action.cursorDown model

        "k" ->
            Action.cursorUp model

        "l" ->
            Action.cursorRight model

        "/" ->
            processCommand model

        _ ->
            model



-- VIM


processCommand : EditorModel -> EditorModel
processCommand model =
    model
