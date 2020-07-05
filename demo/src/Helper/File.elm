module Helper.File exposing (export, getDocumentList, importFile, load, save)

import Config
import Document exposing (DocType(..), Document, Metadata)
import Editor
import File exposing (File)
import File.Download as Download
import File.Select as Select
import MiniLatex.Export
import Outside
import Task
import Types exposing (AppMode(..), Model, Msg(..))


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


mimeType : DocType -> String
mimeType docType =
    case docType of
        MarkdownDoc ->
            "text/markdown"

        MiniLaTeXDoc ->
            "text/x-tex"

        IndexDoc ->
            "text/plain"


save : Model -> Cmd msg
save model =
    case model.currentDocument of
        Nothing ->
            Cmd.none

        Just doc ->
            case Config.appMode of
                Webapp ->
                    Download.string doc.fileName (mimeType doc.docType) doc.content

                Desktop ->
                    Outside.sendInfo (Outside.WriteDocumentToDownloadDirectory doc)


export : Model -> Cmd msg
export model =
    case model.currentDocument of
        Nothing ->
            Cmd.none

        Just document ->
            case document.docType of
                MarkdownDoc ->
                    Cmd.none

                MiniLaTeXDoc ->
                    let
                        contentForExport =
                            Editor.getContent model.editor |> MiniLatex.Export.toLaTeX

                        exportDoc =
                            { document | content = contentForExport }
                    in
                    case Config.appMode of
                        Webapp ->
                            Download.string model.fileName "text/x-tex" contentForExport

                        Desktop ->
                            Outside.sendInfo (Outside.WriteDocumentToDownloadDirectory exportDoc)

                IndexDoc ->
                    Cmd.none
