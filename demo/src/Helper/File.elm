module Helper.File exposing (getDocumentList, importFile, load)

import File exposing (File)
import File.Select as Select
import Outside
import Task
import Types exposing (Msg(..))


getDocumentList : Cmd msg
getDocumentList =
    Cmd.batch
        [ Outside.sendInfo Outside.AskForDocumentList
        , Outside.getPreferences
        ]


importFile : Cmd Msg
importFile =
    Select.file [ "text/markdown", "text/x-tex" ] ImportFile


load : File -> Cmd Msg
load file =
    Task.perform DocumentLoaded (File.toString file)
