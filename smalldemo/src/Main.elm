module Main exposing (main)

import Browser
import Html exposing (Html)
import Http
import Editor exposing (Editor)
import Helpers.Load as Load
import Element exposing (Element, column, text)
import Text



-- MAIN


main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }



-- MODEL


type alias Model
  = {
      editor: Editor
  }


init : () -> (Model, Cmd Msg)
init _ =
    let
        newEditor =
            Editor.initWithContent (Text.numbered Text.darwin) Load.config
    in
  ( {editor = newEditor}
  , Cmd.none
  )



-- UPDATE


type Msg =
    MyEditorMsg Editor.EditorMsg


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MyEditorMsg editorMsg ->
        let
            ( newEditor, cmd ) =
                Editor.update editorMsg model.editor
        in
        ({model | editor = newEditor}, Cmd.map MyEditorMsg cmd)




-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    Element.layout []
    <| column []
    [
        Element.el [] (viewEditor model)
    ]


viewEditor : Model -> Element Msg
viewEditor model =
    Editor.view model.editor |> Html.map MyEditorMsg |> Element.html
