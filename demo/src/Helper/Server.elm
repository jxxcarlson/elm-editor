module Helper.Server exposing
    ( createDocument
    , exportFile
    , getDocument
    , getDocumentList
    , getDocumentToSync
    , isServerAlive
    , saveFile
    , updateDocument
    , updateDocumentList
    , updateFileList
    )

import Codec.Document
import Document exposing (DocType(..), Document, Metadata)
import Editor
import File exposing (File)
import File.Download as Download
import Http
import Json.Decode
import MiniLatex.Export
import Task exposing (Task)
import Types exposing (Model, Msg(..))


isServerAlive : String -> Cmd Msg
isServerAlive serverUrl =
    Http.get
        { url = serverUrl
        , expect = Http.expectString ServerAliveReply
        }


createDocument : String -> Document -> Cmd Msg
createDocument serverUrl document =
    Http.post
        { url = serverUrl ++ "/documents"
        , body = Http.jsonBody (Codec.Document.documentEncoder document)
        , expect = Http.expectJson Message Codec.Document.messageDecoder
        }


updateDocument : String -> Document -> Cmd Msg
updateDocument serverUrl document =
    Http.request
        { method = "PUT"
        , headers = []
        , url = serverUrl ++ "/documents"
        , body = Http.jsonBody (Codec.Document.documentEncoder document)
        , expect = Http.expectJson Message Codec.Document.messageDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


getDocument : String -> String -> Cmd Msg
getDocument serverUrl fileName =
    Http.get
        { url = serverUrl ++ "/document/" ++ fileName
        , expect = Http.expectJson GotDocument Codec.Document.documentDecoder
        }


getDocumentToSync : String -> String -> Cmd Msg
getDocumentToSync serverUrl fileName =
    Http.get
        { url = serverUrl ++ "/document/" ++ fileName
        , expect = Http.expectJson SyncDocument Codec.Document.documentDecoder
        }


getDocumentList : String -> Cmd Msg
getDocumentList serverUrl =
    Http.get
        { url = serverUrl ++ "/documents"
        , expect = Http.expectJson GotDocuments Codec.Document.metadataListDecoder
        }


updateDocumentList : String -> Metadata -> Cmd Msg
updateDocumentList serverUrl record =
    Http.request
        { method = "PUT"
        , headers = []
        , url = serverUrl ++ "/documents"
        , body = Http.jsonBody (Codec.Document.metadataEncoder record)
        , expect = Http.expectJson Message Codec.Document.messageDecoder
        , timeout = Nothing
        , tracker = Nothing
        }



-- FILE I/O


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

        IndexDoc ->
            Download.string fileName "text/plain " content


exportFile : Model -> Cmd msg
exportFile model =
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



-- HELPERS


updateFileList : Metadata -> List Metadata -> List Metadata
updateFileList rec fileList =
    let
        mapper r =
            case r.id == rec.id of
                False ->
                    r

                True ->
                    rec
    in
    List.map mapper fileList
