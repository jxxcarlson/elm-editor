module EditorMsg exposing (EMsg(..), Context(..), Hover(..), Position, Selection(..), WrapOption(..))

{-|

@docs EMsg, Context, Hover, Position, Selection, WrapOption

-}

import Browser.Dom as Dom
import ContextMenu
import Debounce
import File exposing (File)
import Markdown.Render exposing (MarkdownMsg(..))
import Vim


{-| Cursor position
-}
type alias Position =
    { line : Int
    , column : Int
    }


{-| For the context menu
-}
type Context
    = Object
    | Background


{-| Mouuse hover states
-}
type Hover
    = NoHover
    | HoverLine Int
    | HoverChar Position


{-| Selected text
-}
type Selection
    = NoSelection
    | SelectingFrom Hover
    | SelectedChar Position
    | Selection Position Position


{-| -}
type WrapOption
    = DoWrap
    | DontWrap


{-| Messages that the editor responds to
-}
type EMsg
    = EditorNoOp
      -- 68 msg below
    | ExitVimInsertMode
    | MoveUp
    | MoveDown
    | MoveLeft
    | MoveRight
    | MoveToLineStart
    | MoveToLineEnd
    | PageUp
    | PageDown
    | FirstLine
    | LastLine
    | GoToLine
      --
    | NewLine
    | InsertChar String
    | Indent
    | Deindent
      --
    | RemoveCharBefore
    | RemoveCharAfter
    | KillLine
    | KillLineAlt
    | DeleteLine
    | Cut
    | Copy
    | Paste
    | WrapAll
    | WrapSelection
      --
    | Hover Hover
    | GoToHoveredPosition
      --
    | StartSelecting
    | StopSelecting
    | SelectLine
    | SelectUp
    | SelectDown
    | SelectLeft
    | SelectRight
    | SelectGroup
      --
    | Undo
    | Redo
      --
    | AcceptLineToGoTo String
      -- Debouncer
    | DebounceMsg Debounce.Msg
    | Unload String
      --
    | Clear
    | Test
      --
    | ContextMenuMsg (ContextMenu.Msg Context)
    | Item Int
    | ToggleAutoLineBreak
      -- File
    | EditorRequestFile
    | EditorRequestedFile File
    | MarkdownLoaded String
    | EditorSaveFile
      --
    | SendLineForLRSync
    | GotViewportForSync (Maybe String) Selection (Result Dom.Error Dom.Viewport)
    | ViewportMotion (Result Dom.Error ())
    | GotViewportInfo (Result Dom.Error Dom.Viewport)
      --
    | CopyPasteClipboard
    | WriteToSystemClipBoard
      -- Search
    | DoSearch String
    | ToggleSearchPanel
    | ToggleReplacePanel
    | OpenReplaceField
    | RollSearchSelectionForward
    | RollSearchSelectionBackward
    | ReplaceCurrentSelection
    | AcceptLineNumber String
    | AcceptSearchText String
    | AcceptReplacementText String
    | GotViewport (Result Dom.Error Dom.Viewport)
      --
    | ToggleDarkMode
    | ToggleHelp
    | ToggleEditMode
    | ToggleShortCutExecution
      --
    | MarkdownMsg MarkdownMsg
      --
    | Vim Vim.VimMsg
