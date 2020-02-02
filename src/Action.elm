module Action exposing
    ( firstLine
    , goToLine
    , lastLine
    , selectLine
    )

import Array
import Browser.Dom as Dom
import Model exposing (Model, Msg(..), Selection(..))
import Task exposing (Task)


firstLine : Model -> ( Model, Cmd Msg )
firstLine model =
    ( { model | cursor = { line = 0, column = 0 } }, scrollToTopForElement "__editor__" )


goToLine : Int -> Model -> ( Model, Cmd Msg )
goToLine line model =
    let
        length =
            Array.length model.lines

        index =
            line - 1
    in
    case index >= 0 && index < length of
        False ->
            ( model, Cmd.none )

        True ->
            ( { model | cursor = { line = index, column = 0 } }, scrollToLine model.lineHeight (index - model.verticalScrollOffset) )


lastLine : Model -> ( Model, Cmd Msg )
lastLine model =
    let
        lastLineIndex =
            Array.length model.lines - 1
    in
    ( { model | cursor = { line = lastLineIndex, column = 0 } }, scrollToLine model.lineHeight lastLineIndex )


selectLine : Model -> ( Model, Cmd Msg )
selectLine model =
    let
        line =
            model.cursor.line

        lineEnd =
            Array.get line model.lines
                |> Maybe.map String.length
                |> Maybe.withDefault 0
                |> (\x -> x - 1)
    in
    ( { model
        | cursor = { line = line, column = 0 }
        , selection = Selection { line = line, column = 0 } { line = line, column = lineEnd }
      }
    , Cmd.none
    )



-- CURSOR
-- SCROLLING


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
