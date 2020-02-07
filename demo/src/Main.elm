module Main exposing (main)

import Array exposing (Array)
import Browser
import Browser.Dom as Dom
import Cmd.Extra
import ContextMenu exposing (Item(..))
import Diff exposing (Change)
import Editor exposing (Editor)
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Html.Events as HE
import Model exposing (Msg(..))
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
    , lines : List String
    , diffedLines : List (Change String)
    , numberOfTestLines : Maybe Int
    }


type Msg
    = NoOp
    | EditorMsg Editor.EditorMsg
    | TestLines
    | InputNumberOfLines String


init : Flags -> ( Model, Cmd Msg )
init =
    \() ->
        { editor = Editor.init config |> Tuple.first
        , numberOfTestLines = Nothing
        , lines = []
        , diffedLines = []
        }
            |> Cmd.Extra.withCmds
                [ Dom.focus "editor" |> Task.attempt (always NoOp)
                ]


config =
    { width = 800
    , height = 400
    , fontSize = 20
    , verticalScrollOffset = 3
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    ContextMenu.subscriptions (Editor.getContextMenu model.editor)
        |> Sub.map ContextMenuMsg
        |> Sub.map EditorMsg


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
            case editorMsg of
                Unload _ ->
                    let
                        newLines =
                            Editor.getLines newEditor |> Array.toList

                        diffedLines =
                            --Debug.log "DIFF" <|
                            Diff.diff model.lines newLines
                    in
                    ( { model | editor = newEditor, lines = newLines, diffedLines = diffedLines }, Cmd.map EditorMsg cmd )

                _ ->
                    ( { model | editor = newEditor }, Cmd.map EditorMsg cmd )

        TestLines ->
            case model.numberOfTestLines of
                Nothing ->
                    ( model, Cmd.none )

                Just n ->
                    ( { model | editor = Editor.loadArray (testLines n) model.editor }, Cmd.none )

        InputNumberOfLines str ->
            ( { model | numberOfTestLines = String.toInt str }, Cmd.none )


view : Model -> Html Msg
view model =
    H.div
        [ HA.style "margin" "50px"
        , HA.style "display" "flex"
        , HA.style "flex-direction" "column"
        ]
        [ Editor.view model.editor |> H.map EditorMsg
        , viewFooter model
        ]


viewFooter : Model -> Html Msg
viewFooter model =
    H.div
        [ HA.style "display" "flex"
        , HA.style "font-family" "monospace"
        , HA.style "margin-bottom" "20px"
        ]
        [ rowButton 100 "Add test lines: " TestLines [ HA.style "margin-left" "24px", HA.style "margin-top" "4px" ]
        , textField 40 "n" InputNumberOfLines [ HA.style "margin-left" "4px", HA.style "margin-top" "4px" ] [ HA.style "font-size" "14px" ]
        ]


rowButton width str msg attr =
    H.div (rowButtonStyle ++ attr)
        [ H.button ([ HE.onClick msg ] ++ rowButtonLabelStyle width) [ H.text str ] ]


textField width str msg attr innerAttr =
    H.div ([ HA.style "margin-bottom" "10px" ] ++ attr)
        [ H.input
            ([ HA.style "height" "18px"
             , HA.style "width" (String.fromInt width ++ "px")
             , HA.type_ "text"
             , HA.placeholder str
             , HA.style "margin-right" "8px"
             , HE.onInput msg
             ]
                ++ innerAttr
            )
            []
        ]


rowButtonStyle =
    [ HA.style "font-size" "12px"
    , HA.style "border" "none"
    ]


rowButtonLabelStyle width =
    [ HA.style "font-size" "12px"
    , HA.style "background-color" "#666"
    , HA.style "color" "#eee"
    , HA.style "width" (String.fromInt width ++ "px")
    , HA.style "height" "24px"
    , HA.style "border" "none"
    ]



-- TEST


testLines n =
    Array.fromList (List.repeat n "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")


loremIpsum =
    """


Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce feugiat non eros
eu vehicula. Nullam non metus congue, mattis nisi tempus, volutpat diam. Proin
rutrum arcu ut dolor egestas commodo. Nunc lacinia nec magna id rutrum. In id
orci eu arcu ultrices vulputate nec eget leo. Nunc porttitor enim augue, id
iaculis magna blandit at. Donec eu sem non libero vestibulum volutpat a sed
magna.

Etiam sit amet odio et odio placerat finibus sit amet non mauris. Integer quis
lacus ut massa sodales maximus imperdiet vel ex. Etiam efficitur ipsum id
lacinia aliquet. Pellentesque habitant morbi tristique senectus et netus et
malesuada fames ac turpis egestas. Suspendisse potenti. Vivamus blandit mollis
luctus. Sed nisl risus, lobortis ut leo id, vestibulum interdum est. Phasellus
posuere lorem nulla, et congue augue pharetra in.

Curabitur faucibus nisi metus, sit amet lacinia augue pharetra id. Nullam
rhoncus lacus ut varius vestibulum. Nam non porttitor enim, id porttitor urna.
Fusce id pellentesque erat. Pellentesque feugiat auctor erat, ut eleifend risus
porta ac. Pellentesque nec tempus nulla. Vivamus lobortis dui vitae rutrum
bibendum.

Praesent semper enim arcu, vitae dictum tortor fermentum ac. Proin varius
viverra massa, vel cursus justo malesuada eu. Maecenas volutpat at ligula vel
lobortis. Aenean justo ligula, congue ac consectetur eget, tincidunt feugiat
urna. Vivamus semper tortor quis odio viverra tempor. Aliquam sit amet dui quis
lectus viverra tincidunt in at enim. Nullam volutpat sem sit amet auctor rutrum.
Duis dictum turpis non risus vulputate, quis iaculis ligula vulputate.
Vestibulum ut accumsan nibh. Donec ullamcorper vitae nulla non semper. Proin
quis risus nisi.

Morbi bibendum lacus luctus diam ornare gravida. Aenean tortor augue, ultrices
ornare pretium non, tempus ut augue. Nulla a urna nec elit lacinia fringilla.
Etiam fermentum aliquam sollicitudin. Nam suscipit turpis a vestibulum egestas.
Aenean elementum mollis quam, sit amet laoreet tortor. Nunc eros justo, euismod
vitae nisl quis, molestie tempor est. Donec dapibus condimentum massa, sed
imperdiet libero commodo in. Vivamus bibendum egestas massa, quis interdum mi.
Nunc feugiat volutpat lorem. Duis lacinia sapien non cursus varius. Sed lectus
purus, viverra et enim eu, sagittis suscipit sapien. Sed risus nisi, dictum eu
elit in, dignissim lobortis lacus. Aliquam sed malesuada felis.

Cras nulla dolor, iaculis id ornare at, egestas nec ipsum. Pellentesque in
dignissim tellus. Curabitur id gravida lacus. Praesent vitae quam facilisis mi
commodo posuere eu sit amet turpis. Phasellus pretium, diam sit amet hendrerit
viverra, tellus sem bibendum massa, luctus pretium turpis augue et lacus. Nulla
pharetra mi nunc, non vestibulum ex tristique a. Proin dui elit, luctus sed
luctus id, finibus et est. Donec finibus hendrerit feugiat. Quisque vulputate
turpis arcu, eu consequat enim congue sit amet. Nulla at leo justo. Proin
sollicitudin augue ante, id interdum lacus tempor et. Aliquam auctor ligula nec
dui tincidunt luctus. In eu dui vel odio pellentesque blandit. Nam vestibulum
faucibus consectetur. Donec fringilla erat sapien, sed fringilla ipsum ultricies
eget. Proin dapibus leo sit amet cursus venenatis. Pellentesque gravida ante non
risus faucibus, sed tincidunt diam vulputate. Integer non.
"""
