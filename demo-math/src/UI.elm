module UI exposing
    ( elementAttribute
    , exportButton
    , fullRenderButton
    , loadDocumentButton
    , newDocumentPopup
    , openFileButton
    , renderedSource
    , saveFileButton
    , setViewPortForSelectedLine
    )

import Browser.Dom as Dom
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input exposing (labelAbove)
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
    Input.button
        [ mouseDown [ Background.color (rgb255 200 40 40) ]
        , paddingXY 4 8
        ]
        { onPress = Just FullRender, label = text "Render" }


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


toggleFileButton : Model -> Int -> Element Msg
toggleFileButton model w =
    let
        label_ =
            if model.filePopupOpen then
                "Cancel"

            else
                "New document"
    in
    Input.button
        [ mouseDown [ Background.color (rgb255 200 40 40) ]
        , paddingXY 4 8
        , width (px w)
        ]
        { onPress = Just ToggleFilePopup, label = text label_ }


loadDocumentButton : String -> Element Msg
loadDocumentButton fileName =
    Input.button
        [ mouseDown [ Background.color (rgb255 200 40 40) ]
        , paddingXY 8 8

        -- , width (px 100)
        ]
        { onPress = Just (LoadDocument fileName), label = text fileName }


setRenderingModeButton : DocumentType -> DocumentType -> Element Msg
setRenderingModeButton currentMode newMode =
    let
        label_ =
            case newMode of
                MiniLaTeX ->
                    "MiniLaTeX"

                MathMarkdown ->
                    "MathMarkdown"

                CaYaTeX -> "CaYaTeX"

                PlainText ->
                    "Plain Text"

        bgColor =
            if currentMode == newMode then
                rgb255 120 0 0

            else
                Style.Element.gray 0.2
    in
    Input.button
        [ mouseDown [ Background.color (rgb255 40 200 40) ]
        , Background.color bgColor
        , width (px 120)
        , Font.color (Style.Element.gray 0.8)
        , paddingXY 8 8
        ]
        { onPress = Just (NewDocument newMode), label = text label_ }


newDocumentPopup : Model -> Element Msg
newDocumentPopup model =
    if model.filePopupOpen then
        column [ inFront (newDocumentPopup_ model) ]
            [ toggleFileButton model 100
            ]

    else
        toggleFileButton model 100


newDocumentPopup_ : Model -> Element Msg
newDocumentPopup_ model =
    column
        [ spacing 8
        , Font.size 14
        , padding 20
        , Font.color (Style.Element.gray 0.9)
        , alignBottom
        , height (px 130)
        , width (px 400)
        , Background.color (Style.Element.gray 0.2)
        , moveUp 170
        , moveLeft 80
        ]
        [ inputFilename model
        , row [ spacing 24, Font.color (Style.Element.gray 0.9) ] [ makeNewFileButton, cancelNewFileButton ]
        ]


inputFilename model =
    Input.text [ Element.height (px 35), Font.color (Style.Element.gray 0.2) ]
        { onChange = GotFilename
        , text = model.newFilename
        , placeholder = Nothing
        , label = labelAbove [] (text "File name")
        }


makeNewFileButton : Element Msg
makeNewFileButton =
    Input.button
        [ mouseDown [ Font.color (Style.Element.gray 0.9), Background.color (Element.rgb 0.7 0 0) ]
        , Font.color (Style.Element.gray 0.9)
        , Element.height (px 30)
        , Background.color (Style.Element.gray 0.4)
        , paddingXY 8 0
        ]
        { onPress = Just MakeNewfile, label = text "New" }


cancelNewFileButton : Element Msg
cancelNewFileButton =
    Input.button
        [ mouseDown [ Font.color (Style.Element.gray 0.9), Background.color (Element.rgb 0.7 0 0) ]
        , Element.height (px 30)
        , Font.color (Style.Element.gray 0.9)
        , Background.color (Style.Element.gray 0.4)
        , paddingXY 8 8
        ]
        { onPress = Just CancelNewfile, label = text "Cancel" }
