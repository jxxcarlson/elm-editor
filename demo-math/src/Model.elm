module Model exposing (..)

import Browser.Dom as Dom
import Debounce exposing (Debounce)
import Editor exposing (Editor, EditorMsg)
import EditorModel
import File exposing (File)
import Html exposing (Html)
import Http
import MiniLatex.EditSimple exposing (Data, LaTeXMsg)
import Umuli



-- MODEL


type alias Model =
    { windowWidth : Int
    , windowHeight : Int
    , config : EditorModel.Config
    , editor : Editor
    , data : Umuli.Data
    , sourceText : String
    , macroText : String
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
    , renderingMode : RenderingMode
    , filePopupOpen : Bool
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
    | Umuli Umuli.UmuliMsg
    | ToggleFilePopup


type RenderingMode
    = MiniLaTeX
    | MathMarkdown
    | PlainText


umuliLang : RenderingMode -> Umuli.Lang
umuliLang mode =
    case mode of
        MiniLaTeX ->
            Umuli.LMiniLaTeX

        MathMarkdown ->
            Umuli.LMarkdown

        PlainText ->
            Umuli.LText


type PrintingState
    = PrintWaiting
    | PrintProcessing
    | PrintReady



--| ImportFile File
--| DocumentLoaded String
