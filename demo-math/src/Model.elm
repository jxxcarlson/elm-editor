module Model exposing (..)

import Browser.Dom as Dom
import Debounce exposing (Debounce)
import Editor exposing (Editor, EditorMsg)
import EditorModel
import File exposing (File)
import Html exposing (Html)
import Http
import MiniLatex.EditSimple exposing (Data, LaTeXMsg)



-- MODEL


type alias Model =
    { windowWidth : Int
    , windowHeight : Int
    , config : EditorModel.Config
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
    , printingState : PrintingState
    , docId : String
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
    | PrintToPDF
    | ChangePrintingState PrintingState
    | GotPdfLink (Result Http.Error String)
    | FinallyDoCleanPrintArtefacts String


type PrintingState
    = PrintWaiting
    | PrintProcessing
    | PrintReady



--| ImportFile File
--| DocumentLoaded String
