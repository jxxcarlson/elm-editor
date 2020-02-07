# A Pure Elm Text Editor

This package offers a pure Elm text editor.
It relies heavily on prior work of 
Martin Janiczek and Sidney Nemzer.  It is a pleasure
to acknowledge their work.


## Embedding the editor

To wire the editor into your app, follow the instructions below.
See `./demo/` in the source code for an example.

## Model

```elm
import Editor exposing (Editor)

type alias Model =
    { editor : Editor
    , ...
    }
```

## Msg 

```elm
type Msg
    = EditorMsg Editor.EditorMsg
    | ...
```

## Configuration

```elm
config =
    { width = 800
    , height = 400
    , fontSize = 20
    , verticalScrollOffset = 3
    }
```

## Init

```elm
init : Flags -> ( Model, Cmd Msg )
init =
    \() ->
        ( { editor = Editor.init config
          , ...
          }
        , Dom.focus "editor"
            |> Task.attempt (always NoOp)
        )

```


## Update

Handle the editor messages to which you app should respond.

```elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of

        EditorMsg editorMsg ->
            let
                ( newEditor, cmd ) =
                    Editor.update editorMsg model.editor
            in
            case editorMsg of
                Whatever foo ->
                    ( { model | editor = newEditor
                            bar = handleFoo model foo }
                     , Cmd.map EditorMsg cmd )

                _ ->
                    ( { model | editor = newEditor }
                     , Cmd.map EditorMsg cmd )
`       ...
```

## View

Sample view function

```elm
view : Model -> Html Msg
view model =
    H.div
        [ HA.style "margin" "50px"
        , HA.style "display" "flex"
        , HA.style "flex-direction" "column"
        ]
        [ Editor.view model.editor |> H.map EditorMsg
        , ...
        , viewFooter model
        ]
```