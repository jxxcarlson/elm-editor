module Update.Document exposing
    ( changeMetaData
    , createDocument
    , readDocumentCmd
    , updateDocument
    , listDocuments
    , loadDocument
    , toggleDocType
    )

import Cmd.Extra exposing (withCmd, withCmds, withNoCmd)
import Document exposing (DocType(..), Document)
import Helper.Common
import Helper.Load
import UuidHelper
import Helper.Server
import Helper.File
import Helper.Sync
import Outside
import Types exposing (ChangingFileNameState(..)
  , DocumentStatus(..),
  FileLocation(..), Model, Msg, PopupStatus(..))
import View.Scroll

readDocumentCmd fileName model =
    case model.fileLocation of
                 FilesOnDisk ->
                   Outside.sendInfo (Outside.AskForFile fileName)
                 FilesOnServer ->
                    Helper.Server.getDocument model.serverURL fileName

updateDocument : Model -> ( Model, Cmd Msg )
updateDocument model =
    let
        document_ =
            model.document

        document =
            { document_ | timeUpdated = model.currentTime }
    in
    case model.documentStatus of
        DocumentDirty ->
            { model
                | tickCount = model.tickCount + 1
                , documentStatus = DocumentSaved
            }
                |> withCmd (updateDocumentCmd document model)

        DocumentSaved ->
            ( { model | tickCount = model.tickCount + 1 }
            , Cmd.none
            )


updateDocumentCmd : Document -> Model -> Cmd Msg
updateDocumentCmd document model =
    case model.fileLocation of
        FilesOnDisk ->
            Outside.sendInfo (Outside.WriteFile document)

        FilesOnServer ->
            Helper.Server.updateDocument model.serverURL document

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
    , Outside.sendInfo (Outside.WriteFile newDocument)
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
                    Outside.sendInfo (Outside.CreateFile doc)

                FilesOnServer ->
                    Helper.Server.createDocument model.serverURL doc

listDocuments : PopupStatus -> Model -> ( Model, Cmd Msg )
listDocuments status model =
   { model | popupStatus = status, documentStatus = DocumentSaved }
       |> withCmds
         (case model.fileLocation of
             FilesOnDisk ->
               [ Helper.File.getDocumentList
               ]
             FilesOnServer ->
               [ Helper.Server.getDocumentList model.serverURL
               -- , Helper.Server.updateDocument model.serverURL model.document
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
