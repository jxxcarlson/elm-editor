module UpdateFunction exposing
    ( copySelection
    , deleteSelection
    , pasteSelection
    )

import Action
import ArrayUtil
import Common
import Debounce exposing (Debounce)
import Model exposing (Model, Msg(..), Selection(..))


copySelection : Model -> ( Model, Cmd Msg )
copySelection model =
    let
        ( debounce, debounceCmd ) =
            Debounce.push Model.debounceConfig "RCB" model.debounce
    in
    case model.selection of
        (Selection beginSel endSel) as sel ->
            let
                ( _, selectedText ) =
                    Action.deleteSelection sel model.lines
            in
            ( { model
                | cursor = beginSel
                , selection = NoSelection
                , selectedText = selectedText
              }
                |> Common.sanitizeHover
            , debounceCmd
            )
                |> Common.recordHistory model

        _ ->
            ( model, Cmd.none )


pasteSelection : Model -> ( Model, Cmd Msg )
pasteSelection model =
    let
        ( before, after ) =
            Debug.log "DB, paste split: (before, after)" <|
                ArrayUtil.split model.cursor model.lines

        _ =
            Debug.log "DB, paste selectedText" model.selectedText

        newLines =
            ArrayUtil.paste model.cursor model.selectedText model.lines
    in
    ( { model | lines = newLines }, Cmd.none )


deleteSelection : Model -> ( Model, Cmd Msg )
deleteSelection model =
    let
        ( debounce, debounceCmd ) =
            Debounce.push Model.debounceConfig "RCB" model.debounce
    in
    case model.selection of
        NoSelection ->
            ( Common.removeCharBefore { model | debounce = debounce }
                |> Common.sanitizeHover
            , debounceCmd
            )
                |> Common.recordHistory model

        (Selection beginSel endSel) as sel ->
            let
                ( newLines, selectedText ) =
                    Debug.log "XXX" <|
                        Action.deleteSelection sel model.lines
            in
            ( { model
                | lines = newLines
                , cursor = beginSel
                , selection = NoSelection
                , selectedText = selectedText
              }
                |> Common.sanitizeHover
            , debounceCmd
            )
                |> Common.recordHistory model

        SelectedChar _ ->
            ( Common.removeCharBefore { model | debounce = debounce }
                |> Common.sanitizeHover
            , debounceCmd
            )
                |> Common.recordHistory model

        _ ->
            ( Common.removeCharBefore { model | debounce = debounce }
                |> Common.sanitizeHover
            , debounceCmd
            )
                |> Common.recordHistory model
