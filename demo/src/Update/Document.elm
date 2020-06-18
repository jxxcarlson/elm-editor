module Update.Document exposing (..)

import Cmd.Extra exposing (withCmd, withCmds, withNoCmd)
import Document exposing (DocType(..))
import Helper.Load
import Helper.Server
import Helper.Sync
import Outside
import Types exposing (FileLocation(..), PopupStatus(..))
import View.Scroll


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
