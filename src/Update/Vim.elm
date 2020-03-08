module Update.Vim exposing (process)

import Action
import Cmd.Extra exposing (withNoCmd)
import Common
import EditorModel exposing (EMsg(..), EditMode(..), EditorModel, VimMode(..))


process : String -> EditorModel -> EditorModel
process char model =
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

        _ ->
            model
