module Action exposing
    ( cursorDown
    , cursorLeft
    , cursorRight
    , cursorUp
    , deIndent
    , deleteSelection
    , firstLine
    , goToLine
    , indent
    , lastLine
    , moveToLineEnd
    , moveToLineStart
    , pageDown
    , pageUp
    , scrollToLine
    , selectDown
    , selectLeft
    , selectLine
    , selectRight
    , selectUp
    )

import Array exposing (Array)
import ArrayUtil
import Browser.Dom as Dom
import Common
import EditorModel exposing (EditorModel)
import EditorMsg exposing (EMsg(..), Selection(..))
import Task exposing (Task)
import Cursor


-- INDENT


indent : EditorModel -> EditorModel
indent model =
    let
        newLines =
            case model.selection of
                Selection p1 p2 ->
                    ArrayUtil.indent model.indentationOffset p1.line p2.line model.lines

                _ ->
                    model.lines
    in
    { model | lines = newLines }


deIndent : EditorModel -> EditorModel
deIndent model =
    let
        newLines =
            case model.selection of
                Selection p1 p2 ->
                    ArrayUtil.indent -model.indentationOffset p1.line p2.line model.lines

                _ ->
                    model.lines
    in
    { model | lines = newLines }



-- CURSOR MOVES --


firstLine : EditorModel -> ( EditorModel, Cmd EMsg )
firstLine model =
    ( { model | cursor = Cursor.updateHeadWithPosition { line = 0, column = 0 } model.cursor} , scrollToTopForElement "__editor__" )


goToLine : Int -> EditorModel -> ( EditorModel, Cmd EMsg )
goToLine line model =
    let
        length =
            Array.length model.lines

        index =
            min (length - 1) (line - 1)
                |> max 0
    in
    ( { model | cursor = Cursor.updateHeadWithPosition { line = index, column = 0 } model.cursor }, scrollToLine model.lineHeight (index - model.verticalScrollOffset) )


lastLine : EditorModel -> ( EditorModel, Cmd EMsg )
lastLine model =
    let
        lastLineIndex =
            Array.length model.lines - 1
    in
    ( { model | cursor = Cursor.updateHeadWithPosition { line = lastLineIndex, column = 0 } model.cursor }, scrollToLine model.lineHeight lastLineIndex )


moveToLineEnd : EditorModel -> ( EditorModel, Cmd EMsg )
moveToLineEnd model =
    let
      pos = Cursor.position model.cursor
      newPos =   { pos | column = lineEnd pos.line model + 1 }
    in
    ( { model | cursor = Cursor.updateHeadWithPosition newPos model.cursor }, Cmd.none )


moveToLineStart : EditorModel -> ( EditorModel, Cmd EMsg )
moveToLineStart model =
    let
        pos = Cursor.position model.cursor
        newPos =   { pos | column = 0 }
    in
    ( { model | cursor = Cursor.updateHeadWithPosition newPos model.cursor }, Cmd.none )


pageDown : EditorModel -> ( EditorModel, Cmd EMsg )
pageDown model =
    let
        pos = Cursor.position model.cursor


        lpp =
            linesPerPage model

        lastIndex =
            Array.length model.lines - 1

        newLine =
            min lastIndex (pos.line + lpp)

        newCursor =
           Cursor.updateHeadWithPosition { line = newLine, column = 0 } model.cursor

        newY =
            yValueOfLine model.lineHeight pos.line + model.height - 3 * model.lineHeight
    in
    ( { model | cursor = newCursor }, scrollToYCoordinate newY )


pageUp : EditorModel -> ( EditorModel, Cmd EMsg )
pageUp model =
    let
        pos = Cursor.position model.cursor

        lpp =
            linesPerPage model

        newLine =
            max 0 (pos.line - lpp)

        newCursor =
            Cursor.updateHeadWithPosition { line = newLine, column = 0 } model.cursor

        newY =
            yValueOfLine model.lineHeight pos.line - model.height - 1 * model.lineHeight
    in
    ( { model | cursor = newCursor }, scrollToYCoordinate newY )



-- SELECTION --


