module Helper.File exposing
    ( docType
    , exportFile
    , fileExtension
    , getListOfFilesInLocalStorage
    , read
    , requestFile
    , saveFile
    , saveFileToLocalStorage
    , titleFromFileName
    )

import Editor
import File exposing (File)
import File.Download as Download
import File.Select as Select
import MiniLatex.Export
import Outside
import Task exposing (Task)
import Types exposing (DocType(..), Model, Msg(..))



-- FILE I/O


fileExtension : String -> String
fileExtension str =
    str |> String.split "." |> List.reverse |> List.head |> Maybe.withDefault "md"


read : File -> Cmd Msg
read file =
    Task.perform DocumentLoaded (File.toString file)


requestFile : Cmd Msg
requestFile =
    Select.file [ "text/markdown", "text/x-tex" ] RequestedFile


saveFile : Model -> Cmd msg
saveFile model =
    case ( model.docType, model.fileName ) of
        ( MarkdownDoc, Just fileName ) ->
            Download.string fileName "text/markdown" (Editor.getContent model.editor)

        ( MiniLaTeXDoc, Just fileName ) ->
            Download.string fileName "text/x-tex" (Editor.getContent model.editor)

        ( _, _ ) ->
            Cmd.none


saveFileToLocalStorage : Model -> Cmd msg
saveFileToLocalStorage model =
    case model.fileName of
        Just fileName ->
            Outside.sendInfo (Outside.WriteFile ( "file:" ++ fileName, Editor.getContent model.editor ))

        Nothing ->
            Cmd.none


getListOfFilesInLocalStorage : Cmd msg
getListOfFilesInLocalStorage =
    Outside.sendInfo Outside.AskForFileList


exportFile : Model -> Cmd msg
exportFile model =
    case ( model.docType, model.fileName ) of
        ( MarkdownDoc, Just fileName ) ->
            Cmd.none

        ( MiniLaTeXDoc, Just fileName ) ->
            let
                contentForExport =
                    Editor.getContent model.editor |> MiniLatex.Export.toLaTeX
            in
            Download.string fileName "text/x-tex" contentForExport

        ( _, _ ) ->
            Cmd.none


titleFromFileName : String -> String
titleFromFileName fileName =
    fileName
        |> String.split "."
        |> List.reverse
        |> List.drop 1
        |> List.reverse
        |> String.join "."


docType : String -> DocType
docType fileName =
    case fileExtension fileName of
        "md" ->
            MarkdownDoc

        "tex" ->
            MiniLaTeXDoc

        "latex" ->
            MiniLaTeXDoc

        _ ->
            MarkdownDoc
