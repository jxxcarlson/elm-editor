module Update.UI exposing (managePopup)

import Types exposing(Model, PopupStatus(..),  PopupWindow(..), DocumentStatus(..), FileLocation(..))
import Cmd.Extra exposing (withCmd,withNoCmd, withCmds)
import Helper.Server
import Helper.File


managePopup : PopupStatus -> Model -> (Model, Cmd Types.Msg)
managePopup status model =
  case status of
    PopupOpen LocalStoragePopup ->
        -- TODO: needs to be eliminated
        { model | popupStatus = status }
            |> withCmd (Helper.Server.getDocumentList model.fileStorageUrl)

    PopupOpen FilePopup ->
        { model | popupStatus = status } |> withNoCmd

    PopupOpen NewFilePopup ->
        { model | popupStatus = status } |> withNoCmd

    PopupOpen FileListPopup ->
        -- TODO: Add File API
        { model | popupStatus = status, documentStatus = DocumentSaved }
            |> withCmds
              (case model.fileLocation of
                  LocalFiles ->
                    [ Helper.File.getDocumentList
                    ]
                  RemoteFiles ->
                    [ Helper.Server.getDocumentList model.fileStorageUrl
                    , Helper.Server.updateDocument model.fileStorageUrl model.document
                    ])
    PopupOpen _ ->
        { model | popupStatus = status } |> withNoCmd

    PopupClosed ->
        { model | popupStatus = status } |> withNoCmd