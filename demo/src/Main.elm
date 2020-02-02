module Main exposing (main)

import Array exposing (Array)
import Browser
import Browser.Dom as Dom
import Editor exposing (Editor)
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Task


type alias Flags =
    ()


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { editor : Editor
    }


type Msg
    = NoOp
    | EditorMsg Editor.EditorMsg


init : Flags -> ( Model, Cmd Msg )
init =
    \() ->
        ( { editor = Editor.init { width = 800, height = 200 } }
        , Dom.focus "editor"
            |> Task.attempt (always NoOp)
        )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        EditorMsg editorMsg ->
            let
                ( newEditor, cmd ) =
                    Editor.update editorMsg model.editor
            in
            ( { model | editor = newEditor }, Cmd.map EditorMsg cmd )


view : Model -> Html Msg
view model =
    H.div [ HA.style "margin" "50px" ]
        [ Editor.view model.editor |> H.map EditorMsg
        ]
