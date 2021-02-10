module Helper.Scroll exposing
    ( getElementWithViewPort
    , scrollEditorToLine
    , scrollToTopForElement
    , setViewPortForSelectedLineInRenderedText
    , setViewportForElementInRenderedText
    , toEditorTop
    , toRenderedTextTop
    , verticalOffsetInRenderedText
    )

import Browser.Dom as Dom
import Editor
import Task exposing (Task)
import Model exposing(Model, Msg(..))



-- SCROLLING


setViewportForElementInRenderedText : String -> Cmd Msg
setViewportForElementInRenderedText id =
    Dom.getViewportOf "__RENDERED_TEXT__"
        |> Task.andThen (\vp -> getElementWithViewPort vp id)
        |> Task.attempt SetViewPortForElement


toEditorTop : Cmd Msg
toEditorTop =
    scrollToTopForElement "__editor__"


toRenderedTextTop : Cmd Msg
toRenderedTextTop =
    scrollToTopForElement "__RENDERED_TEXT__"


scrollToTopForElement : String -> Cmd Msg
scrollToTopForElement id =
    Task.attempt (\_ -> NoOp) (Dom.setViewportOf id 0 0)


getElementWithViewPort : Dom.Viewport -> String -> Task Dom.Error ( Dom.Element, Dom.Viewport )
getElementWithViewPort vp id =
    Dom.getElement id
        |> Task.map (\el -> ( el, vp ))


setViewPortForSelectedLineInRenderedText : Dom.Element -> Dom.Viewport -> Cmd Msg
setViewPortForSelectedLineInRenderedText element viewport =
    let
        y =
            viewport.viewport.y + element.element.y - verticalOffsetInRenderedText
    in
    Task.attempt (\_ -> NoOp) (Dom.setViewportOf "__RENDERED_TEXT__" 0 y)


scrollEditorToLine : Model -> Int -> Cmd Msg
scrollEditorToLine model line =
    let
        y =
            Editor.getLineHeight model.editor * toFloat line - verticalOffsetInRenderedText
    in
    Task.attempt (\_ -> NoOp) (Dom.setViewportOf "__editor__" 0 y)


verticalOffsetInRenderedText : number
verticalOffsetInRenderedText =
    140
