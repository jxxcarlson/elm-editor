module Helper.File exposing
    ( createDocument
    , docType
    , exportFile
    , fileExtension
    , getDocument
    , getDocumentList
    , read
    , requestFile
    , saveFile
    , titleFromFileName
    , updateDocType
    , updateDocument
    )

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


createDocument : String -> Document -> Cmd Msg
createDocument serverUrl document =
    Http.post
        { url = serverUrl ++ "/documents"
        , body = Http.jsonBody (Outside.extendedDocumentEncoder Config.token document)
        , expect = Http.expectJson Message Outside.messageDecoder
        }


updateDocument : String -> Document -> Cmd Msg
updateDocument serverUrl document =
    Http.request
        { method = "PUT"
        , headers = []
        , url = serverUrl ++ "/documents"
        , body = Http.jsonBody (Outside.extendedDocumentEncoder Config.token document)
        , expect = Http.expectJson Message Outside.messageDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


getDocument : String -> String -> Cmd Msg
getDocument serverUrl fileName =
    Http.get
        { url = serverUrl ++ "/document/" ++ fileName
        , expect = Http.expectJson GotDocument Outside.documentDecoder
        }


getDocumentList : String -> Cmd Msg
getDocumentList serverUrl =
    Http.get
        { url = serverUrl ++ "/documents"
        , expect = Http.expectJson GotDocuments Outside.documentListDecoder
        }


updateDocumentList : String -> Document -> Cmd Msg
updateDocumentList serverUrl document =
    Http.request
        { method = "PUT"
        , headers = []
        , url = serverUrl ++ "/documents"
        , body = Http.jsonBody (Outside.encodeMiniFileRecord document)
        , expect = Http.expectJson Message Outside.messageDecoder
        , timeout = Nothing
        , tracker = Nothing
        }



-- FILE I/O


updateDocType : DocType -> String -> String
updateDocType docType_ fileName =
    case docType_ of
        MiniLaTeXDoc ->
            titleFromFileName fileName ++ ".tex"

        MarkdownDoc ->
            titleFromFileName fileName ++ ".md"


titleFromFileName : String -> String
titleFromFileName fileName =
    fileName
        |> String.split "."
        |> List.reverse
        |> List.drop 1
        |> List.reverse
        |> String.join "."


fileExtension : String -> String
fileExtension str =
    str |> String.split "." |> List.reverse |> List.head |> Maybe.withDefault "txt"


read : File -> Cmd Msg
read file =
    Task.perform DocumentLoaded (File.toString file)


requestFile : Cmd Msg
requestFile =
    Select.file [ "text/markdown", "text/x-tex" ] RequestedFile


saveFile : Model -> Cmd msg
saveFile model =
    let
        content =
            "uuid: " ++ model.document.id ++ "\n\n" ++ model.document.content

        fileName =
            model.document.fileName
    in
    case model.docType of
        MarkdownDoc ->
            Download.string fileName "text/markdown" content

        MiniLaTeXDoc ->
            Download.string fileName "text/x-tex" content


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
