module Update.UI exposing (managePopup
  , syncLR
  , setViewportForElement
  , handleRenderMsg
  )

import Types exposing(Model, PopupStatus(..),  Msg(..), PopupWindow(..), DocumentStatus(..), FileLocation(..))
import Cmd.Extra exposing (withCmd,withNoCmd, withCmds)
import Helper.Server
import Helper.File
import Helper.Common
import View.Scroll
import Markdown.Render exposing (MarkdownMsg(..))
import MiniLatex.Edit
import Helper.Sync
import Update.Helper
import Editor
import Browser.Dom
import Render.Types exposing (RenderMsg(..))



managePopup : PopupStatus -> Model -> (Model, Cmd Types.Msg)
managePopup status model =
  case status of
    PopupOpen LocalStoragePopup ->
        -- TODO: needs to be eliminated
        { model | popupStatus = status }
            |> withCmd (Helper.Server.getDocumentList model.fileStorageUrl)

    PopupOpen FilePopup ->
        let
            tags_ = Helper.Common.stringFromList model.document.tags
            categories_ = Helper.Common.stringFromList model.document.categories
            newModel = { model | tags_ = tags_
                         , categories_ = categories_
                         , title_ = model.document.title
                         , subtitle_ = model.document.subtitle
                         ,  belongsTo_ = model.document.belongsTo}
        in
        { newModel | popupStatus = status } |> withNoCmd

    PopupOpen NewFilePopup ->
        { model | popupStatus = status } |> withNoCmd

    PopupOpen FileListPopup ->
        -- TODO: Add File API
        { model | popupStatus = status, documentStatus = DocumentSaved }
            |> withCmds
              (case model.fileLocation of
                  LocalFiles ->
                    [ Helper.File.getDocumentList
                    ]
                  RemoteFiles ->
                    [ Helper.Server.getDocumentList model.fileStorageUrl
                    , Helper.Server.updateDocument model.fileStorageUrl model.document
                    ])
    PopupOpen _ ->
        { model | popupStatus = status } |> withNoCmd

    PopupClosed ->
        { model | popupStatus = status } |> withNoCmd


setViewportForElement : Result error (Browser.Dom.Element, Browser.Dom.Viewport) -> Model -> (Model, Cmd Types.Msg)
setViewportForElement result model =
   case result of
        Ok ( element, viewport ) ->
            model
                |> Update.Helper.postMessage "synced"
                |> withCmd (View.Scroll.setViewPortForSelectedLineInRenderedText element viewport)

        Err _ ->
            model
                |> Update.Helper.postMessage "sync error"
                |> withNoCmd



--setViewportForSync : Result error (Browser.Dom.Element, Browser.Dom.Viewport) -> Model -> (Model, Cmd Msg)
--setViewportForSync result model =
--    case result of
--        Ok ( element, viewport ) ->
--            model
--                |> Update.Helper.postMessage "synced"
--                |> withCmd (View.Scroll.setViewPortForSelectedLineInRenderedText element viewport)
--
--        Err _ ->
--            model
--                |> Update.Helper.postMessage "sync error"
--                |> withNoCmd


handleRenderMsg : RenderMsg -> Model -> (Model, Cmd Msg)
handleRenderMsg renderMsg model =
            {- DOC sync RL: renderMsg receives the id of the element clicked in
               the rendered text.  It is used highlight the corresponding
               source text (RL sync)
            -}
            case renderMsg of
                LaTeXMsg latexMsg ->
                    case latexMsg of
                        MiniLatex.Edit.IDClicked id ->
                            Helper.Sync.onId id model

                Render.Types.MarkdownMsg markdownMsg ->
                    case markdownMsg of
                        IDClicked id ->
                            Helper.Sync.onId id model

syncLR : Model -> (Model, Cmd Msg)
syncLR model =
    let
        ( newEditor, cmd ) =
            Editor.sendLine model.editor
    in
    ( { model | editor = newEditor }, Cmd.map EditorMsg cmd )