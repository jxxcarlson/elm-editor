module EditorMsg exposing (Context(..), EMsg(..), Hover(..), Position, Selection(..))

import Browser.Dom as Dom
import ContextMenu exposing (ContextMenu)
import Debounce exposing (Debounce)
import File exposing (File)
import Markdown.Render exposing (MarkdownMsg(..))


type alias Position =
    { line : Int
    , column : Int
    }


type Context
    = Object
    | Background


type Hover
    = NoHover
    | HoverLine Int
    | HoverChar Position


type Selection
    = NoSelection
    | SelectingFrom Hover
    | SelectedChar Position
    | Selection Position Position


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
      --
    | MarkdownMsg MarkdownMsg
