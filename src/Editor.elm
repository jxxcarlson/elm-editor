module Editor exposing
    ( Editor(..), init, loadArray
    , EditorMsg, getLines, getContextMenu, update, view
    , getContent, getCursor, getLineHeight, getSelectedString, getWrapOption, indexOf, initWithContent, insertAtCursor, lineAtCursor, loadString, placeInClipboard, resize, sendLine, setCursor, syncMessages
    )

{-| Use the Editor module to embed a pure Elm text editor
into another application. See `./demo` in the source
code for an example.


## Setting up the editor

@docs Editor, init, loadArray


## Using the editor

@docs EditorMsg, getLines, getContextMenu, update, view

-}

import Array exposing (Array)
import ArrayUtil
import Cmd.Extra
import ContextMenu exposing (ContextMenu)
import File.Select as Select
import Html as H exposing (Html)
import Menu.View exposing (viewContextMenu)
import Model exposing (Config, Context(..), Model, Msg(..))
import Update as U
import View exposing (viewDebug, viewEditor, viewHeader, viewSearchPanel)
import Wrap exposing (WrapOption)


{-| Opaque type for the editor
-}
type Editor
    = Editor Model


getLineHeight : Editor -> Float
getLineHeight (Editor data) =
    data.lineHeight


indexOf : Editor -> String -> Maybe ( Int, String )
indexOf (Editor data) key =
    ArrayUtil.indexOf key data.lines


{-| Place string in the editor's clipboard
-}
placeInClipboard : String -> Editor -> Editor
placeInClipboard str (Editor model) =
    Editor { model | clipboard = str }


insertAtCursor : String -> Editor -> Editor
insertAtCursor str (Editor data) =
    let
        n =
            str |> String.lines |> List.length

        newLines =
            ArrayUtil.insert data.cursor str data.lines

        newCursor =
            { line = data.cursor.line + n, column = data.cursor.column }
    in
    Editor
        { data
            | lines = newLines
            , clipboard = str
            , cursor = newCursor
        }


getCursor : Editor -> { line : Int, column : Int }
getCursor (Editor model) =
    model.cursor


setCursor : { line : Int, column : Int } -> Editor -> Editor
setCursor cursor (Editor data) =
    Editor { data | cursor = cursor }


getWrapOption : Editor -> WrapOption
getWrapOption (Editor model) =
    model.wrapOption


getSelectedString : Editor -> Maybe String
getSelectedString (Editor model) =
    model.selectedString


sendLine : Editor -> ( Editor, Cmd Msg )
sendLine (Editor model) =
    U.sendLine model
        |> (\( model_, message ) -> ( Editor model_, message ))


lineAtCursor : Editor -> String
lineAtCursor (Editor data) =
    Array.get data.cursor.line data.lines
        |> Maybe.withDefault "invalid cursor"


resize : Float -> Float -> Editor -> Editor
resize width height (Editor model) =
    Editor { model | width = width, height = height }


{-| View function for the editor
-}
view : Editor -> Html Msg
view (Editor model) =
    H.div []
        [ viewHeader model
        , viewSearchPanel model
        , viewEditor model
        , viewContextMenu model.width model
        , viewDebug model
        ]


getContent : Editor -> String
getContent editor =
    getLines editor
        |> Array.toList
        |> String.join "\n"


{-| Initialize the editor with a configuration
-}
init : Config -> ( Editor, Cmd Msg )
init config =
    let
        ( contextMenu, msg ) =
            ContextMenu.init

        cmd : Cmd Msg
        cmd =
            Cmd.map ContextMenuMsg msg
    in
    ( config, contextMenu )
        |> Model.init
        |> Editor
        |> Cmd.Extra.withCmd cmd


initWithContent : String -> Config -> Editor
initWithContent content config =
    let
        ( contextMenu, msg ) =
            ContextMenu.init

        cmd : Cmd Msg
        cmd =
            Cmd.map ContextMenuMsg msg
    in
    ( config, contextMenu )
        |> Model.init
        |> (\m -> { m | lines = content |> String.lines |> Array.fromList })
        |> Editor


{-| Update the editor with a message
-}
update : Msg -> Editor -> ( Editor, Cmd Msg )
update msg (Editor model) =
    let
        ( newModel, cmd ) =
            U.update msg model
    in
    ( Editor newModel, cmd )


{-| The messages to which the editor responds
-}
type alias EditorMsg =
    Msg


{-| Load content into the editor
-}
loadArray : Array String -> Editor -> Editor
loadArray array (Editor model) =
    Editor { model | lines = array }


loadString : String -> Editor -> Editor
loadString str (Editor model) =
    Editor { model | lines = str |> String.lines |> Array.fromList }


{-| Get the current editor content
-}
getLines : Editor -> Array String
getLines (Editor model) =
    model.lines


{-| Get the context menu
-}
getContextMenu : Editor -> ContextMenu Context
getContextMenu (Editor model) =
    model.contextMenu


syncMessages : List Msg
syncMessages =
    [ RemoveCharBefore
    , RemoveCharAfter
    , KillLine
    , Cut
    , Copy
    , NewLine
    , Paste
    , WrapAll
    , WrapSelection
    , Undo
    , Redo
    ]
