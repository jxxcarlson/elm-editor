module Helper.File exposing (export, getDocumentList, importFile, load, save)

import Document exposing (DocType(..), Document, Metadata)
import Editor
import File exposing (File)
import File.Download as Download
import File.Select as Select
import MiniLatex.Export
import Outside
import Task
import Types exposing (Model, Msg(..))


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



-- FILE I/O


save : Model -> Cmd msg
save model =
    case model.currentDocument of
        Nothing ->
            Cmd.none

        Just doc ->
            let
                content =
                    "uuid: " ++ doc.id ++ "\n\n" ++ doc.content

                fileName =
                    doc.fileName
            in
            case model.docType of
                MarkdownDoc ->
                    Download.string fileName "text/markdown" content

                MiniLaTeXDoc ->
                    Download.string fileName "text/x-tex" content

                IndexDoc ->
                    Download.string fileName "text/plain " content


export : Model -> Cmd msg
export model =
    case model.docType of
        MarkdownDoc ->
            Cmd.none

        MiniLaTeXDoc ->
            let
                contentForExport =
                    Editor.getContent model.editor |> MiniLatex.Export.toLaTeX
            in
            Download.string model.fileName "text/x-tex" contentForExport

        IndexDoc ->
            Cmd.none
