module Action exposing
    ( deleteSelection
    , firstLine
    , goToLine
    , lastLine
    , moveToLineEnd
    , moveToLineStart
    , pageDown
    , pageUp
    , scrollToLine
    , selectLine
    )

import Array exposing (Array)
import ArrayUtil
import Browser.Dom as Dom
import Model exposing (Model, Msg(..), Selection(..))
import Task exposing (Task)



-- CURSOR MOVES --


firstLine : Model -> ( Model, Cmd Msg )
firstLine model =
    ( { model | cursor = { line = 0, column = 0 } }, scrollToTopForElement "__editor__" )


goToLine : Int -> Model -> ( Model, Cmd Msg )
goToLine line model =
    let
        length =
            Array.length model.lines

        index =
            min (length - 1) (line - 1)
                |> max 0
    in
    ( { model | cursor = { line = index, column = 0 } }, scrollToLine model.lineHeight (index - model.verticalScrollOffset) )


lastLine : Model -> ( Model, Cmd Msg )
lastLine model =
    let
        lastLineIndex =
            Array.length model.lines - 1
    in
    ( { model | cursor = { line = lastLineIndex, column = 0 } }, scrollToLine model.lineHeight lastLineIndex )


moveToLineEnd : Model -> ( Model, Cmd Msg )
moveToLineEnd model =
    ( { model | cursor = { line = model.cursor.line, column = lineEnd model.cursor.line model } }, Cmd.none )


moveToLineStart : Model -> ( Model, Cmd Msg )
moveToLineStart model =
    ( { model | cursor = { line = model.cursor.line, column = 0 } }, Cmd.none )


pageDown : Model -> ( Model, Cmd Msg )
pageDown model =
    let
        lpp =
            linesPerPage model

        lastIndex =
            Array.length model.lines - 1

        newLine =
            min lastIndex (model.cursor.line + lpp)

        newCursor =
            { line = newLine, column = 0 }

        newY =
            yValueOfLine model.lineHeight model.cursor.line + model.height - 3 * model.lineHeight
    in
    ( { model | cursor = newCursor }, scrollToYCoordinate newY )


pageUp : Model -> ( Model, Cmd Msg )
pageUp model =
    let
        lpp =
            linesPerPage model

        newLine =
            max 0 (model.cursor.line - lpp)

        newCursor =
            { line = newLine, column = 0 }

        newY =
            yValueOfLine model.lineHeight model.cursor.line - model.height - 1 * model.lineHeight
    in
    ( { model | cursor = newCursor }, scrollToYCoordinate newY )



-- SELECTION --


selectLine : Model -> ( Model, Cmd Msg )
selectLine model =
    let
        line =
            model.cursor.line

        lineEnd_ =
            Array.get line model.lines
                |> Maybe.map String.length
                |> Maybe.withDefault 0
                |> (\x -> x - 1)
    in
    ( { model
        | cursor = { line = line, column = 0 }
        , selection = Selection { line = line, column = 0 } { line = line, column = lineEnd_ }
      }
    , Cmd.none
    )


deleteSelection : Selection -> Array String -> ( Array String, Array String )
deleteSelection selection array =
    case selection of
        Selection beginSel endSel ->
            ArrayUtil.cut beginSel endSel array
                |> ArrayUtil.join

        _ ->
            ( array, Array.fromList [ "" ] )


lineEnd : Int -> Model -> Int
lineEnd line model =
    Array.get line model.lines
        |> Maybe.map String.length
        |> Maybe.withDefault 0
        |> (\x -> x - 1)



-- SCROLLING --


scrollToTopForElement : String -> Cmd Msg
scrollToTopForElement id =
    Task.attempt (\_ -> NoOp) (Dom.setViewportOf id 0 0)


scrollToLine : Float -> Int -> Cmd Msg
scrollToLine lineHeight n =
    let
        y =
            toFloat n * lineHeight
    in
    Task.attempt (\_ -> NoOp) (Dom.setViewportOf "__editor__" 0 y)


scrollToYCoordinate : Float -> Cmd Msg
scrollToYCoordinate y =
    Task.attempt (\_ -> NoOp) (Dom.setViewportOf "__editor__" 0 y)


yValueOfLine : Float -> Int -> Float
yValueOfLine lineHeight n =
    toFloat n * lineHeight


linesPerPage : Model -> Int
linesPerPage model =
    floor (model.height / model.lineHeight)
