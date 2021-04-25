module Update.Function exposing
    ( copySelection
    , deleteLine
    , deleteSelection
    , insertChar
    , killLine
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
import Debounce
import Dict exposing (Dict)
import EditorModel exposing (EditMode(..), EditorModel, HelpState(..), ViewMode(..), VimMode(..))
import EditorMsg exposing (EMsg(..), Position, Selection(..))
import Line
import Position
import Task
import Update.Line
import Vim.Update


autoclose : Dict String String
autoclose =
    Dict.fromList
        [ ( "[", "]" )
        , ( "{", "}" )
        , ( "(", ")" )
        , ( "\"", "\"" )
        , ( "`", "`" )
        ]


replacements : Dict String String
replacements =
    Dict.fromList
        [ ( ":$", "$$\n\\pi\n$$" )
        , ( ":th", "\\begin{theorem}\n\n\\end{theorem}" )
        ]


copySelection : EditorModel -> ( EditorModel, Cmd EMsg )
copySelection model =
    let
        ( _, debounceCmd ) =
            Debounce.push EditorModel.debounceConfig "RCB" model.debounce
    in
    case model.selection of
        (Selection _ endSel) as sel ->
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


lengthOfLine : Int -> Array String -> Int
lengthOfLine line targetLines =
    Array.get line targetLines
        |> Maybe.map String.length
        |> Maybe.withDefault 0


killLine : EditorModel -> EditorModel
killLine model =
    let
        newSelection =
            Selection model.cursor (Line.lastPosition model.cursor.line model.lines)

        ( newLines, selectedText ) =
            Action.deleteSelection newSelection model.lines
    in
    { model | lines = newLines, selectedText = selectedText }


deleteLine : EditorModel -> EditorModel
deleteLine model =
    let
        newCursor =
            { line = model.cursor.line, column = 0 }

        newSelection =
            Selection newCursor (Line.lastPosition model.cursor.line model.lines)

        ( newLines, selectedText ) =
            Action.deleteSelection newSelection model.lines
    in
    { model
        | lines = newLines
        , selectedText = selectedText
        , cursor = newCursor
    }


pasteSelection : EditorModel -> EditorModel
pasteSelection model =
    -- TODO:CURRENT
    let
        newCursor =
            if Array.length model.selectedText == 1 then
                Position.deltaColumn (lengthOfLine 0 model.selectedText) model.cursor

            else
                { line = model.cursor.line + Array.length model.selectedText, column = model.cursor.column }
    in
    case model.selection of
        NoSelection ->
            { model
                | lines = ArrayUtil.replaceLines model.cursor model.cursor model.selectedText model.lines
                , cursor = newCursor
            }

        SelectingFrom _ ->
            model

        SelectedChar pos ->
            { model
                | lines = ArrayUtil.replaceLines pos pos model.selectedText model.lines
                , cursor = newCursor
            }

        Selection sel1 sel2 ->
            let
                -- TODO: in this case, delete selection, then paste
                _ =
                    Debug.log "paste, (sel1, sel2)" ( sel1, sel2 )

                --( newArray, removed ) =
                --    Action.deleteSelection model.selection model.lines |> Debug.log "CUT"
                delta =
                    lengthOfLine 0 model.selectedText + sel1.column - sel2.column |> Debug.log "DELTA"
            in
            { model
                | lines = ArrayUtil.replaceLines sel1 sel2 model.selectedText model.lines
                , cursor = Position.deltaColumn delta model.cursor
                , selection = NoSelection
            }


replaceLines : EditorModel -> Array String -> EditorModel
replaceLines model strings =
    case model.selection of
        Selection p1 p2 ->
            { model
                | lines = ArrayUtil.replaceLines p1 p2 strings model.lines
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

        (Selection beginSel _) as sel ->
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

        SelectedChar _ ->
            ( Common.removeCharBefore { model | debounce = debounce }
                |> Common.sanitizeHover
            , debounceCmd
            )

        _ ->
            ( Common.removeCharBefore { model | debounce = debounce }
                |> Common.sanitizeHover
            , debounceCmd
            )



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
                ++ restOfLineAfterCursor
                :: restOfLines
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
            Vim.Update.process char model


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
