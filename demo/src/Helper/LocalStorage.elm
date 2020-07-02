module Helper.LocalStorage exposing (..)

import Config
import Document exposing (Document)
import Editor
import File exposing (File)
import File.Download as Download
import File.Select as Select
import Http
import MiniLatex.Export
import Outside
import Task exposing (Task)
import Types exposing (DocType(..), Model, Msg(..))


saveFileToLocalStorage : Model -> Cmd msg
saveFileToLocalStorage model =
    saveFileToLocalStorage_ model.currentDocument


saveFileToLocalStorage_ : Document -> Cmd msg
saveFileToLocalStorage_ document =
    Outside.sendInfo (Outside.WriteDocument document)


getListOfFilesInLocalStorage : Cmd msg
getListOfFilesInLocalStorage =
    Outside.sendInfo Outside.AskForDocumentList
