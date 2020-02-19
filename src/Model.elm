module Model exposing
    ( AutoLineBreak(..)
    , Config
    , Context(..)
    , Hover(..)
    , Model
    , Msg(..)
    , Position
    , Selection(..)
    , Snapshot
    , debounceConfig
    , init
    )

import Array exposing (Array)
import Browser.Dom as Dom
import ContextMenu exposing (ContextMenu)
import Debounce exposing (Debounce)
import File exposing (File)
import History exposing (History)
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
    }


type Context
    = Object
    | Background


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
    }


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
    = NoOp
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
      --
    | DebounceMsg Debounce.Msg
    | Unload String
      --
    | Clear
    | Test
      --
    | ContextMenuMsg (ContextMenu.Msg Context)
    | Item Int
    | ToggleAutoLineBreak
      --
    | RequestFile
    | RequestedFile File
    | MarkdownLoaded String
    | SaveFile
      --
    | SendLine
    | GotViewportForSync (Maybe String) Selection (Result Dom.Error Dom.Viewport)
      --
    | CopyPasteClipboard
    | WriteToSystemClipBoard



--| GotViewport (Result Dom.Error Dom.Viewport)
--| SetViewPortForElement (Result Dom.Error ( Dom.Element, Dom.Viewport ))
