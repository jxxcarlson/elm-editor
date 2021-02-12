module Model exposing (..)

import Browser.Dom as Dom
import Debounce exposing (Debounce)
import Editor exposing (Editor, EditorMsg)
import File exposing (File)
import Html exposing (Html)
import MiniLatex.EditSimple exposing (Data, LaTeXMsg)



-- MODEL


type alias Model =
    { windowWidth : Int
    , windowHeight : Int
    , editor : Editor
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
    , fileName : String
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
    | SaveFile
    | FileRequested
    | FileSelected File
    | FileLoaded String



--| ImportFile File
--| DocumentLoaded String
