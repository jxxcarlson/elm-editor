module Update.Vim exposing (process)

import Action
import Model exposing (Model, Msg(..))


process : String -> Model -> Model
process char model =
    case char of
        "h" ->
            Action.cursorLeft model

        "l" ->
            Action.cursorRight model

        _ ->
            model
