module Model exposing
    ( AutoLineBreak(..)
    , Config
    , Context(..)
    , EditMode(..)
    , HelpState(..)
    , Hover(..)
    , Model
    , Msg(..)
    , Position
    , Selection(..)
    , Snapshot
    , ViewMode(..)
    , VimMode(..)
    , debounceConfig
    , init
    )

import Array exposing (Array)
import Browser.Dom as Dom
import ContextMenu exposing (ContextMenu)
import Debounce exposing (Debounce)
import File exposing (File)
import History exposing (History)
import Markdown.Render exposing (MarkdownMsg(..))
import RollingList exposing (RollingList)
import Wrap exposing (WrapOption(..))


type alias Model =
    { lines : Array String
    , cursor : Position
    , hover : Hover
    , selection : Selection
    , selectedText : Array String
    , selectedString : Maybe String
    , width : Float
    , height : Float
    , fontSize : Float
    , lineHeight : Float
    , verticalScrollOffset : Int
    , lineNumberToGoTo : String
    , debounce : Debounce String
    , history : History Snapshot
    , contextMenu : ContextMenu Context
    , autoLineBreak : AutoLineBreak
    , debugOn : Bool
    , topLine : Int
    , wrapOption : WrapOption
    , clipboard : String
    , searchTerm : String
    , searchResults : RollingList Selection
    , searchResultIndex : Int
    , showSearchPanel : Bool
    , canReplace : Bool
    , replacementText : String
    , viewMode : ViewMode
    , indentationOffset : Int
    , helpState : HelpState
    , editMode : EditMode
    }


type ViewMode
    = Light
    | Dark


type Context
    = Object
    | Background


type HelpState
    = HelpOn
    | HelpOff


type alias Snapshot =
    { lines : Array String
    , cursor : Position
    , selection : Selection
    }


emptySnapshot : Snapshot
emptySnapshot =
    { lines = Array.fromList [ "" ]
    , cursor = { line = 0, column = 0 }
    , selection = NoSelection
    }


type alias Config =
    { width : Float
    , height : Float
    , fontSize : Float
    , verticalScrollOffset : Int
    , debugOn : Bool
    , wrapOption : WrapOption
    }


type Hover
    = NoHover
    | HoverLine Int
    | HoverChar Position


type Selection
    = NoSelection
    | SelectingFrom Hover
    | SelectedChar Position
    | Selection Position Position


type alias Position =
    { line : Int
    , column : Int
    }


init : ( Config, ContextMenu Context ) -> Model
init ( config, contextMenu ) =
    { lines = Array.fromList [ "" ]
    , cursor = Position 0 0
    , hover = NoHover
    , selection = NoSelection
    , selectedText = Array.fromList [ "" ]
    , selectedString = Nothing
    , width = config.width
    , height = config.height
    , fontSize = config.fontSize
    , lineHeight = 1.2 * config.fontSize
    , verticalScrollOffset = config.verticalScrollOffset
    , lineNumberToGoTo = ""
    , debounce = Debounce.init
    , history = History.empty
    , contextMenu = contextMenu
    , autoLineBreak = AutoLineBreakON
    , debugOn = config.debugOn
    , topLine = 0
    , wrapOption = config.wrapOption
    , clipboard = ""
    , searchTerm = ""
    , searchResults = RollingList.fromList []
    , searchResultIndex = 0
    , showSearchPanel = False
    , canReplace = False
    , replacementText = ""
    , viewMode = Light
    , indentationOffset = 4
    , helpState = HelpOff
    , editMode = StandardEditor
    }


type EditMode
    = StandardEditor
    | VimEditor VimMode


type VimMode
    = VimNormal
    | VimInsert


type AutoLineBreak
    = AutoLineBreakON
    | AutoLineBreakOFF


debounceConfig : Debounce.Config Msg
debounceConfig =
    { strategy = Debounce.later 300
    , transform = DebounceMsg
    }



-- MSG


type Msg
    = EditorNoOp
      --
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
    | SendLine
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



--| GotViewport (Result Dom.Error Dom.Viewport)
--| SetViewPortForElement (Result Dom.Error ( Dom.Element, Dom.Viewport ))
