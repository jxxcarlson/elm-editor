module Helper.LaTeX exposing (..)

import Codec
import Config
import Editor exposing (Editor)
import Http
import Markdown.LaTeX
import MiniLatex.Export
import Model exposing (DocumentType(..), Msg(..), PrintingState(..))
import Process
import Random
import Task
import UUID


printToPDF model =
    let
        ( newUUID_, newSeed ) =
            Random.step UUID.generator model.randomSeed

        uuid =
            UUID.toString newUUID_
    in
    ( { model | randomSeed = newSeed, uuid = uuid }
    , Cmd.batch
        [ generatePdf model.documentType uuid model.editor
        , Process.sleep 1 |> Task.perform (always (ChangePrintingState PrintProcessing))
        ]
    )


generatePdf : DocumentType -> String -> Editor -> Cmd Msg
generatePdf docType uuid editor =
    let
        ( contentForExport, imageUrlList ) =
            case docType of
                MiniLaTeX ->
                    Editor.getContent editor
                        |> MiniLatex.Export.toLaTeXWithImages

                MathMarkdown ->
                    Editor.getContent editor
                        |> Markdown.LaTeX.export
                        |> MiniLatex.Export.toLaTeXWithImages

                PlainText ->
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
