module Helper.File exposing (checkServer, export, postToServer, save)

import Config
import Editor
import File.Download as Download
import Http
import Json.Encode exposing (encode, string)
import MiniLatex.Export
import Model exposing (Model, Msg(..))


mimeType : String -> String
mimeType fileName =
    let
        parts =
            String.split "." fileName
                |> List.reverse
                |> List.head
    in
    case parts of
        Nothing ->
            "text/txt"

        Just "tex" ->
            "text/x-latex"

        Just "md" ->
            "text/x-markdown"

        Just "txt" ->
            "text/plain"

        _ ->
            "text/plain"


encodeDocument : String -> String -> Json.Encode.Value
encodeDocument fileName content =
    Json.Encode.object
        [ ( "fileName", Json.Encode.string fileName )
        , ( "content", Json.Encode.string content )
        ]


postToServer : String -> String -> Cmd Msg
postToServer fileName content =
    Http.post
        { url = Config.fileServer ++ "/save"
        , body = Http.jsonBody (encodeDocument fileName content)
        , expect = Http.expectWhatever SavedToServer
        }


checkServer : Cmd Msg
checkServer =
    Http.get
        { url = Config.fileServer ++ "/hello"
        , expect = Http.expectString ServerIsAlive
        }


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
