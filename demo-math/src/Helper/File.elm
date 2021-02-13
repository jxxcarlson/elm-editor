module Helper.File exposing (export, save)

import Editor
import File exposing (File)
import File.Download as Download
import File.Select as Select
import MiniLatex.Export
import Model exposing (Model, Msg(..))
import Task



--importFile : Cmd Msg
--importFile =
--    Select.file [ "text/markdown", "text/x-tex" ] ImportFile
--
--
--load : File -> Cmd Msg
--load file =
--    Task.perform DocumentLoaded (File.toString file)


save : Model -> Cmd msg
save model =
    let
        content =
            Editor.getContent model.editor
    in
    Download.string model.fileName "text/x-tex" content


export : Model -> Cmd msg
export model =
    let
        contentForExport =
            Editor.getContent model.editor |> MiniLatex.Export.toLaTeX
    in
    Download.string model.fileName "text/x-tex" contentForExport
