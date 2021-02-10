module Update.Document exposing
    ( acceptLocal
    , acceptRemote
    , changeMetaData
    , createDocument
    , forcePush
    , listDocuments
    , load
    , loadDocument
    , load_
    , readDocumentCmd
    , rejectOne
    , setIndex
    , sync
    , toggleDocType
    , updateDocument
    )

import Cmd.Extra exposing (withCmd, withCmds, withNoCmd)
import Data
import Document exposing (DocType(..), Document, SyncOperation(..))
import Helper.Common
import Helper.Diff
import Helper.File
import Helper.Load
import Helper.Server
import Helper.Sync
import Index
import Outside
import Time
import Types
    exposing
        ( ChangingFileNameState(..)
        , DocumentStatus(..)
        , FileLocation(..)
        , HandleIndex(..)
        , MergeSite(..)
        , Model
        , Msg
        , PopupStatus(..)
        , PopupWindow(..)
        , ResolveMergeConflict(..)
        )
import Update.Helper
import UuidHelper
import View.Scroll


forcePush : Model -> ( Model, Cmd Msg )
forcePush model =
    case model.currentDocument of
        Nothing ->
            model |> withNoCmd

        Just doc ->
            if Helper.Diff.conflictsResolved doc.content then
                let
                    newDoc =
                        doc |> Document.updateSyncTimes model.currentTime
                in
                { model | currentDocument = Just newDoc }
                    |> withCmds (updateBothDocuments model.serverURL newDoc newDoc)

            else
                model
                    |> Update.Helper.postMessage "You still have conflicts"
                    |> withNoCmd


acceptLocal : ResolveMergeConflict -> Model -> ( Model, Cmd Msg )
acceptLocal mode model =
    case model.currentDocument of
        Nothing ->
            model |> withNoCmd

        Just doc ->
            let
                merger =
                    case mode of
                        ResolveOne ->
                            Helper.Diff.acceptOneLocal

                        ResolveAll ->
                            Helper.Diff.acceptLocal

                newDoc =
                    doc
                        |> Document.updateSyncTimes model.currentTime
                        |> (\doc_ -> { doc_ | content = merger doc.content })
            in
            { model | currentDocument = Just newDoc }
                |> Helper.Load.load newDoc
                |> withCmds (updateBothDocuments model.serverURL newDoc newDoc)


acceptRemote : ResolveMergeConflict -> Model -> ( Model, Cmd Msg )
acceptRemote mode model =
    case model.currentDocument of
        Nothing ->
            model |> withNoCmd

        Just doc ->
            let
                merger =
                    case mode of
                        ResolveOne ->
                            Helper.Diff.acceptOneRemote

                        ResolveAll ->
                            Helper.Diff.acceptRemote

                newDoc =
                    doc
                        |> Document.updateSyncTimes model.currentTime
                        |> (\doc_ -> { doc_ | content = merger doc.content })
            in
            { model | currentDocument = Just newDoc }
                |> Helper.Load.load newDoc
                |> withCmds (updateBothDocuments model.serverURL newDoc newDoc)


rejectOne : MergeSite -> Model -> ( Model, Cmd Msg )
rejectOne mergeSite model =
    case model.currentDocument of
        Nothing ->
            model |> withNoCmd

        Just doc ->
            let
                merger =
                    case mergeSite of
                        LocalSite ->
                            Helper.Diff.rejectOneLocal

                        RemoteSite ->
                            Helper.Diff.rejectOneRemote

                newDoc =
                    doc
                        |> Document.updateSyncTimes model.currentTime
                        |> (\doc_ -> { doc_ | content = merger doc.content })
            in
            { model | currentDocument = Just newDoc }
                |> Helper.Load.load newDoc
                |> withCmds (updateBothDocuments model.serverURL newDoc newDoc)


