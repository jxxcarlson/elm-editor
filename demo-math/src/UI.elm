module UI exposing(renderedSource, setViewPortForSelectedLine)

import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events exposing (onClick, onInput)
import Style.Html exposing(..)
import Model exposing(..)
import Browser.Dom as Dom
import Element exposing(Element)
import Task exposing(Task)



label text_ =
    p labelStyle [ text text_ ]



renderedSource : Float -> Float ->  Html Msg -> Element Msg
renderedSource width height renderedText =
    (Html.div (renderedSourceStyle width height ++ [ ]) -- HA.class "rhs" 
        [ renderedText ]) |> Element.html


setViewportForElement : String -> Cmd Msg
setViewportForElement id =
    Dom.getViewportOf "__RENDERED_TEXT__"
        |> Task.andThen (\vp -> getElementWithViewPort vp id)
        |> Task.attempt SetViewPortForElement


setViewPortForSelectedLine : Dom.Element -> Dom.Viewport -> Cmd Msg
setViewPortForSelectedLine element viewport =
    let
        y =
            viewport.viewport.y + element.element.y - element.element.height - 100
    in
    Task.attempt (\_ -> NoOp) (Dom.setViewportOf "__RENDERED_TEXT__" 0 y)


getElementWithViewPort : Dom.Viewport -> String -> Task Dom.Error ( Dom.Element, Dom.Viewport )
getElementWithViewPort vp id =
    Dom.getElement id
        |> Task.map (\el -> ( el, vp ))




--
-- BUTTONS
--


clearButton width =
    button ([ onClick Clear ] ++ buttonStyle colorBlue width) [ text "Clear" ]


fullRenderButton width =
    button ([ onClick FullRender ] ++ buttonStyle colorBlue width) [ text "Re-render" ]


restoreTextButton width =
    button ([ onClick RestoreText ] ++ buttonStyle colorBlue width) [ text "Restore" ]


exportButton width =
    button ([ onClick Export ] ++ buttonStyle colorBlue width) [ text "Export" ]


exampleButton width =
    button ([ onClick ExampleText ] ++ buttonStyle colorBlue width) [ text "Example 2" ]

