module Helper.LaTeX exposing (..)

import Codec
import Config
import Editor exposing (Editor)
import Http
import MiniLatex.Export
import Model exposing (Msg(..), PrintingState(..))
import Process
import Random
import Task
import UUID


printToPDF model =
    let
        ( newUUID, newSeed ) =
            Random.step UUID.generator model.randomSeed
    in
    ( { model | randomSeed = newSeed, uuid = UUID.toString newUUID }
    , Cmd.batch
        [ generatePdf (UUID.toString newUUID) model.editor
        , Process.sleep 1 |> Task.perform (always (ChangePrintingState PrintProcessing))
        ]
    )


gotPdfLink model result =
    case result of
        Err _ ->
            ( model, Cmd.none )

        Ok docId ->
            ( model
            , Cmd.batch
                [ Process.sleep 5 |> Task.perform (always (ChangePrintingState PrintReady))
                ]
            )


generatePdf : String -> Editor -> Cmd Msg
generatePdf uuid editor =
    let
        ( contentForExport, imageUrlList ) =
            Editor.getContent editor
                |> MiniLatex.Export.toLaTeXWithImages
    in
    Http.request
        { method = "POST"
        , headers = [ Http.header "Content-Type" "application/json" ]
        , url = Config.pdfServer ++ "/pdf"
        , body = Http.jsonBody (Codec.encodeForPDF uuid contentForExport imageUrlList)
        , expect = Http.expectString GotPdfLink
        , timeout = Nothing
        , tracker = Nothing
        }