selectLine : EditorModel -> ( EditorModel, Cmd EMsg )
selectLine model =
    let
        pos = Cursor.position model.cursor

        line =
            pos.line

        lineEnd_ =
            Array.get line model.lines
                |> Maybe.map String.length
                |> Maybe.withDefault 0
                |> (\x -> x - 1)
    in
    ( { model
        | cursor = Cursor.updateHeadWithPosition { line = line, column = lineEnd_ + 1 } model.cursor
        , selection = Selection { line = line, column = 0 } { line = line, column = lineEnd_ }
      }
    , Cmd.none
    )


deleteSelection : Selection -> Array String -> ( Array String, Array String )
deleteSelection selection array =
    case selection of
        Selection beginSel endSel ->
            ArrayUtil.cut beginSel endSel array
                |> ArrayUtil.joinEnds

        _ ->
            ( array, Array.fromList [ "" ] )


lineEnd : Int -> EditorModel -> Int
lineEnd line model =
    Array.get line model.lines
        |> Maybe.map String.length
        |> Maybe.withDefault 0
        |> (\x -> x - 1)



-- SCROLLING --


scrollToTopForElement : String -> Cmd EMsg
scrollToTopForElement id =
    Task.attempt (\_ -> EditorNoOp) (Dom.setViewportOf id 0 0)


scrollToLine : Float -> Int -> Cmd EMsg
scrollToLine lineHeight n =
    let
        y =
            toFloat n * lineHeight
    in
    Task.attempt (\_ -> EditorNoOp) (Dom.setViewportOf "__editor__" 0 y)


scrollToYCoordinate : Float -> Cmd EMsg
scrollToYCoordinate y =
    Task.attempt (\_ -> EditorNoOp) (Dom.setViewportOf "__editor__" 0 y)


yValueOfLine : Float -> Int -> Float
yValueOfLine lineHeight n =
    toFloat n * lineHeight


linesPerPage : EditorModel -> Int
linesPerPage model =
    floor (model.height / model.lineHeight)



--- CURSOR ACTIONS


cursorRight : EditorModel -> EditorModel
cursorRight model =
     let
         pos = Cursor.position model.cursor
         newPos = Common.moveRight pos model.lines
      in
          { model | cursor = Cursor.updateHeadWithPosition newPos model.cursor}


cursorLeft : EditorModel -> EditorModel
cursorLeft model =
     let
         pos = Cursor.position model.cursor
         newPos = Common.moveLeft pos model.lines
      in
          { model | cursor = Cursor.updateHeadWithPosition newPos model.cursor}



cursorUp : EditorModel -> EditorModel
cursorUp model =
    let
         pos = Cursor.position model.cursor
         newPos = Common.moveUp pos model.lines
      in
          { model | cursor = Cursor.updateHeadWithPosition newPos model.cursor}


cursorDown : EditorModel -> EditorModel
cursorDown model =
    let
         pos = Cursor.position model.cursor
         newPos = Common.moveDown pos model.lines
      in
          { model | cursor = Cursor.updateHeadWithPosition newPos model.cursor}


selectUp : EditorModel -> EditorModel
selectUp model =
    let
        pos = Cursor.position model.cursor

        extendSelection a_ b =
            Selection (Common.moveUp a_ model.lines) b

        newSelection =
            case model.selection of
                Selection a b ->
                    extendSelection a b

                _ ->
                    extendSelection pos pos
    in
    { model | selection = newSelection }


selectDown : EditorModel -> EditorModel
selectDown model =
    let
        pos = Cursor.position model.cursor

        extendSelection a b_ =
            Selection a (Common.moveDown b_ model.lines)

        newSelection =
            case model.selection of
                Selection a b ->
                    extendSelection a b

                _ ->
                    extendSelection pos pos
    in
    { model | selection = newSelection }


selectLeft : EditorModel -> EditorModel
selectLeft model =
    let
        pos = Cursor.position model.cursor

        extendSelection a_ b =
            Selection (Common.moveLeft a_ model.lines) b

        newSelection =
            case model.selection of
                Selection a b ->
                    extendSelection a b

                _ ->
                    extendSelection pos pos
    in
    { model | selection = newSelection }


selectRight : EditorModel -> EditorModel
selectRight model =
    let
        pos = Cursor.position model.cursor

        extendSelection a b_ =
            Selection a (Common.moveRight b_ model.lines)

        newSelection =
            case model.selection of
                Selection a b ->
                    extendSelection a b

                _ ->
                    extendSelection pos pos
    in
    { model | selection = newSelection }
