module Types exposing
    ( ChangingFileNameState(..)
    , DocumentStatus(..)
    , FileLocation(..)
    , Model
    , Msg(..)
    , PopupStatus(..)
    , PopupWindow(..)
    )

import Browser.Dom as Dom
import Document exposing (DocType(..), Document, MiniFileRecord)
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
    , currentTime : Time.Posix
    , uuid : String
    , randomSeed : Random.Seed
    , messageLife : Int
    , width : Float
    , height : Float
    , editor : Editor
    , message : String

    -- UI
    , popupStatus : PopupStatus
    , fileLocation : FileLocation

    -- document
    , renderingData : RenderingData
    , docTitle : String
    , docType : DocType
    , fileName : String
    , fileName_ : String
    , changingFileNameState : ChangingFileNameState
    , fileList : List MiniFileRecord
    , documentStatus : DocumentStatus
    , selectedId : ( Int, Int )
    , selectedId_ : String
    , document : Document
    , fileStorageUrl : String

    -- User
    , authorName : String
    , userName : String
    , email : String
    , password : String
    , passwordAgain : String
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
    | NewFilePopup
    | LocalStoragePopup
    | RemoteFileListPopup
    | AuthorPopup


type DocumentStatus
    = DocumentDirty
    | DocumentSaved



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
    | ToggleFileLocation FileLocation
      -- Document
    | InputFileName String
    | Load String
    | DocumentLoaded String
    | ToggleDocType
    | CreateDocument
    | ChangeFileName String
    | CancelChangeFileName
    | SoftDelete MiniFileRecord
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
    | AskForDocument String
    | GotDocument (Result Http.Error Document)
    | Message (Result Http.Error String)
      -- Author
    | InputAuthorname String
    | InputUsername String
    | InputPassword String
    | InputPasswordAgain String
    | InputEmail String
    | CreateAuthor
