module Keymap exposing (Keymap, keymaps)

import Dict exposing (Dict)
import Model exposing (Msg(..))


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
            , ( "Enter", Insert "\n" )

            --, ( "Home", CursorToLineStart )
            --, ( "End", CursorToLineEnd )
            --, ( "Tab", Indent )
            ]
    , shift =
        Dict.fromList
            [--( "ArrowUp", SelectUp )
             --, ( "ArrowDown", SelectDown )
             --, ( "ArrowLeft", SelectLeft )
             --, ( "ArrowRight", SelectRight )
             --, ( "Tab", Deindent )
             --, ( "Home", SelectToLineStart )
             --, ( "End", SelectToLineEnd )
            ]
    , option =
        Dict.fromList
            [--( "ArrowUp", ScrollUp 20 )
             --, ( "ArrowDown", ScrollDown 20 )
             --, ( "ArrowLeft", CursorToLineStart )
             --, ( "ArrowRight", CursorToLineEnd )
            ]
    , controlAndOption =
        Dict.fromList
            [--( "ArrowUp", FirstLine )
             --, ( "ArrowDown", LastLine )
             --, ( "ArrowRight", CursorToGroupEnd )
             --, ( "ArrowLeft", CursorToGroupStart )
             --, ( "∑", ToggleWrapping )
             --, ( "ç", Clear )
            ]
    , control =
        Dict.fromList
            [--( "Backspace", RemoveGroupBefore )
             --, ( "Delete", RemoveGroupAfter )
             --, ( "d", SelectGroup )
             --, ( "c", Copy )
             --, ( "g", ToggleGoToLinePanel )
             --, ( ".", RollSearchSelectionForward )
             --, ( ",", RollSearchSelectionBackward )
             --, ( "h", ToggleHelp )
             --, ( "x", Cut )
             --, ( "s", ToggleSearchPanel )
             --, ( "r", ToggleReplacePanel )
             --, ( "v", Paste )
             --, ( "z", Undo )
             --, ( "w", WrapSelection )
             --, ( "y", Redo )
            ]
    , controlAndShift =
        Dict.fromList
            [--( "ArrowRight", SelectToGroupEnd )
             --, ( "ArrowLeft", SelectToGroupStart )
             --, ( "C", WriteToSystemClipBoard )
             --, ( "I", ToggleInfoPanel )
             --, ( "V", CopyPasteClipboard )
             --, ( "W", WrapAll )
             --, ( "S", SendLine )
             --, ( "A", SelectAll )
            ]
    }
