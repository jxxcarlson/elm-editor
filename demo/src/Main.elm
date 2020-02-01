module Main exposing (main)

import Array exposing (Array)
import Browser
import Browser.Dom as Dom
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Html.Events as HE
import Html.Lazy
import Json.Decode as JD exposing (Decoder)
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
    {
     numberOfLinesToAdd : Maybe Int
    }




type Msg
    =
    | Clear
    | TestLines
    | InputNumberOfLines String



init : Flags -> ( Model, Cmd Msg )
init =
    \() ->
        ( initModel
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

        TestLines ->
            case model.numberOfLinesToAdd of
                Nothing ->
                    ( model, Cmd.none )

                Just n ->
                    ( { model | lines = Array.append model.lines (testLines n) }, Cmd.none )

        InputNumberOfLines str ->
            ( { model | numberOfLinesToAdd = String.toInt str }, Cmd.none )


view : Model -> Html Msg
view model =
    H.div [ HA.style "margin" "50px" ]
        [ viewHeader model
        , viewEditor model
        , viewDebug model
        , viewFooter model
        ]


viewFooter : Model -> Html Msg
viewFooter model =
    H.div
        [ HA.style "display" "flex"
        , HA.style "flex-direction" "column"
        , HA.style "margin-top" "20px"
        ]
        [ H.p [ HA.style "margin-top" "0px" ]
            [ H.text "This demo is an Elm 0.19 version of"
            , H.a [ HA.href "https://janiczek.github.io/elm-editor/" ] [ H.text " Martin Janiczek's elm-editor" ]
            , H.span [] [ H.text ". See also his " ]
            , H.a [ HA.href "https://discourse.elm-lang.org/t/text-editor-done-in-pure-elm/1365/" ] [ H.text " Discourse article" ]
            , H.span [] [ H.text ". " ]
            ]
        , H.p [ HA.style "margin-top" "0px" ]
            [ H.a [ HA.href "https://github.com/jxxcarlson/elm-editor" ] [ H.text "Github repo" ]
            , H.span [] [ H.text " forked from " ]
            , H.a [ HA.href "https://janiczek.github.io/elm-editor/" ] [ H.text " Martin Janiczek. " ]
            ]
        ]


viewHeader : Model -> Html Msg
viewHeader model =
    H.div
        [ HA.style "display" "flex"
        , HA.style "font-family" "monospace"
        , HA.style "margin-bottom" "20px"
        ]
        [ H.span [ HA.style "font-size" "24px" ] [ H.text "Text editor" ]
        , lineNumbersDisplay model
        , wordCountDisplay model
        , rowButton 40 "Clear" Clear [ HA.style "margin-left" "24px", HA.style "margin-top" "4px" ]
        , rowButton 100 "Add test lines: " TestLines [ HA.style "margin-left" "24px", HA.style "margin-top" "4px" ]
        , textField 40 "n" InputNumberOfLines [ HA.style "margin-left" "4px", HA.style "margin-top" "4px" ] [ HA.style "font-size" "14px" ]
        ]


ensureNonBreakingSpace : Char -> Char
ensureNonBreakingSpace char =
    case char of
        ' ' ->
            nonBreakingSpace

        _ ->
            char


{-| The non-breaking space character will not get whitespace-collapsed like a
regular space.
-}
nonBreakingSpace : Char
nonBreakingSpace =
    Char.fromCode 160


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
