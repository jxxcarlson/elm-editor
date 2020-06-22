module Helper.Load exposing
    ( config
    , loadAboutDocument
    , loadDocument
    , updateModelWithDocument
    )

import Data
import Document exposing (DocType(..), Document)
import Editor
import EditorMsg exposing (WrapOption(..))
import Helper.Common
import Helper.Server
import List.Extra
import Markdown.Option exposing (MarkdownOption(..))
import Render exposing (RenderingOption(..))
import Time
import Types exposing (Model, Msg(..))
import UuidHelper


loadAboutDocument : Model -> Model
loadAboutDocument model =
    updateModelWithDocument Data.about model


{-|

    - Load the document content into the editor
    - Compute the rendered content and store it in the model.

-}
updateModelWithDocument : Document -> Model -> Model
updateModelWithDocument document model =
    let
        docType =
            Document.docType document.fileName

        renderingOption =
            case docType of
                MarkdownDoc ->
                    OMarkdown ExtendedMath

                MiniLaTeXDoc ->
                    OMiniLatex
    in
    { model
        | renderingData = Render.load ( 0, 0 ) model.counter renderingOption document.content
        , fileName = document.fileName
        , fileName_ = document.fileName
        , counter = model.counter + 1
        , editor =
            Editor.initWithContent document.content
                (config { width = model.width, height = model.height, wrapOption = DontWrap })
        , docTitle = document.fileName
        , docType = docType
        , document = document
    }


{-|

    - Create a document with given file name, content, and document type into the model
    - Load the content into the editor
    - Compute the rendered content and store it in the model.

-}
loadDocument : Time.Posix -> String -> String -> DocType -> Model -> Model
loadDocument time fileName_ content_ docType_ model =
    let
        author_ =
            model.preferences |> Maybe.map .userName |> Maybe.withDefault "unknown"

        doc =
            { fileName = fileName_
            , id = model.uuid
            , author = author_
            , timeCreated = time
            , timeUpdated = time
            , tags = []
            , categories = []
            , content = content_
            , title = ""
            , subtitle = ""
            , abstract = ""
            , belongsTo = ""
            }
    in
    updateModelWithDocument doc model
        |> UuidHelper.newUuid


config flags =
    { width = Helper.Common.windowWidth flags.width
    , height = Helper.Common.windowHeight (flags.height - 10)
    , fontSize = 16
    , verticalScrollOffset = 3
    , debugOn = False
    , wrapOption = DontWrap
    }
