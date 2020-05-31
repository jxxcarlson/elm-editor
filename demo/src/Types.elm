module Types exposing
    ( ChangingFileNameState(..)
    , DocType(..)
    , DocumentStatus(..)
    , Model
    , Msg(..)
    , PopupStatus(..)
    , PopupWindow(..)
    )

import Browser.Dom as Dom
import Document exposing (BasicDocument, MiniFileRecord)
import Editor exposing (Editor)
import File exposing (File)
import Http
import Outside
import Random
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
    , newFileName : String
    , changingFileNameState : ChangingFileNameState
    , fileList : List MiniFileRecord
    , documentStatus : DocumentStatus
    , selectedId : ( Int, Int )
    , selectedId_ : String
    , message : String
    , tickCount : Int
    , popupStatus : PopupStatus
    , authorName : String
    , document : BasicDocument
    , randomSeed : Random.Seed
    , uuid : String
    }


type ChangingFileNameState
    = ChangingFileName
    | FileNameOK


type PopupStatus
    = PopupClosed
    | PopupOpen PopupWindow


type PopupWindow
    = FilePopup
    | FileListPopup
    | AuthorPopup


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
    | DeleteFileFromLocalStorage String
    | SaveFileToLocalStorage
    | InputFileName String
    | ChangeFileName
    | CancelChangeFileName
    | About
    | InputAuthorname String
    | GotAtmosphericRandomNumber (Result Http.Error String)
