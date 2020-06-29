module Update.Function exposing
    ( copySelection
    , deleteSelection
    , insertChar
    , newLine
    , pasteSelection
    , replaceLines
    , toggleEditMode
    , toggleHelpState
    , toggleViewMode
    , unload
    )

import Action
import Array exposing (Array)
import ArrayUtil
import Common
import Debounce exposing (Debounce)
import Dict exposing (Dict)
import EditorModel exposing (EditMode(..), EditorModel, HelpState(..), ViewMode(..), VimMode(..))
import EditorMsg exposing (EMsg(..), Position, Selection(..))
import Task
import Update.Line
import Update.Vim


autoclose : Dict String String
autoclose =
    Dict.fromList
        [ ( "[", "]" )
        , ( "{", "}" )
        , ( "(", ")" )
        , ( "\"", "\"" )
        , ( "'", "'" )
        , ( "`", "`" )
        ]


copySelection : EditorModel -> ( EditorModel, Cmd EMsg )
copySelection model =
    let
        ( debounce, debounceCmd ) =
            Debounce.push EditorModel.debounceConfig "RCB" model.debounce
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
                |> Common.recordHistoryWithCmd model

        _ ->
            ( model, Cmd.none )


pasteSelection : EditorModel -> EditorModel
pasteSelection model =
    let
        newCursor =
            { line = model.cursor.line + Array.length model.selectedText, column = model.cursor.column }
    in
    { model
        | lines = ArrayUtil.replaceLines model.cursor model.cursor model.selectedText model.lines
        , cursor = newCursor
    }


replaceLines : EditorModel -> Array String -> EditorModel
replaceLines model strings =
    let
        n =
            Array.length strings

        newCursor =
            { line = model.cursor.line + n, column = model.cursor.column }
    in
    case model.selection of
        Selection p1 p2 ->
            { model
                | lines = ArrayUtil.replaceLines p1 p2 strings model.lines

                -- , cursor = newCursor
            }

        _ ->
            model


deleteSelection : EditorModel -> ( EditorModel, Cmd EMsg )
deleteSelection model =
    let
        ( debounce, debounceCmd ) =
            Debounce.push EditorModel.debounceConfig "RCB" model.debounce
    in
    case model.selection of
        NoSelection ->
            ( Common.removeCharBefore { model | debounce = debounce }
                |> Common.sanitizeHover
            , debounceCmd
            )
                |> Common.recordHistoryWithCmd model

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
                |> Common.recordHistoryWithCmd model

        SelectedChar _ ->
            ( Common.removeCharBefore { model | debounce = debounce }
                |> Common.sanitizeHover
            , debounceCmd
            )
                |> Common.recordHistoryWithCmd model

        _ ->
            ( Common.removeCharBefore { model | debounce = debounce }
                |> Common.sanitizeHover
            , debounceCmd
            )
                |> Common.recordHistoryWithCmd model



-- MORE STUFF


newLine : EditorModel -> EditorModel
newLine ({ cursor, lines } as model) =
    let
        { line, column } =
            cursor

        linesList : List String
        linesList =
            Array.toList lines

        line_ : Int
        line_ =
            line + 1

        contentUntilCursor : List String
        contentUntilCursor =
            linesList
                |> List.take line_
                |> List.indexedMap
                    (\i content ->
                        if i == line then
                            String.left column content

                        else
                            content
                    )

        restOfLineAfterCursor : String
        restOfLineAfterCursor =
            String.dropLeft column (Common.lineContent lines line)

        restOfLines : List String
        restOfLines =
            List.drop line_ linesList

        newLines : Array String
        newLines =
            (contentUntilCursor
                ++ [ restOfLineAfterCursor ]
                ++ restOfLines
            )
                |> Array.fromList

        newCursor : Position
        newCursor =
            { line = line_
            , column = 0
            }
    in
    { model
        | lines = newLines
        , cursor = newCursor
    }


insertChar : EditMode -> String -> EditorModel -> EditorModel
insertChar editMode char model =
    case editMode of
        StandardEditor ->
            insertDispatch char model
                |> Update.Line.break

        VimEditor VimInsert ->
            insertDispatch char model
                |> Update.Line.break

        VimEditor VimNormal ->
            Update.Vim.process char model


insertDispatch : String -> EditorModel -> EditorModel
insertDispatch str model =
    case ( model.selection, Dict.get str autoclose ) of
        ( selection, Just closing ) ->
            insertWithMatching selection closing str model

        _ ->
            insertSimple str model


insertWithMatching : Selection -> String -> String -> EditorModel -> EditorModel
insertWithMatching selection closing str model =
    -- TODO: working on this
    let
        ( start, end ) =
            case selection of
                Selection a b ->
                    ( a, b )

                _ ->
                    ( model.cursor, model.cursor )

        insertion =
            str ++ ArrayUtil.between start end model.lines ++ closing

        newCursor =
            { line = model.cursor.line, column = model.cursor.column + String.length insertion - 1 }

        newLines =
            ArrayUtil.replace start end insertion model.lines
    in
    { model | lines = newLines, cursor = newCursor }


insertSimple : String -> EditorModel -> EditorModel
insertSimple char ({ cursor, lines } as model) =
    let
        { line, column } =
            cursor

        maxLineLength =
            20

        lineWithCharAdded : String -> String
        lineWithCharAdded content =
            String.left column content
                ++ char
                ++ String.dropLeft column content

        newLines : Array String
        newLines =
            lines
                |> Array.indexedMap
                    (\i content ->
                        if i == line then
                            lineWithCharAdded content

                        else
                            content
                    )

        newCursor : Position
        newCursor =
            { line = line
            , column = column + 1
            }
    in
    { model
        | lines = newLines
        , cursor = newCursor
    }



-- DEBOUNCE


unload : String -> Cmd EMsg
unload s =
    Task.perform Unload (Task.succeed s)



--


toggleViewMode : EditorModel -> EditorModel
toggleViewMode model =
    case model.viewMode of
        Light ->
            { model | viewMode = Dark }

        Dark ->
            { model | viewMode = Light }


toggleHelpState : EditorModel -> EditorModel
toggleHelpState model =
    case model.helpState of
        HelpOff ->
            { model | helpState = HelpOn }

        HelpOn ->
            { model | helpState = HelpOff }


toggleEditMode : EditorModel -> EditorModel
toggleEditMode model =
    case model.editMode of
        StandardEditor ->
            { model | editMode = VimEditor VimNormal }

        VimEditor _ ->
            { model | editMode = StandardEditor }
