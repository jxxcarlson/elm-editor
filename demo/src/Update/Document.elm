module Update.Document exposing
    ( changeMetaData
    , createDocument
    , readDocumentCmd
    , setIndex
    , load
    , load_
    , sync
    , updateDocument
    , listDocuments
    , loadDocument
    , toggleDocType
    )

import Cmd.Extra exposing (withCmd, withCmds, withNoCmd)
import Document exposing (DocType(..), Document, SyncOperation(..))
import Helper.Common
import Helper.Load
import Update.Helper
import UuidHelper
import Index
import Helper.Server
import Helper.File
import Helper.Sync
import Outside
import Types exposing (ChangingFileNameState(..)
  , DocumentStatus(..), PopupWindow(..), HandleIndex(..),
  FileLocation(..), Model, Msg, PopupStatus(..))
import View.Scroll
import Time



updateDocsForSync : String -> SyncOperation -> Time.Posix -> Document -> Document -> (Document, Document)
updateDocsForSync serverUrl op currentTime localDoc remoteDoc =
    case op of
       DocsIdentical -> makeSyncDataEqual currentTime localDoc remoteDoc

       SyncConflict ->  pushDocument currentTime localDoc remoteDoc

       PushDocument -> pushDocument currentTime localDoc remoteDoc

       PullDocument -> pullDocument currentTime localDoc remoteDoc

       NoSyncOp -> (localDoc, remoteDoc)

makeSyncDataEqual : Time.Posix -> Document -> Document ->  (Document, Document)
makeSyncDataEqual currentTime localDoc remoteDoc =
    (Document.updateSyncTimes  currentTime localDoc
  , Document.updateSyncTimes currentTime remoteDoc)

pushDocument : Time.Posix -> Document -> Document ->  (Document, Document)
pushDocument currentTime localDoc remoteDoc =
    let
      newDoc =  Document.updateSyncTimes  currentTime localDoc
    in
   -- (Document.updateSyncTimes  currentTime localDoc
   --, Document.updateSyncTimes currentTime {remoteDoc | content = localDoc.content })
   (newDoc, newDoc)

pullDocument : Time.Posix -> Document -> Document ->  (Document, Document)
pullDocument currentTime localDoc remoteDoc =
    let
      newDoc = Document.updateSyncTimes  currentTime remoteDoc
    in
   -- (Document.updateSyncTimes  currentTime {localDoc | content = remoteDoc.content}
   --, Document.updateSyncTimes currentTime remoteDoc)
   (newDoc, newDoc)

syncCommands : String ->  SyncOperation  -> Document -> Document -> List (Cmd Msg)
syncCommands serverUrl op localDoc remoteDoc  =
          case op of
                 DocsIdentical -> updateBothDocuments serverUrl localDoc remoteDoc
                 SyncConflict -> updateBothDocuments serverUrl localDoc remoteDoc
                 PushDocument -> updateBothDocuments serverUrl localDoc remoteDoc
                 PullDocument -> updateBothDocuments serverUrl localDoc remoteDoc
                 NoSyncOp -> []

updateBothDocuments : String -> Document -> Document -> List (Cmd Msg)
updateBothDocuments serverUrl localDoc remoteDoc =
    [Outside.sendInfo (Outside.WriteDocument localDoc), Helper.Server.updateDocument  serverUrl remoteDoc ]

sync : Result error Document -> Model -> (Model, Cmd Msg)
sync result model =
   case result of
           Ok remoteDoc ->
              let
                    localDoc = model.document
                    op = Debug.log "OP" (Document.syncOperation localDoc remoteDoc)
                    message = op |>  Document.stringOfSyncOperation
                    (localDoc_, remoteDoc_) = updateDocsForSync model.serverURL op model.currentTime localDoc remoteDoc

              in
                { model | document = localDoc_ }
                  |> (Update.Helper.postMessage ("Sync: "  ++ message))
                  |> withCmds (syncCommands model.serverURL op localDoc_ remoteDoc_ )


           Err _ ->
               model
                   |> Update.Helper.postMessage "Error getting remote document"
                   |> withNoCmd




load : Result error Document-> Model -> Model
load result model =
    case result of
        Ok document ->
            load_ document model

        Err _ ->
            model
                |> Update.Helper.postMessage "Error getting remote document"

load_ : Document -> Model -> Model
load_ document model =
     case document.docType of
            MarkdownDoc ->
                Helper.Load.load document model

            MiniLaTeXDoc ->
                Helper.Load.load document model

            IndexDoc ->
                case model.handleIndex of
                    EditIndex -> Helper.Load.load document model
                    UseIndex ->  setIndex document model


setIndex : Document -> Model -> Model
setIndex document model =
    { model | index = Index.get  document.content
    , popupStatus = PopupOpen IndexPopup}


readDocumentCmd fileName model =
    case model.fileLocation of
                 FilesOnDisk ->
                   Outside.sendInfo (Outside.AskForDocument fileName)
                 FilesOnServer ->
                    Helper.Server.getDocument model.serverURL fileName