updateDocsForSync : SyncOperation -> Time.Posix -> Document -> Document -> ( Document, Document )
updateDocsForSync op currentTime localDoc remoteDoc =
    case op of
        DocsIdentical ->
            makeSyncDataEqual currentTime localDoc remoteDoc

        SyncConflict ->
            ( Helper.Diff.compareDocuments localDoc remoteDoc, remoteDoc )

        PushDocument ->
            pushDocument currentTime localDoc

        PullDocument ->
            pullDocument currentTime remoteDoc

        NoSyncOp ->
            ( localDoc, remoteDoc )


makeSyncDataEqual : Time.Posix -> Document -> Document -> ( Document, Document )
makeSyncDataEqual currentTime localDoc remoteDoc =
    ( Document.updateSyncTimes currentTime localDoc
    , Document.updateSyncTimes currentTime remoteDoc
    )


pushDocument : Time.Posix -> Document -> ( Document, Document )
pushDocument currentTime localDoc =
    let
        newDoc =
            Document.updateSyncTimes currentTime localDoc
    in
    -- (Document.updateSyncTimes  currentTime localDoc
    --, Document.updateSyncTimes currentTime {remoteDoc | content = localDoc.content })
    ( newDoc, newDoc )


pullDocument : Time.Posix -> Document -> ( Document, Document )
pullDocument currentTime remoteDoc =
    let
        newDoc =
            Document.updateSyncTimes currentTime remoteDoc
    in
    -- (Document.updateSyncTimes  currentTime {localDoc | content = remoteDoc.content}
    --, Document.updateSyncTimes currentTime remoteDoc)
    ( newDoc, newDoc )


syncCommands : String -> SyncOperation -> Document -> Document -> List (Cmd Msg)
syncCommands serverUrl op localDoc remoteDoc =
    case op of
        DocsIdentical ->
            updateBothDocuments serverUrl localDoc remoteDoc

        SyncConflict ->
            [ Outside.sendInfo (Outside.WriteDocument localDoc) ]

        PushDocument ->
            updateBothDocuments serverUrl localDoc remoteDoc

        PullDocument ->
            updateBothDocuments serverUrl localDoc remoteDoc

        NoSyncOp ->
            []


updateBothDocuments : String -> Document -> Document -> List (Cmd Msg)
updateBothDocuments serverUrl localDoc remoteDoc =
    [ Outside.sendInfo (Outside.WriteDocument localDoc), Helper.Server.updateDocument serverUrl remoteDoc ]


sync : Result error Document -> Document -> Model -> ( Model, Cmd Msg )
sync result localDoc model =
    case result of
        Ok remoteDoc ->
            let
                -- op = Debug.log "OP" (Document.syncOperation localDoc remoteDoc)
                op =
                    Document.syncOperation localDoc remoteDoc

                message =
                    op |> Document.stringOfSyncOperation

                ( localDoc_, remoteDoc_ ) =
                    updateDocsForSync op model.currentTime localDoc remoteDoc
            in
            { model | currentDocument = Just localDoc_ }
                |> Helper.Load.load localDoc_
                |> Update.Helper.postMessage ("Sync: " ++ message)
                |> withCmds (syncCommands model.serverURL op localDoc_ remoteDoc_)

        Err _ ->
            model
                |> Update.Helper.postMessage "(S) Error getting remote document"
                |> withNoCmd


load : Result error Document -> Model -> Model
load result model =
    case result of
        Ok document ->
            load_ document model

        Err _ ->
            load_ (Data.template "Document not found") { model | currentDocument = Nothing }
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
                EditIndex ->
                    Helper.Load.load document { model | indexName = document.fileName }

                UseIndex ->
                    setIndex document { model | indexName = document.fileName }


setIndex : Document -> Model -> Model
setIndex document model =
    { model
        | index = Index.get document.content
        , popupStatus = PopupOpen IndexPopup
    }


