module Update.Vim exposing (..)
---(process, update, toString)

import Action
import EditorModel exposing (EditMode(..), EditorModel, VimMode(..))
import Vim exposing(..)
import ArrayUtil
import Array
import EditDistance exposing(levenshteinOfStrings)
import List.Extra



update : VimMsg -> VimModel -> VimModel
update msg model = model
    -- case (msg, model.state) of

toString : VState -> String
toString vstate =
    case vstate of
        VAccumulate -> "accumulate"
        VNormal -> "normal"

setState : VState -> VimModel -> VimModel
setState state model =
    { model | state = state}

appendBuffer : String -> VimModel -> VimModel
appendBuffer str model =
    { model | buffer = model.buffer  ++ str}

setBuffer str model =
    { model | buffer = str  }

process : String -> EditorModel -> EditorModel
process char model =
    case (model.vimModel.state, char) of
        (VNormal, "=") -> { model | vimModel = setState VAccumulate model.vimModel}
        (VNormal, _) -> vimModeProcess char model
        (VAccumulate, "=") -> innerProcessCommand model
        (VAccumulate, _) -> { model | vimModel = appendBuffer char model.vimModel}


executeBuffer : String -> String
executeBuffer buffer_ =
    bestMatch buffer_ replacements1


bestMatch : String -> List GuessingDatum1 -> String
bestMatch str data =
    data
      |> List.map (\datum -> (distance str datum, datum.r))
      |> List.sortBy (\(ds, s) -> ds)
      |> List.head |> Debug.log "XX"
      |> Maybe.map Tuple.second
      |> Maybe.withDefault ""


distance : String -> GuessingDatum1 -> Int
distance word datum =
     let
           n1 = String.length word
           n2 = String.length datum.k
           n = min n1 n2
     in
        levenshteinOfStrings (String.left n datum.k) word


type alias GuessingDatum = {a : String, b : String, r : String}
type alias GuessingDatum1 = {k : String, r : String}


replacements1 : List GuessingDatum1
replacements1 = [
     { k = "theorem", r ="\\begin{theorem}\nXXX\n\\end{theorem}\n" }
   , { k = "equation", r ="\\begin{equation}\nXXX\n\\end{equation}\n" }
   , { k = "env", r ="\\begin{env}\nXXX\n\\end{env}\n" }
   , { k = "$", r = "$ XX $" }
   , { k = "$$", r = "$$\nXX\n$$" }

  ]

replacements : List GuessingDatum
replacements = [
     { a = "begin", b = "theorem", r ="\\begin{theorem}\nXXX\n\\end{theorem}\n" }
   , { a = "begin", b = "equation", r ="\\begin{equation}\nXXX\n\\end{equation}\n" }
   , { a = "begin", b = "env", r ="\\begin{env}\nXXX\n\\end{env}\n" }
   , { a = "$", b = "$", r = "$ XX $" }
   , { a = "$$", b = "$$", r = "$$\nXX\n$$" }

  ]


innerProcessCommand : EditorModel -> EditorModel
innerProcessCommand model =
    let
        insertion = executeBuffer model.vimModel.buffer

        linesToInsert = Array.fromList (String.lines insertion)

        lines = ArrayUtil.replaceLines model.cursor model.cursor linesToInsert model.lines

        vimModel = model.vimModel
          |> setState VNormal
          |> setBuffer ""

    in
    {model | vimModel = vimModel, lines = lines }

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
processCommand model = model
