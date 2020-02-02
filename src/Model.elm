module Model exposing (Config, Hover(..), Model, Msg(..), Position, Selection(..), init)

import Array exposing (Array)


type alias Model =
    { lines : Array String
    , cursor : Position
    , hover : Hover
    , selection : Selection
    , width : Float
    , height : Float
    , fontSize : Float
    , lineHeight : Float
    , verticalScrollOffset : Int
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


init : Config -> Model
init config =
    { lines = Array.fromList [ "" ]
    , cursor = Position 0 0
    , hover = NoHover
    , selection = NoSelection
    , width = config.width
    , height = config.height
    , fontSize = config.fontSize
    , lineHeight = 1.2 * config.fontSize
    , verticalScrollOffset = config.verticalScrollOffset
    }



-- MSG


type Msg
    = NoOp
    | MoveUp
    | MoveDown
    | MoveLeft
    | MoveRight
    | NewLine
    | InsertChar String
    | RemoveCharBefore
    | RemoveCharAfter
    | Hover Hover
    | GoToHoveredPosition
    | StartSelecting
    | StopSelecting
      --
    | SelectLine
      --
    | Clear
    | Test
