module Editor exposing
    ( Editor(..), init, initWithContent, loadArray, loadString, resize, sendLine, syncMessages
    , EditorMsg, getLines, getContextMenu, update, view
    , insertAtCursor, lineAtCursor, getCursor, setCursor
    , placeInClipboard
    , getContent, getLineHeight, getSelectedString, getWrapOption, indexOf
    , replaceSelection, replaceSelection2
    )

{-| Use the Editor module to embed a pure Elm text editor
into another application. See `./demo` in the source
code for an example.
a


## Setting up the editor

@docs Editor, init, initWithContent, loadArray, loadString, resize, sendLine, syncMessages


## Using the editor

@docs EditorMsg, getLines, getContextMenu, update, view


## Cursor

@docs insertAtCursor, lineAtCursor, getCursor, setCursor


## Clipboard

@docs placeInClipboard


## Getting data from the editor

@docs getContent, getLineHeight, getSelectedString, getWrapOption, indexOf

-}

import Array exposing (Array)
import ArraySearch
import ArrayUtil
import Cmd.Extra
import ContextMenu exposing (ContextMenu)
import EditorModel exposing (Config, EditorModel)
import EditorMsg exposing (Context(..), EMsg(..), Selection(..), WrapOption)
import Html as H exposing (Html)
import Html.Attributes as HA
import Update as U
import Update.Function as Function
import Update.Scroll
import View.Editor
import View.EditorFooter
import View.Help
import View.Search


{-| Opaque type for the editor
-}
type Editor
    = Editor EditorModel


{-| -}
getLineHeight : Editor -> Float
getLineHeight (Editor data) =
    data.lineHeight


{-| Return (lineNumber, target) where target in the
editor's array inof lines is a string
which matches the key
-}
indexOf : Editor -> String -> List Int
indexOf (Editor data) key =
    ArraySearch.filter (String.words key) data.lines


{-| Place string in the editor's clipboard
-}
placeInClipboard : String -> Editor -> Editor
placeInClipboard str (Editor model) =
    Editor { model | clipboard = str }


{-| Insert a string into the editor at a
given cursor location
-}
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


replaceSelection : String -> Editor -> Editor
replaceSelection str (Editor data) =
    Editor (Function.replaceLines data (Array.fromList (String.lines str)))


replaceSelection2 : String -> Editor -> Editor
replaceSelection2 str (Editor data) =
    case data.selection of
        NoSelection ->
            Editor data

        SelectingFrom _ ->
            Editor data

        SelectedChar pos ->
            Editor { data | lines = ArrayUtil.replaceLines pos pos (arrayFromString str) data.lines }

        Selection sel1 sel2 ->
            Editor { data | lines = ArrayUtil.replaceLines sel1 sel2 (arrayFromString str) data.lines }


arrayFromString : String -> Array String
arrayFromString str =
    str |> String.lines |> Array.fromList


{-| -}
getCursor : Editor -> { line : Int, column : Int }
getCursor (Editor model) =
    model.cursor


{-| Set the editor's cursor to a given position
-}
setCursor : { line : Int, column : Int } -> Editor -> Editor
setCursor cursor (Editor data) =
    Editor { data | cursor = cursor }


{-| -}
getWrapOption : Editor -> WrapOption
getWrapOption (Editor model) =
    model.wrapOption


{-| -}
getSelectedString : Editor -> Maybe String
getSelectedString (Editor model) =
    model.selectedString


{-| Used by a host app to scroll the editor to scroll the
editor display to the line where the cursor is.
-}
sendLine : Editor -> ( Editor, Cmd EMsg )
sendLine (Editor model) =
    {- DOC sync RL: scroll line -}
    Update.Scroll.sendLine model
        |> (\( model_, message ) -> ( Editor model_, message ))


{-| Return the line where the cursor is
-}
lineAtCursor : Editor -> String
lineAtCursor (Editor data) =
    Array.get data.cursor.line data.lines
        |> Maybe.withDefault "invalid cursor"


{-| Resize the editor
-}
resize : Float -> Float -> Editor -> Editor
resize width height (Editor model) =
    Editor { model | width = width, height = height }


{-| View function for the editor
-}
view : Editor -> Html EMsg
view (Editor model) =
    H.div [ HA.style "background-color" "#555", HA.style "height" (String.fromFloat (model.height + 0) ++ "px") ]
        [ View.Editor.viewHeader model
        , View.Search.searchPanel model
        , View.Search.replacePanel model
        , View.Editor.view model
        , View.EditorFooter.view model

        -- , viewContextMenu model.width model
        , View.Editor.viewDebug model
        , View.Help.view model |> H.map MarkdownMsg
        ]


{-| Retrieve text from editor
-}
getContent : Editor -> String
getContent editor =
    getLines editor
        |> Array.toList
        |> String.join "\n"


{-| Initialize the editor with a configuration
-}
init : Config -> ( Editor, Cmd EMsg )
init config =
    let
        ( contextMenu, msg ) =
            ContextMenu.init

        cmd : Cmd EMsg
        cmd =
            Cmd.map ContextMenuMsg msg
    in
    ( config, contextMenu )
        |> EditorModel.init
        |> Editor
        |> Cmd.Extra.withCmd cmd


{-| -Initialize the the editor with
given content : String
-}
initWithContent : String -> Config -> Editor
initWithContent content config =
    let
        ( contextMenu, _ ) =
            ContextMenu.init
    in
    ( config, contextMenu )
        |> EditorModel.init
        |> (\m -> { m | lines = content |> String.lines |> Array.fromList })
        |> Editor


{-| Update the editor with a message
-}
update : EMsg -> Editor -> ( Editor, Cmd EMsg )
update msg (Editor model) =
    let
        ( newModel, cmd ) =
            U.update msg model
    in
    ( Editor newModel, cmd )


{-| The messages to which the editor responds
-}
type alias EditorMsg =
    EMsg


{-| Load content into the editor
-}
loadArray : Array String -> Editor -> Editor
loadArray array (Editor model) =
    Editor { model | lines = array }


{-| Load a string into the editor
-}
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


{-| Messages to be handled by a host app in some default way
-}
syncMessages : List EMsg
syncMessages =
    [ RemoveCharBefore
    , RemoveCharAfter
    , KillLine
    , Cut
    , Copy
    , CopyPasteClipboard
    , NewLine
    , Paste
    , WrapAll
    , WrapSelection
    , Undo
    , Redo
    , Indent
    , Deindent
    ]
