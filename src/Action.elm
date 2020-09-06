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
import CursorData


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
    ( { model | cursor = CursorData.updateNative { line = 0, column = 0 } model.cursor} , scrollToTopForElement "__editor__" )


goToLine : Int -> EditorModel -> ( EditorModel, Cmd EMsg )
goToLine line model =
    let
        length =
            Array.length model.lines

        index =
            min (length - 1) (line - 1)
                |> max 0
    in
    ( { model | cursor = CursorData.updateNative { line = index, column = 0 } model.cursor }, scrollToLine model.lineHeight (index - model.verticalScrollOffset) )


lastLine : EditorModel -> ( EditorModel, Cmd EMsg )
lastLine model =
    let
        lastLineIndex =
            Array.length model.lines - 1
    in
    ( { model | cursor = CursorData.updateNative { line = lastLineIndex, column = 0 } model.cursor }, scrollToLine model.lineHeight lastLineIndex )


moveToLineEnd : EditorModel -> ( EditorModel, Cmd EMsg )
moveToLineEnd model =
    let
      native =   { line = model.cursor.native.line, column = lineEnd model.cursor.native.line model + 1 }
    in
    ( { model | cursor = {native = native, foreign = model.cursor.foreign} }, Cmd.none )


moveToLineStart : EditorModel -> ( EditorModel, Cmd EMsg )
moveToLineStart model =
    let
        native =   { line = model.cursor.native.line, column = 0 }
    in
    ( { model | cursor = {native = native, foreign = model.cursor.foreign} }, Cmd.none )


pageDown : EditorModel -> ( EditorModel, Cmd EMsg )
pageDown model =
    let
        lpp =
            linesPerPage model

        lastIndex =
            Array.length model.lines - 1

        newLine =
            min lastIndex (model.cursor.native.line + lpp)

        newCursor =
           {native = { line = newLine, column = 0 }, foreign = model.cursor.foreign}

        newY =
            yValueOfLine model.lineHeight model.cursor.native.line + model.height - 3 * model.lineHeight
    in
    ( { model | cursor = newCursor }, scrollToYCoordinate newY )


pageUp : EditorModel -> ( EditorModel, Cmd EMsg )
pageUp model =
    let
        lpp =
            linesPerPage model

        newLine =
            max 0 (model.cursor.native.line - lpp)

        newCursor =
            {native = { line = newLine, column = 0 }, foreign = model.cursor.foreign}

        newY =
            yValueOfLine model.lineHeight model.cursor.native.line - model.height - 1 * model.lineHeight
    in
    ( { model | cursor = newCursor }, scrollToYCoordinate newY )



-- SELECTION --


selectLine : EditorModel -> ( EditorModel, Cmd EMsg )
selectLine model =
    let
        line =
            model.cursor.native.line

        lineEnd_ =
            Array.get line model.lines
                |> Maybe.map String.length
                |> Maybe.withDefault 0
                |> (\x -> x - 1)
    in
    ( { model
        | cursor = CursorData.updateNative { line = line, column = lineEnd_ + 1 } model.cursor
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
              native = Common.moveRight model.cursor.native model.lines
      in
          { model | cursor = {native = native, foreign = model.cursor.foreign} }


cursorLeft : EditorModel -> EditorModel
cursorLeft model =
    let
            native = Common.moveLeft model.cursor.native model.lines
    in
        { model | cursor = {native = native, foreign = model.cursor.foreign} }



cursorUp : EditorModel -> EditorModel
cursorUp model =
    let
        native = Common.moveUp model.cursor.native model.lines
    in
    { model | cursor = {native = native, foreign = model.cursor.foreign} }


cursorDown : EditorModel -> EditorModel
cursorDown model =
    let
            native = Common.moveDown model.cursor.native model.lines
        in
        { model | cursor = {native = native, foreign = model.cursor.foreign} }


selectUp : EditorModel -> EditorModel
selectUp model =
    let
        extendSelection a_ b =
            Selection (Common.moveUp a_ model.lines) b

        newSelection =
            case model.selection of
                Selection a b ->
                    extendSelection a b

                _ ->
                    extendSelection model.cursor.native model.cursor.native
    in
    { model | selection = newSelection }


selectDown : EditorModel -> EditorModel
selectDown model =
    let
        extendSelection a b_ =
            Selection a (Common.moveDown b_ model.lines)

        newSelection =
            case model.selection of
                Selection a b ->
                    extendSelection a b

                _ ->
                    extendSelection model.cursor.native model.cursor.native
    in
    { model | selection = newSelection }


selectLeft : EditorModel -> EditorModel
selectLeft model =
    let
        extendSelection a_ b =
            Selection (Common.moveLeft a_ model.lines) b

        newSelection =
            case model.selection of
                Selection a b ->
                    extendSelection a b

                _ ->
                    extendSelection model.cursor.native model.cursor.native
    in
    { model | selection = newSelection }


selectRight : EditorModel -> EditorModel
selectRight model =
    let
        extendSelection a b_ =
            Selection a (Common.moveRight b_ model.lines)

        newSelection =
            case model.selection of
                Selection a b ->
                    extendSelection a b

                _ ->
                    extendSelection model.cursor.native model.cursor.native
    in
    { model | selection = newSelection }
