module Update.Document exposing
    ( createDocument
    , loadDocument
    , toggleDocType
    )

import Cmd.Extra exposing (withCmd, withCmds, withNoCmd)
import Document exposing (DocType(..))
import Helper.Load
import Helper.Server
import Helper.Sync
import Outside
import Types exposing (FileLocation(..), Model, Msg, PopupStatus(..))
import Update.Helper
import View.Scroll


{-|

    - Create a new document give the fileName and docType in the model
    - Load the document into the model using Helper.Load.loadDocument
    - Persist the document according to the value of fileLocation

-}
createDocument : Model -> ( Model, Cmd Msg )
createDocument model =
    let
        newModel =
            case model.docType of
                MarkdownDoc ->
                    Helper.Load.loadDocument model.fileName_ "" MarkdownDoc model

                MiniLaTeXDoc ->
                    Helper.Load.loadDocument model.fileName_ "" MiniLaTeXDoc model

        doc =
            newModel.document

        createDocCmd =
            case model.fileLocation of
                LocalFiles ->
                    Outside.sendInfo (Outside.CreateFile doc)

                RemoteFiles ->
                    Helper.Server.createDocument model.fileStorageUrl doc
    in
    { newModel | popupStatus = PopupClosed }
        |> Helper.Sync.syncModel2
        |> withCmd
            (Cmd.batch
                [ View.Scroll.toEditorTop
                , View.Scroll.toRenderedTextTop
                , createDocCmd
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
        docType =
            case Document.fileExtension model.fileName of
                "md" ->
                    MarkdownDoc

                "latex" ->
                    MiniLaTeXDoc

                "tex" ->
                    MiniLaTeXDoc

                _ ->
                    MarkdownDoc

        newModel =
            Helper.Load.loadDocument (Document.titleFromFileName model.fileName) content docType model
                |> (\m -> { m | docType = docType })
                |> Helper.Sync.syncModel2

        newDocument =
            newModel.document
    in
    newModel
        |> withCmds
            [ View.Scroll.toRenderedTextTop
            , View.Scroll.toEditorTop
            , Helper.Server.updateDocument model.fileStorageUrl newDocument
            ]


setViewportForSync result model =
    case result of
        Ok ( element, viewport ) ->
            model
                |> Update.Helper.postMessage "synced"
                |> withCmd (View.Scroll.setViewPortForSelectedLineInRenderedText element viewport)

        Err _ ->
            model
                |> Update.Helper.postMessage "sync error"
                |> withNoCmd


toggleDocType : Model -> ( Model, Cmd Msg )
toggleDocType model =
    let
        newDocType =
            case model.docType of
                MarkdownDoc ->
                    MiniLaTeXDoc

                MiniLaTeXDoc ->
                    MarkdownDoc
    in
    ( { model
        | docType = newDocType
        , fileName = Document.changeDocType newDocType model.fileName
      }
    , Cmd.none
    )
