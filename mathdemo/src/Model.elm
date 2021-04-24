module Model exposing (..)

import Browser.Dom as Dom
import Debounce exposing (Debounce)
import Editor exposing (Editor, EditorMsg)
import EditorModel
import File exposing (File)
import Http
import MiniLatex.EditSimple exposing (Data, LaTeXMsg)
import Outside
import Random
import Time
import Umuli



-- MODEL


type alias Model =
    { windowWidth : Int
    , windowHeight : Int
    , config : EditorModel.Config
    , editor : Editor
    , data : Umuli.Data
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
    , documentType : DocumentType
    , filePopupOpen : Bool
    , randomSeed : Random.Seed
    , uuid : String
    , fileArchive : FileArchive
    , tick : Int
    , currentTime : Time.Posix
    , documentDirty : Bool
    , newFilename : String
    }


type FileArchive
    = Server
    | Disk


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
    | NewDocument DocumentType
    | LoadDocument String
    | SavedToServer (Result Http.Error ())
    | ServerIsAlive (Result Http.Error String)
    | Tick Time.Posix
    | GotFilename String
    | MakeNewfile
    | CancelNewfile
    | Outside Outside.InfoForElm
    | OutsideInfo Outside.InfoForOutside
    | LogErr String


type DocumentType
    = MiniLaTeX
    | MathMarkdown
    | CaYaTeX
    | PlainText


umuliLang : DocumentType -> Umuli.Lang
umuliLang documentType =
    case documentType of
        MiniLaTeX ->
            Umuli.LMiniLaTeX

        MathMarkdown ->
            Umuli.LMarkdown


        CaYaTeX -> Umuli.LCaYaTeX

        PlainText ->
            Umuli.LText


fileExtension : DocumentType -> String
fileExtension dt =
    case dt of
        MiniLaTeX ->
            ".tex"

        MathMarkdown ->
            ".md"

        CaYaTeX -> ".cyt"


        PlainText ->
            ".txt"


docType : String -> DocumentType
docType ext =
    case ext of
        "tex" ->
            MiniLaTeX

        "md" ->
            MathMarkdown

        "cyt" -> CaYaTeX

        "txt" ->
            PlainText

        _ ->
            MathMarkdown


findDocumentType : String -> DocumentType
findDocumentType fileName =
    let
        parts =
            String.split "." fileName

        mExtensionName =
            List.head (List.reverse parts)
    in
    case mExtensionName of
        Just "tex" ->
            MiniLaTeX

        Just "md" ->
            MathMarkdown

        Just "cyt" ->
            CaYaTeX

        Just "txt" ->
            PlainText

        _ ->
            PlainText


type PrintingState
    = PrintWaiting
    | PrintProcessing
    | PrintReady



--| ImportFile File
--| DocumentLoaded String
