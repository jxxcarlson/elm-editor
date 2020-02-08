module Model exposing
    ( Config
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
import ContextMenu exposing (ContextMenu)
import Debounce exposing (Debounce)
import History exposing (History)


type alias Model =
    { lines : Array String
    , cursor : Position
    , hover : Hover
    , selection : Selection
    , selectedText : Array String
    , width : Float
    , height : Float
    , fontSize : Float
    , lineHeight : Float
    , verticalScrollOffset : Int
    , lineNumberToGoTo : String
    , debounce : Debounce String
    , history : History Snapshot
    , contextMenu : ContextMenu Context
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
    , width = config.width
    , height = config.height
    , fontSize = config.fontSize
    , lineHeight = 1.2 * config.fontSize
    , verticalScrollOffset = config.verticalScrollOffset
    , lineNumberToGoTo = ""
    , debounce = Debounce.init
    , history = History.empty
    , contextMenu = contextMenu
    }


debounceConfig : Debounce.Config Msg
debounceConfig =
    { strategy = Debounce.later 2000
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
    | Cut
    | Copy
    | Paste
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
