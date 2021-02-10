module Model exposing(..)

import Editor exposing(EditorMsg)
import Debounce
import Browser.Dom as Dom
import MiniLatex.EditSimple exposing(LaTeXMsg, Data)
import Debounce exposing(Debounce)
import Html exposing(Html)
import Editor exposing(Editor)

-- MODEL


type alias Model =
    { editor : Editor
    , sourceText : String
    , renderedText : Html Msg
    , macroText : String
    , editRecord : Data -- MiniLatex.EditSimple.LaTeXMsg
    , debounce : Debounce String
    , counter : Int
    , seed : Int
    , selectedId : String
    , message : String
    , images : List String
    , imageUrl : String
    }


type Msg
    = MyEditorMsg Editor.EditorMsg
    | NoOp
    | Clear
    | Render String
    | GetContent String
    | GetMacroText String
    | DebounceMsg Debounce.Msg
    | GenerateSeed
    | NewSeed Int
    | FullRender
    | RestoreText
    | ExampleText
    | SetViewPortForElement (Result Dom.Error ( Dom.Element, Dom.Viewport ))
    | LaTeXMsg MiniLatex.EditSimple.LaTeXMsg
    | Export
