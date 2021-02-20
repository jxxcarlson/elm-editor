module Vim.Update exposing
    ( process
    , setState
    , toString
    , toggleShortCutExecution
    , update
    )

import Action
import EditorModel exposing (EditMode(..), EditorModel, VimMode(..))
import Vim exposing (..)
import Vim.Execute as Execute


update : VimMsg -> VimModel -> VimModel
update msg model =
    model


toggleShortCutExecution model =
    case ( model.editMode, model.vimModel.state ) of
        ( StandardEditor, Vim.VNormal ) ->
            ( { model
                | vimModel = setState Vim.VAccumulate model.vimModel
                , editMode = VimEditor VimNormal
              }
            , Cmd.none
            )

        ( VimEditor VimNormal, Vim.VAccumulate ) ->
            let
                newModel =
                    Execute.innerProcessCommand model
            in
            ( { newModel | editMode = StandardEditor }, Cmd.none )

        ( VimEditor VimInsert, Vim.VAccumulate ) ->
            let
                newModel =
                    Execute.innerProcessCommand model
            in
            ( { newModel | editMode = VimEditor VimNormal }, Cmd.none )

        ( VimEditor VimInsert, Vim.VNormal ) ->
            ( { model | editMode = VimEditor VimNormal }, Cmd.none )

        _ ->
            ( model, Cmd.none )



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


process : String -> EditorModel -> EditorModel
process char model =
    case ( model.vimModel.state, char ) of
        ( VNormal, "=" ) ->
            -- TODO: link to option-=
            { model | vimModel = setState VAccumulate model.vimModel }

        ( VNormal, _ ) ->
            vimModeProcess char model

        ( VAccumulate, "=" ) ->
            Execute.innerProcessCommand model

        ( VAccumulate, _ ) ->
            { model | vimModel = appendBuffer char model.vimModel }


resetVimModel : VimModel -> VimModel
resetVimModel vm =
    vm
        |> setState VNormal
        |> setBuffer ""


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


setBuffer str model =
    { model | buffer = str }



-- VIM


processCommand : EditorModel -> EditorModel
processCommand model =
    model
