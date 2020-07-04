module Types exposing
    ( AppMode(..)
    , Authorization(..)
    , ChangingFileNameState(..)
    , DocumentStatus(..)
    , FileLocation(..)
    , HandleIndex(..)
    , Model
    , Msg(..)
    , PopupStatus(..)
    , PopupWindow(..)
    , SearchOptions(..)
    , ServerStatus(..)
    , SignInMode(..)
    )

import Author exposing (Author)
import Browser.Dom as Dom
import Codec.System exposing (Preferences)
import Document exposing (DocType(..), Document, Metadata)
import Editor exposing (Editor)
import File exposing (File)
import Http
import Json.Decode
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
    , serverStatus : ServerStatus
    , currentTime : Time.Posix
    , uuid : String
    , randomSeed : Random.Seed
    , messageLife : Int
    , width : Float
    , height : Float
    , editor : Editor
    , message : String
    , preferences : Maybe Preferences
    , appMode : AppMode

    -- UI
    , popupStatus : PopupStatus
    , fileLocation : FileLocation

    -- document
    , indexName : String
    , index : List String
    , handleIndex : HandleIndex
    , renderingData : RenderingData
    , docTitle : String
    , docType : DocType
    , fileName : String
    , fileName_ : String
    , tags_ : String
    , categories_ : String
    , title_ : String
    , subtitle_ : String
    , abstract_ : String
    , belongsTo_ : String
    , searchText_ : String
    , changingFileNameState : ChangingFileNameState
    , fileList : List Metadata
    , documentStatus : DocumentStatus
    , selectedId : ( Int, Int )
    , selectedId_ : String
    , currentDocument : Maybe Document
    , serverURL : String
    , searchOptions : SearchOptions

    -- User
    , authorName : String
    , userName : String
    , email : String
    , password : String
    , passwordAgain : String
    , signInMode : SignInMode
    , currentUser : Maybe Author
    }


type AppMode
    = Desktop
    | Webapp


type ServerStatus
    = ServerOffline
    | ServerOnline
    | ServerStatusUnknown


type HandleIndex
    = EditIndex
    | UseIndex


type SearchOptions
    = ExcludeDeleted
    | ShowDeleted
    | ShowDeletedOnly


type SignInMode
    = SigningIn
    | SetupAuthor
    | SignedIn
    | SigningUp


type FileLocation
    = FilesOnDisk
    | FilesOnServer


type ChangingFileNameState
    = ChangingMetadata
    | FileNameOK


type PopupStatus
    = PopupClosed
    | PopupOpen PopupWindow


type PopupWindow
    = FilePopup
    | NewFilePopup
    | IndexPopup
    | LocalStoragePopup
    | FileListPopup
    | PreferencesPopup
    | SyncPopup


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
    | ServerAliveReply (Result Http.Error String)
      -- UI
    | ManagePopup PopupStatus
    | About
    | ToggleFileLocation FileLocation
      -- Document
    | InputSearch String
    | InputFileName String
    | InputTags String
    | InputCategories String
    | InputTitle String
    | InputSubtitle String
    | InputBelongsTo String
    | LoadAboutDocument
    | DocumentLoaded String
    | ToggleDocType
    | CreateDocument
    | GetDocument HandleIndex String
    | ChangeMetadata String
    | CancelChangeFileName
    | SoftDelete Metadata
    | HardDelete String
    | CycleSearchOptions
      -- External Files
    | GetFileToImport
    | SendRequestForFile String
    | ImportFile File
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
    | OutsideInfo Outside.InfoForOutside
    | DeleteFileFromLocalStorage String
    | SaveFileToStorage
      -- File storage
    | SetDocumentDirectory
    | AskForRemoteDocuments
    | GotDocuments (Result Http.Error (List Metadata))
    | AskForDocument String
    | GotDocument (Result Http.Error Document)
    | GetDocumentToSync
    | ForcePush
    | SyncDocument (Result Http.Error Document)
    | Message (Result Http.Error String)
    | Publish
      -- Author
    | InputAuthorname String
    | InputUsername String
    | InputPassword String
    | InputPasswordAgain String
    | InputEmail String
    | SetUserName_
    | CreateAuthor
    | SignUp
    | SignIn
    | SignOut
    | GotSigninReply (Result Http.Error Authorization)
    | GetPreferences
    | GotPreferences Preferences


type Authorization
    = A Author
    | B Bool
