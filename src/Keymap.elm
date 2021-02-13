module Keymap exposing (handle)

import Dict exposing (Dict)
import EditorMsg exposing (EMsg(..))
import Html exposing (Attribute)
import Html.Events as HE
import Json.Decode as JD exposing (Decoder)


handle : Attribute EMsg
handle =
    HE.custom "keydown" (JD.map transformMsg keydownDecoder)


transformMsg : a -> { message : a, stopPropagation : Bool, preventDefault : Bool }
transformMsg msg =
    { message = msg, stopPropagation = True, preventDefault = True }


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


keydownDecoder : Decoder EMsg
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


keyToMsg : Keydown -> Decoder EMsg
keyToMsg { char, key, modifier } =
    let
        {- DOC decode  keypresses -}
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

        -- (Nothing,"Escape",None)
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
    Dict String EMsg


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
            , ( "Tab", Indent )
            , ( "Escape", ToggleShortCutExecution )

            --, ( "Escape", ExitVimInsertMode )
            ]
    , shift =
        Dict.fromList
            [ ( "ArrowUp", SelectUp )
            , ( "ArrowDown", SelectDown )
            , ( "ArrowLeft", SelectLeft )
            , ( "ArrowRight", SelectRight )
            , ( "Tab", Deindent )

            --, ( "Home", SelectToLineStart )
            --, ( "End", SelectToLineEnd )
            ]
    , option =
        Dict.fromList
            [ ( "ArrowUp", PageUp )
            , ( "ArrowDown", PageDown )
            , ( "ArrowLeft", MoveToLineStart )
            , ( "ArrowRight", MoveToLineEnd )
            , ( "ß", SendLineForLRSync ) -- option s
            , ( "∂", ToggleDarkMode ) -- option d
            , ( "√", ToggleEditMode ) -- option v

            --, ( "≠", ToggleShortCutExecution )
            ]
    , controlAndOption =
        Dict.fromList
            [ ( "ArrowUp", FirstLine )
            , ( "ArrowDown", LastLine )

            --, ( "ArrowRight", CursorToGroupEnd )
            --, ( "ArrowLeft", CursorToGroupStart )
            --, ( "∑", ToggleWrapping )
            , ( "ç", Clear )
            , ( "ß", EditorSaveFile )
            , ( "t", Test )
            ]
    , control =
        Dict.fromList
            [ -- ( "Backspace", RemoveGroupBefore )
              --, ( "Delete", RemoveGroupAfter )
              ( "j", SelectGroup )
            , ( "c", Copy )

            --, ( "g", ToggleGoToLinePanel )
            , ( ".", RollSearchSelectionForward )
            , ( ",", RollSearchSelectionBackward )
            , ( "h", ToggleHelp )
            , ( "l", SelectLine )
            , ( "x", Cut )
            , ( "s", ToggleSearchPanel )

            --, ( "r", ToggleReplacePanel )
            , ( "d", RemoveCharAfter )
            , ( "k", KillLine )
            , ( "u", DeleteLine )
            , ( "o", EditorRequestFile )
            , ( "v", Paste ) -- TODO:CURRENT
            , ( "a", MoveToLineStart )
            , ( "e", MoveToLineEnd )
            , ( "z", Undo )
            , ( "w", WrapSelection )
            , ( "y", Redo )
            , ( "\\", SendLineForLRSync )
            ]
    , controlAndShift =
        Dict.fromList
            [ -- ( "ArrowRight", SelectToGroupEnd )
              --, ( "ArrowLeft", SelectToGroupStart )
              ( "C", WriteToSystemClipBoard )
            , ( "V", CopyPasteClipboard )
            , ( "W", WrapAll )
            , ( "S", SendLineForLRSync )
            , ( "K", KillLineAlt )

            --, ( "A", SelectAll )
            ]
    }
