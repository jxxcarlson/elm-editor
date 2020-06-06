module Types exposing
    ( ChangingFileNameState(..)
    , DocType(..)
    , DocumentStatus(..)
    , FileLocation(..)
    , Model
    , Msg(..)
    , PopupStatus(..)
    , PopupWindow(..)
    )

import Browser.Dom as Dom
import Document exposing (Document, MiniFileRecord)
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
    { -- system
      tickCount : Int
    , counter : Int
    , width : Float
    , height : Float
    , editor : Editor
    , message : String
    , randomSeed : Random.Seed

    -- UI
    , popupStatus : PopupStatus
    , fileLocation : FileLocation

    -- document
    , renderingData : RenderingData
    , docTitle : String
    , docType : DocType
    , fileName : Maybe String
    , newFileName : String
    , changingFileNameState : ChangingFileNameState
    , fileList : List MiniFileRecord
    , documentStatus : DocumentStatus
    , selectedId : ( Int, Int )
    , selectedId_ : String
    , authorName : String
    , document : Document
    , uuid : String
    , fileStorageUrl : String
    }


type FileLocation
    = LocalFiles
    | RemoteFiles


type ChangingFileNameState
    = ChangingFileName
    | FileNameOK


type PopupStatus
    = PopupClosed
    | PopupOpen PopupWindow


type PopupWindow
    = FilePopup
    | FileListPopup
    | RemoteFileListPopup
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
      -- System
    | Tick Time.Posix
    | WindowSize Int Int
    | GotAtmosphericRandomNumber (Result Http.Error String)
      -- UI
    | ManagePopup PopupStatus
    | About
    | InputAuthorname String
    | ToggleFileLocation FileLocation
      -- Document
    | InputFileName String
    | Load String
    | DocumentLoaded String
    | ToggleDocType
    | NewDocument
    | ChangeFileName
    | CancelChangeFileName
      -- External Files
    | RequestFile
    | SendRequestForFile String
    | RequestedFile File
    | SaveFile
    | ExportFile
      -- Editor
    | EditorMsg Editor.EditorMsg
    | SyncLR
    | SetViewPortForElement (Result Dom.Error ( Dom.Element, Dom.Viewport ))
    | LogErr String
    | RenderMsg RenderMsg
      -- Local storage
    | Outside Outside.InfoForElm
    | DeleteFileFromLocalStorage String
    | SaveFileToStorage
      -- File storage
    | AskForRemoteDocuments
    | GotDocuments (Result Http.Error (List MiniFileRecord))
    | AskForRemoteDocument String
    | GotDocument (Result Http.Error Document)
    | Message (Result Http.Error String)
