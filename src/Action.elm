module Action exposing
    ( firstLine
    , scrollToTopForElement
    , selectLine
    )

import Array
import Browser.Dom as Dom
import Model exposing (Model, Msg(..), Selection(..))
import Task exposing (Task)


firstLine : Model -> ( Model, Cmd Msg )
firstLine model =
    ( { model | cursor = { line = 0, column = 0 } }, scrollToTopForElement "__editor__" )


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
