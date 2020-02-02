module Action exposing (firstLine, scrollToTopForElement)

import Browser.Dom as Dom
import Model exposing (Model, Msg(..))
import Task exposing (Task)


firstLine : Model -> ( Model, Cmd Msg )
firstLine model =
    ( { model | cursor = { line = 0, column = 0 } }, scrollToTopForElement "__editor__" )



-- SCROLLING


scrollToTopForElement : String -> Cmd Msg
scrollToTopForElement id =
    Task.attempt (\_ -> NoOp) (Dom.setViewportOf id 0 0)
