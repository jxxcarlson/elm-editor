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
import Vim
import Window exposing (Window)


type alias EditorModel =
    { lines : Array String
    , cursor : Position
    , window : Window
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
    , viewLineNumbersOn : Bool
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
    , vimModel : Vim.VimModel
    , devModeOn : Bool
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


type alias Config =
    { width : Float
    , height : Float
    , fontSize : Float
    , verticalScrollOffset : Int
    , viewMode : ViewMode
    , debugOn : Bool
    , viewLineNumbersOn : Bool
    , wrapOption : WrapOption
    }


init : ( Config, ContextMenu Context ) -> EditorModel
init ( config, contextMenu ) =
    { lines = Array.fromList (String.lines "")
    , cursor = Position 0 0
    , window = Window.init 600
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
    , viewLineNumbersOn = config.viewLineNumbersOn
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
    , viewMode = config.viewMode
    , indentationOffset = 3
    , helpState = HelpOff
    , editMode = StandardEditor
    , vimModel = Vim.init
    , devModeOn = False
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


lineEnd : Int -> EditorModel -> Int
lineEnd line model =
    Array.get line model.lines
        |> Maybe.map String.length
        |> Maybe.withDefault 0
        |> (\x -> x - 1)
