module Types exposing (DocType(..), DocumentStatus(..), Model, Msg(..), PopupStatus(..))

import Browser.Dom as Dom
import Editor exposing (Editor)
import File exposing (File)
import Outside
import Render exposing (RenderingData)
import Render.Types exposing (RenderMsg)
import Time



-- MODEL


type alias Model =
    { editor : Editor
    , renderingData : RenderingData
    , counter : Int
    , width : Float
    , height : Float
    , docTitle : String
    , docType : DocType
    , fileName : Maybe String
    , fileContents : String
    , fileList : List String
    , documentStatus : DocumentStatus
    , selectedId : ( Int, Int )
    , selectedId_ : String
    , message : String
    , tickCount : Int
    , popupStatus : PopupStatus
    }


type PopupStatus
    = PopupClosed
    | PopupOpen


type DocumentStatus
    = DocumentDirty
    | DocumentSaved


type DocType
    = MarkdownDoc
    | MiniLaTeXDoc



-- MSG


type Msg
    = NoOp
    | EditorMsg Editor.EditorMsg
    | WindowSize Int Int
    | Load String
    | ToggleDocType
    | NewDocument
    | SetViewPortForElement (Result Dom.Error ( Dom.Element, Dom.Viewport ))
    | RequestFile
    | RequestedFile File
    | DocumentLoaded String
    | SaveFile
    | ExportFile
    | SyncLR
    | Outside Outside.InfoForElm
    | LogErr String
    | RenderMsg RenderMsg
    | Tick Time.Posix
    | ManagePopup PopupStatus
    | SendRequestForFile String
