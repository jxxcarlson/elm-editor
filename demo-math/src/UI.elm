module UI exposing
    ( elementAttribute
    , exportButton
    , openFileButton
    , renderedSource
    , saveFileButton
    , setViewPortForSelectedLine
    )

import Browser.Dom as Dom
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Input as Input
import Html exposing (..)
import Html.Attributes as HA
import Html.Events exposing (onClick)
import Model exposing (..)
import Style.Html exposing (..)
import Task exposing (Task)


label text_ =
    p labelStyle [ text text_ ]


renderedSource : Float -> Float -> Html Msg -> Element Msg
renderedSource width height renderedText =
    Html.div (renderedSourceStyle width height ++ [])
        -- HA.class "rhs"
        [ renderedText ]
        |> Element.html


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


elementAttribute : String -> String -> Element.Attribute msg
elementAttribute key value =
    Element.htmlAttribute (HA.attribute key value)



--
-- BUTTONS
--


clearButton width =
    button ([ onClick Clear ] ++ buttonStyle colorBlue width) [ text "Clear" ]
        |> Element.html


fullRenderButton width =
    button ([ onClick FullRender ] ++ buttonStyle colorBlue width) [ text "Re-render" ]


restoreTextButton width =
    button ([ onClick RestoreText ] ++ buttonStyle colorBlue width) [ text "Restore" ]


exportButton width =
    Input.button
        [ Element.mouseDown [ Background.color (Element.rgb255 200 40 40) ]
        , Element.paddingXY 4 8
        ]
        { onPress = Just Export, label = Element.text "Export" }


saveFileButton width =
    Input.button
        [ Element.mouseDown [ Background.color (Element.rgb255 200 40 40) ]
        , Element.paddingXY 4 8
        ]
        { onPress = Just SaveFile, label = Element.text "Save" }


openFileButton width =
    Input.button
        [ Element.mouseDown [ Background.color (Element.rgb255 200 40 40) ]
        , Element.paddingXY 4 8
        ]
        { onPress = Just FileRequested, label = Element.text "Open" }


exampleButton width =
    button ([ onClick ExampleText ] ++ buttonStyle colorBlue width) [ text "Example 2" ]
