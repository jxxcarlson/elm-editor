module Helper.LaTeX exposing (..)

import Codec
import Config
import Http
import MiniLatex.Export
import Model exposing (Msg(..), PrintingState(..))
import Process
import Task


printToPDF model =
    ( model
    , Cmd.batch
        [ generatePdf model.sourceText
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


generatePdf : String -> Cmd Msg
generatePdf sourceText =
    let
        ( contentForExport, imageUrlList ) =
            sourceText
                |> MiniLatex.Export.toLaTeXWithImages
    in
    Http.request
        { method = "POST"
        , headers = [ Http.header "Content-Type" "application/json" ]
        , url = Config.pdfServer ++ "/pdf"
        , body = Http.jsonBody (Codec.encodeForPDF Config.testUuid contentForExport imageUrlList)
        , expect = Http.expectString GotPdfLink
        , timeout = Nothing
        , tracker = Nothing
        }
