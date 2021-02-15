module UI exposing
    ( elementAttribute
    , exportButton
    , filePopup
    , openFileButton
    , renderedSource
    , saveFileButton
    , setViewPortForSelectedLine
    )

import Browser.Dom as Dom
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events exposing (onClick)
import Model exposing (..)
import Style.Element
import Style.Html exposing (..)
import Task exposing (Task)


label text_ =
    Html.p labelStyle [ Html.text text_ ]


renderedSource : Float -> Float -> Html Msg -> Element Msg
renderedSource width height renderedText =
    Html.div (renderedSourceStyle width height ++ [])
        -- HA.class "rhs"
        [ renderedText ]
        |> html


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


elementAttribute : String -> String -> Attribute msg
elementAttribute key value =
    htmlAttribute (HA.attribute key value)



--
-- BUTTONS
--


clearButton width =
    Html.button ([ onClick Clear ] ++ buttonStyle colorBlue width) [ Html.text "Clear" ]
        |> html


fullRenderButton width =
    Html.button ([ onClick FullRender ] ++ buttonStyle colorBlue width) [ Html.text "Re-render" ]


restoreTextButton width =
    Html.button ([ onClick RestoreText ] ++ buttonStyle colorBlue width) [ Html.text "Restore" ]


exportButton : a -> Element Msg
exportButton width =
    Input.button
        [ mouseDown [ Background.color (rgb255 200 40 40) ]
        , paddingXY 4 8
        ]
        { onPress = Just Export, label = text "Export" }


saveFileButton : a -> Element Msg
saveFileButton width =
    Input.button
        [ mouseDown [ Background.color (rgb255 200 40 40) ]
        , paddingXY 4 8
        ]
        { onPress = Just SaveFile, label = text "Save" }


openFileButton : Int -> Element Msg
openFileButton width =
    Input.button
        [ mouseDown [ Background.color (rgb255 200 40 40) ]
        , paddingXY 4 8
        ]
        { onPress = Just FileRequested, label = text "Open" }


exampleButton width =
    Html.button ([ onClick ExampleText ] ++ buttonStyle colorBlue width) [ Html.text "Example 2" ]


toggleFileButton : Int -> Element Msg
toggleFileButton width =
    Input.button
        [ mouseDown [ Background.color (rgb255 200 40 40) ]
        , paddingXY 4 8
        ]
        { onPress = Just ToggleFilePopup, label = text "File Info" }


filePopup : Model -> Element Msg
filePopup model =
    if model.filePopupOpen then
        column [ inFront (filePopup_ model) ] [ toggleFileButton 100 ]

    else
        toggleFileButton 100


filePopup_ : a -> Element Msg
filePopup_ model =
    column
        [ spacing 12
        , Font.size 14
        , padding 20
        , Font.color (Style.Element.gray 0.1)
        , alignBottom
        , height (px 300)
        , width (px 300)
        , Background.color (rgb 0.95 0.95 1.0)
        , moveUp 320
        ]
        [ text "XXXX"
        ]
