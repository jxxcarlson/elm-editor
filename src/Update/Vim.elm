module Update.Vim exposing (process, toString, update, setState, innerProcessCommand)

import Action
import Array
import ArrayUtil
import EditDistance exposing (levenshteinOfStrings)
import EditorModel exposing (EditMode(..), EditorModel, VimMode(..))
import Vim exposing (..)


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
            "normal"


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


executeBuffer : String -> String
executeBuffer buffer_ =
    bestMatch buffer_ replacements


bestMatch : String -> List GuessingDatum -> String
bestMatch str data =
    data
        |> List.map (\datum -> ( distance str datum, datum.r ))
        |> List.sortBy (\( ds, s ) -> ds)
        |> List.head
        |> Maybe.map Tuple.second
        |> Maybe.withDefault ""


distance : String -> GuessingDatum -> Int
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


type alias GuessingDatum =
    { k : String, r : String }


replacements : List GuessingDatum
replacements =
    [ { k = "theorem", r = "\\begin{theorem}\nXXX\n\\end{theorem}\n" }
    , { k = "equation", r = "\\begin{equation}\nXXX\n\\end{equation}\n" }
    , { k = "env", r = "\\begin{env}\nXXX\n\\end{env}\n" }
    , { k = "$", r = "$ XX $" }
    , { k = "$$", r = "$$\nXX\n$$" }
    ]


innerProcessCommand : EditorModel -> EditorModel
innerProcessCommand model =
    -- TODO: link to option-=
    let
        insertion =
            executeBuffer model.vimModel.buffer

        linesToInsert =
            Array.fromList (String.lines insertion)

        lines =
            ArrayUtil.replaceLines model.cursor model.cursor linesToInsert model.lines

        vimModel =
            model.vimModel
                |> setState VNormal
                |> setBuffer ""
    in
    { model | vimModel = vimModel, lines = lines }


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