readDocumentCmd : FileLocation -> String -> String -> Cmd Msg
readDocumentCmd fileLocation serverURL fileName =
    case fileLocation of
        FilesOnDisk ->
            Outside.sendInfo (Outside.AskForDocument fileName)

        FilesOnServer ->
            Helper.Server.getDocument serverURL fileName


updateDocument : Model -> ( Model, Cmd Msg )
updateDocument model =
    case model.currentDocument of
        Nothing ->
            ( model, Cmd.none )

        Just doc ->
            updateDocument_ doc model


updateDocument_ : Document -> Model -> ( Model, Cmd Msg )
updateDocument_ doc model =
    let
        updatedDocument =
            { doc | timeUpdated = model.currentTime }
    in
    case model.documentStatus of
        DocumentDirty ->
            { model
                | tickCount = model.tickCount + 1
                , documentStatus = DocumentSaved
                , currentDocument = Just updatedDocument
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
    case model.currentDocument of
        Nothing ->
            ( model, Cmd.none )

        Just oldDocument ->
            let
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
            { model
                | fileName = model.fileName_
                , docType = Document.docType model.fileName_
                , changingFileNameState = FileNameOK
                , popupStatus = PopupClosed
                , currentDocument = Just newDocument
                , fileList = Helper.Server.updateFileList (Document.toMetadata newDocument) model.fileList
            }
                |> withCmds
                    [ Outside.sendInfo (Outside.WriteDocument newDocument)
                    , Outside.sendInfo (Outside.DeleteDocument oldDocument.fileName)
                    ]


{-|

    - Create a new document give the fileName and docType in the model
    - Load the document into the model using Helper.Load.loadDocument
    - Persist the document according to the value of fileLocation

-}
createDocument : Model -> ( Model, Cmd Msg )
createDocument model =
    let
        fileName =
            case model.preferences of
                Nothing ->
                    Document.extendFileName model.docType "" uuid model.fileName_

                Just pref ->
                    Document.extendFileName model.docType pref.userName uuid model.fileName_

        ( uuid, seed ) =
            UuidHelper.generate model.randomSeed

        ( newDoc, newModel ) =
            case model.docType of
                MarkdownDoc ->
                    Helper.Load.createAndLoad model.currentTime fileName "" MarkdownDoc model

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
                , createDocCmd newDoc model
                ]
            )


createDocCmd : Document -> Model -> Cmd Msg
createDocCmd doc model =
    case model.fileLocation of
        FilesOnDisk ->
            Outside.sendInfo (Outside.CreateDocument doc)

        FilesOnServer ->
            Helper.Server.createDocument model.serverURL doc


listDocuments : PopupStatus -> Model -> ( Model, Cmd Msg )
listDocuments status model =
    let
        remoteGetDocCmd =
            case model.currentDocument of
                Nothing ->
                    Cmd.none

                Just doc ->
                    Helper.Server.getDocument model.serverURL doc.fileName
    in
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
                    , remoteGetDocCmd
                    ]
            )



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
        fileName =
            case model.preferences of
                Nothing ->
                    Document.extendFileName model.docType "" uuid model.fileName_

                Just pref ->
                    Document.extendFileName model.docType pref.userName uuid model.fileName

        ( uuid, _ ) =
            UuidHelper.generate model.randomSeed

        docType_ =
            case Document.fileExtension fileName of
                "md" ->
                    MarkdownDoc

                "latex" ->
                    MiniLaTeXDoc

                "tex" ->
                    MiniLaTeXDoc

                _ ->
                    MarkdownDoc

        ( newDocument, newModel_ ) =
            -- createAndLoad time fileName_ content_ docType_ model
            Helper.Load.createAndLoad model.currentTime fileName content docType_ model

        newModel =
            newModel_ |> Helper.Sync.syncModel2
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

                IndexDoc ->
                    MarkdownDoc
    in
    ( { model
        | docType = newDocType
        , fileName = Document.changeDocType newDocType model.fileName
      }
    , Cmd.none
    )
