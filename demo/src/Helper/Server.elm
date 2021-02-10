module Helper.Server exposing
    ( createDocument
    , getDocument
    , getDocumentList
    , getDocumentToSync
    , isServerAlive
    , updateDocument
    , updateDocumentList
    , updateFileList
    )

import Codec.Document
import Document exposing (DocType(..), Document, Metadata)
import Http
import Types exposing (Msg(..))


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



-- HELPERS


updateFileList : Metadata -> List Metadata -> List Metadata
updateFileList rec fileList =
    let
        mapper r =
            if r.id == rec.id then
                rec

            else
                r
    in
    List.map mapper fileList
