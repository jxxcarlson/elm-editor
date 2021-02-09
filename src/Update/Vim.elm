module Update.Vim exposing (process, update)

import Action
import EditorModel exposing (EditMode(..), EditorModel, VimMode(..))
import EditorMsg exposing (EMsg(..))
import Vim exposing(..)

{-}

type alias VimState = {
        buffer : String
      , innerState : VInnerState
   }

type VInnerState = VAccumulate | VDischarge | VNormal

-}



update : VimMsg -> VimModel -> VimModel
update msg model = model



process : String -> EditorModel -> EditorModel
process char model =
    case (model.vimModel.state, char) of
        (VNormal, _) -> vimModeProcess char model
        _ -> model

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
