module Keymap exposing (handle)

import Dict exposing (Dict)
import Html exposing (Attribute)
import Html.Events as HE
import Json.Decode as JD exposing (Decoder)
import Model exposing (Msg(..))


handle : Attribute Msg
handle =
    HE.custom "keydown" (JD.map transformMsg keydownDecoder)


transformMsg : a -> { message : a, stopPropagation : Bool, preventDefault : Bool }
transformMsg msg =
    { message = msg, stopPropagation = True, preventDefault = True }


alwaysMsg : msg -> ( msg, Bool )
alwaysMsg msg =
    ( msg, True )


type alias Keydown =
    { char : Maybe String
    , key : String
    , modifier : Modifier
    }


type Modifier
    = None
    | Control
    | Option
    | Shift
    | ControlAndShift
    | ControlAndOption


keydownDecoder : Decoder Msg
keydownDecoder =
    JD.map3 Keydown
        characterDecoder
        (JD.field "key" JD.string)
        modifierDecoder
        |> JD.andThen keyToMsg


characterDecoder : Decoder (Maybe String)
characterDecoder =
    JD.field "key" JD.string
        |> JD.map
            (\key ->
                case String.uncons key of
                    Just ( char, "" ) ->
                        Just (String.fromChar char)

                    _ ->
                        Nothing
            )


modifierDecoder : Decoder Modifier
modifierDecoder =
    JD.map3 modifierFromFlags
        (JD.field "ctrlKey" JD.bool)
        (JD.field "shiftKey" JD.bool)
        (JD.field "altKey" JD.bool)


modifierFromFlags : Bool -> Bool -> Bool -> Modifier
modifierFromFlags ctrl shift option =
    case ( ctrl, shift, option ) of
        ( True, True, False ) ->
            ControlAndShift

        ( False, True, False ) ->
            Shift

        ( True, False, False ) ->
            Control

        ( False, False, True ) ->
            Option

        ( True, False, True ) ->
            ControlAndOption

        ( _, _, _ ) ->
            None


keyToMsg : Keydown -> Decoder Msg
keyToMsg { char, key, modifier } =
    let
        _ =
            Debug.log "(c, k, m)" ( char, key, modifier )

        keyFrom keymap =
            Dict.get key keymap
                |> Maybe.map JD.succeed
                |> Maybe.withDefault (JD.fail "This key does nothing")

        keyOrCharFrom keymap =
            JD.oneOf
                [ keyFrom keymap
                , char
                    |> Maybe.map (InsertChar >> JD.succeed)
                    |> Maybe.withDefault
                        (JD.fail "This key does nothing")
                ]
    in
    case modifier of
        None ->
            keyOrCharFrom keymaps.noModifier

        Control ->
            keyFrom keymaps.control

        Shift ->
            keyOrCharFrom keymaps.shift

        ControlAndShift ->
            keyFrom keymaps.controlAndShift

        ControlAndOption ->
            keyFrom keymaps.controlAndOption

        Option ->
            keyFrom keymaps.option


type alias Keymap =
    Dict String Msg


keymaps :
    { noModifier : Keymap
    , shift : Keymap
    , option : Keymap
    , control : Keymap
    , controlAndShift : Keymap
    , controlAndOption : Keymap
    }
keymaps =
    { noModifier =
        Dict.fromList
            [ ( "ArrowUp", MoveUp )
            , ( "ArrowDown", MoveDown )
            , ( "ArrowLeft", MoveLeft )
            , ( "ArrowRight", MoveRight )
            , ( "Backspace", RemoveCharBefore )
            , ( "Delete", RemoveCharAfter )
            , ( "Enter", NewLine )
            , ( "Home", MoveToLineStart )
            , ( "End", MoveToLineEnd )

            --, ( "Tab", Indent )
            ]
    , shift =
        Dict.fromList
            [-- ( "ArrowUp", SelectUp )
             --, ( "ArrowDown", SelectDown )
             --, ( "ArrowLeft", SelectLeft )
             --, ( "ArrowRight", SelectRight )
             --, ( "Tab", Deindent )
             --, ( "Home", SelectToLineStart )
             --, ( "End", SelectToLineEnd )
            ]
    , option =
        Dict.fromList
            [ ( "ArrowUp", PageUp )
            , ( "ArrowDown", PageDown )
            , ( "ArrowLeft", MoveToLineStart )
            , ( "ArrowRight", MoveToLineEnd )
            ]
    , controlAndOption =
        Dict.fromList
            [ ( "ArrowUp", FirstLine )
            , ( "ArrowDown", LastLine )

            --, ( "ArrowRight", CursorToGroupEnd )
            --, ( "ArrowLeft", CursorToGroupStart )
            --, ( "∑", ToggleWrapping )
            , ( "ç", Clear )
            , ( "t", Test )
            ]
    , control =
        Dict.fromList
            [ -- ( "Backspace", RemoveGroupBefore )
              --, ( "Delete", RemoveGroupAfter )
              --, ( "d", SelectGroup )
              ( "c", Copy )

            --, ( "g", ToggleGoToLinePanel )
            --, ( ".", RollSearchSelectionForward )
            --, ( ",", RollSearchSelectionBackward )
            --, ( "h", ToggleHelp )
            , ( "x", Cut )

            --, ( "s", ToggleSearchPanel )
            --, ( "r", ToggleReplacePanel )
            , ( "d", RemoveCharAfter )
            , ( "k", KillLine )
            , ( "v", Paste )
            , ( "a", MoveToLineStart )
            , ( "e", MoveToLineEnd )
            , ( "z", Undo )

            --, ( "w", WrapSelection )
            , ( "y", Redo )
            ]
    , controlAndShift =
        Dict.fromList
            [-- ( "ArrowRight", SelectToGroupEnd )
             --, ( "ArrowLeft", SelectToGroupStart )
             --, ( "C", WriteToSystemClipBoard )
             --, ( "V", CopyPasteClipboard )
             --, ( "W", WrapAll )
             --, ( "S", SendLine )
             --, ( "A", SelectAll )
            ]
    }
