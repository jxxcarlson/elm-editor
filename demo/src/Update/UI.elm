module Update.UI exposing
    ( handleRenderMsg
    , managePopup
    , setViewportForElement
    , syncLR
    )

import Browser.Dom
import Cmd.Extra exposing (withCmd, withCmds, withNoCmd)
import Editor
import Helper.Common
import Helper.Server
import Helper.Sync
import Markdown.Render exposing (MarkdownMsg(..))
import MiniLatex.Edit
import Render.Types exposing (RenderMsg(..))
import Types exposing (DocumentStatus(..), FileLocation(..), Model, Msg(..), PopupStatus(..), PopupWindow(..))
import Update.Document
import Update.Helper
import View.Scroll


managePopup : PopupStatus -> Model -> ( Model, Cmd Types.Msg )
managePopup status model =
    let
        _ =
            Debug.log "Popup Status" status
    in
    case status of
        PopupOpen LocalStoragePopup ->
            -- TODO: needs to be eliminated
            { model | popupStatus = status }
                |> withCmd (Helper.Server.getDocumentList model.serverURL)

        PopupOpen FilePopup ->
            let
                tags_ =
                    Helper.Common.stringFromList model.document.tags

                categories_ =
                    Helper.Common.stringFromList model.document.categories

                newModel =
                    { model
                        | tags_ = tags_
                        , categories_ = categories_
                        , title_ = model.document.title
                        , subtitle_ = model.document.subtitle
                        , belongsTo_ = model.document.belongsTo
                    }
            in
            { newModel | popupStatus = status } |> withNoCmd

        PopupOpen NewFilePopup ->
            { model | popupStatus = status, fileName_ = "" } |> withNoCmd

        PopupOpen FileListPopup ->
            Update.Document.listDocuments status model

        PopupOpen IndexPopup ->
            { model | popupStatus = status } |> withNoCmd

        PopupOpen _ ->
            { model | popupStatus = status } |> withNoCmd

        PopupClosed ->
            { model | popupStatus = status } |> withNoCmd


setViewportForElement : Result error ( Browser.Dom.Element, Browser.Dom.Viewport ) -> Model -> ( Model, Cmd Types.Msg )
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


handleRenderMsg : RenderMsg -> Model -> ( Model, Cmd Msg )
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


syncLR : Model -> ( Model, Cmd Msg )
syncLR model =
    let
        ( newEditor, cmd ) =
            Editor.sendLine model.editor
    in
    ( { model | editor = newEditor }, Cmd.map EditorMsg cmd )