updateDocument : Model -> ( Model, Cmd Msg )
updateDocument model =
    let
        currentDocument =
            model.document

        updatedDocument =
            { currentDocument | timeUpdated = model.currentTime }
    in
    case model.documentStatus of
        DocumentDirty ->
            { model
                | tickCount = model.tickCount + 1
                , documentStatus = DocumentSaved
                , document = updatedDocument
            }
                |> withCmd (updateDocumentCmd model.serverURL model.fileLocation updatedDocument)

        DocumentSaved ->
            ( { model | tickCount = model.tickCount + 1 }
            , Cmd.none
            )


updateDocumentCmd : String -> FileLocation -> Document -> Cmd Msg
updateDocumentCmd serverUrl fileLocation document =
    case fileLocation of
        FilesOnDisk ->
            Outside.sendInfo (Outside.WriteDocument document)

        FilesOnServer ->
            Helper.Server.updateDocument serverUrl document

changeMetaData : Model -> ( Model, Cmd Msg )
changeMetaData model =
    let
        oldDocument =
            model.document

        newDocument =
            { oldDocument
                | fileName = model.fileName_
                , tags = Helper.Common.listFromString model.tags_
                , categories = Helper.Common.listFromString model.categories_
                , title = model.title_
                , subtitle = model.subtitle_
                , abstract = model.abstract_
                , belongsTo = model.belongsTo_
            }
    in
    ( { model
        | fileName = model.fileName_
        , docType = Document.docType model.fileName_
        , changingFileNameState = FileNameOK
        , popupStatus = PopupClosed
        , document = newDocument
        , fileList = Helper.Server.updateFileList (Document.toMetadata newDocument) model.fileList
      }
    , Outside.sendInfo (Outside.WriteDocument newDocument)
    )


{-|

    - Create a new document give the fileName and docType in the model
    - Load the document into the model using Helper.Load.loadDocument
    - Persist the document according to the value of fileLocation

-}
createDocument : Model -> ( Model, Cmd Msg )
createDocument model =
    let


        fileName = case model.preferences of
           Nothing -> Document.extendFileName model.docType "" uuid model.fileName_
           Just pref  -> Document.extendFileName model.docType pref.userName uuid model.fileName_


        ( uuid, seed ) =
            UuidHelper.generate model.randomSeed

        newModel =
            case model.docType of
                MarkdownDoc ->
                    Helper.Load.createAndLoad model.currentTime fileName  "" MarkdownDoc model

                MiniLaTeXDoc ->
                    Helper.Load.createAndLoad model.currentTime fileName "" MiniLaTeXDoc model

                IndexDoc ->
                    Helper.Load.createAndLoad model.currentTime fileName "" IndexDoc model
    in
    { newModel | popupStatus = PopupClosed, uuid = uuid, randomSeed = seed }
        |> Helper.Sync.syncModel2
        |> withCmd
            (Cmd.batch
                [ View.Scroll.toEditorTop
                , View.Scroll.toRenderedTextTop
                , createDocCmd newModel.document model
                ]
            )

createDocCmd : Document -> Model-> Cmd Msg
createDocCmd doc model =
            case model.fileLocation of
                FilesOnDisk ->
                    Outside.sendInfo (Outside.CreateDocument doc)

                FilesOnServer ->
                    Helper.Server.createDocument model.serverURL doc

listDocuments : PopupStatus -> Model -> ( Model, Cmd Msg )
listDocuments status model =
   { model | popupStatus = status, documentStatus = DocumentSaved }
       |> withCmds
         (case model.fileLocation of
             FilesOnDisk ->
               [ Helper.File.getDocumentList
               , Outside.getPreferences
               ]
             FilesOnServer ->
               [ Helper.Server.getDocumentList model.serverURL
               , Outside.getPreferences
               , Helper.Server.getDocument model.serverURL model.document.fileName
               ])




--
--|> Helper.Sync.syncModel2
--|> withCmd
--    (Cmd.batch
--        [ View.Scroll.toEditorTop
--        , View.Scroll.toRenderedTextTop
--        ]
--    )


loadDocument : String -> Model -> ( Model, Cmd Msg )
loadDocument content model =
    let

        fileName = case model.preferences of
                   Nothing -> Document.extendFileName model.docType "" uuid model.fileName_
                   Just pref  -> Document.extendFileName model.docType pref.userName uuid model.fileName


        ( uuid, seed ) =
                    UuidHelper.generate model.randomSeed

        docType =
            case Document.fileExtension fileName of
                "md" ->
                    MarkdownDoc

                "latex" ->
                    MiniLaTeXDoc

                "tex" ->
                    MiniLaTeXDoc

                _ ->
                    MarkdownDoc

        newModel =
            Helper.Load.createAndLoad model.currentTime
                fileName
                content
                docType
                model
                |> (\m -> { m | docType = docType, uuid = uuid, randomSeed = seed })
                |> Helper.Sync.syncModel2

        newDocument =  newModel.document
    in
    newModel
        |> withCmds
            [ View.Scroll.toRenderedTextTop
            , View.Scroll.toEditorTop
            , createDocCmd newDocument model
            ]


toggleDocType : Model -> ( Model, Cmd Msg )
toggleDocType model =
    let
        newDocType =
            case model.docType of
                MarkdownDoc ->
                    MiniLaTeXDoc

                MiniLaTeXDoc ->
                    IndexDoc

                IndexDoc -> MarkdownDoc


    in
    ( { model
        | docType = newDocType
        , fileName = Document.changeDocType newDocType model.fileName
      }
    , Cmd.none
    )
