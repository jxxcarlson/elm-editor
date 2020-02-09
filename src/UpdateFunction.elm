module UpdateFunction exposing
    ( copySelection
    , deleteSelection
    , pasteSelection
    , replaceLines
    )

import Action
import Array exposing (Array)
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
                | cursor = { endSel | column = endSel.column + 1 }
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
        n =
            Array.length model.selectedText

        newCursor =
            { line = model.cursor.line + n, column = model.cursor.column }
    in
    ( { model
        | lines = ArrayUtil.paste model.cursor model.selectedText model.lines
        , cursor = newCursor
      }
    , Cmd.none
    )


replaceLines : Model -> Array String -> ( Model, Cmd Msg )
replaceLines model strings =
    let
        n =
            Array.length strings

        newCursor =
            { line = model.cursor.line + n, column = model.cursor.column }
    in
    case model.selection of
        Selection p1 p2 ->
            ( { model
                | lines = ArrayUtil.replaceLines p1 p2 strings model.lines
                , cursor = newCursor
              }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


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
