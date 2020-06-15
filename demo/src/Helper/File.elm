module Helper.File exposing (getDocumentList)

import Outside


getDocumentList : Cmd msg
getDocumentList =
    Outside.sendInfo Outside.AskForFileList
