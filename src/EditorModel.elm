module EditorModel exposing
    ( AutoLineBreak(..)
    , Config
    , EditMode(..)
    , EditorModel
    , HelpState(..)
    , Snapshot
    , ViewMode(..)
    , VimMode(..)
    , debounceConfig
    , init
    )

import Array exposing (Array)
import ContextMenu exposing (ContextMenu)
import Debounce exposing (Debounce)
import EditorMsg exposing (Context(..), EMsg(..), Hover(..), Position, Selection(..), WrapOption(..))
import History exposing (History)
import RollingList exposing (RollingList)


type alias EditorModel =
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


init : ( Config, ContextMenu Context ) -> EditorModel
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


debounceConfig : Debounce.Config EMsg
debounceConfig =
    { strategy = Debounce.later 300
    , transform = DebounceMsg
    }
