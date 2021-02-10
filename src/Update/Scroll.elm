module Update.Scroll exposing
    ( jumpToBottom
    , jumpToHeightForSync
    , rollSearchSelectionBackward
    , rollSearchSelectionForward
    , sendLine
    , setEditorViewportForLine
    , toString
    )

import Array
import ArrayUtil
import Browser.Dom as Dom
import EditorModel exposing (EditorModel)
import EditorMsg exposing (EMsg(..), Position, Selection(..))
import RollingList
import Search
import Task


setEditorViewportForLine : Float -> Int -> Cmd EMsg
setEditorViewportForLine lineHeight lineNumber =
    let
        y =
            toFloat lineNumber * lineHeight
    in
    if y >= 0 then
        Dom.setViewportOf "__editor__" 0 y
            |> Task.andThen (\_ -> Dom.getViewportOf "__editor__")
            |> Task.attempt (\info -> GotViewport info)

    else
        Cmd.none


{-| Search for str and scroll to first hit. Used internally.
-}
toString : String -> EditorModel -> ( EditorModel, Cmd EMsg )
toString str model =
    let
        searchResults =
            Search.hits str model.lines
    in
    case List.head searchResults of
        Nothing ->
            ( { model | searchResults = RollingList.fromList [], searchTerm = str, selection = NoSelection }, Cmd.none )

        Just (Selection cursor end) ->
            ( { model
                | cursor = cursor
                , selection = Selection cursor end
                , searchResults = RollingList.fromList searchResults
                , searchTerm = str
                , searchResultIndex = 0
              }
            , setEditorViewportForLine model.lineHeight (max 0 (cursor.line - 5))
            )

        _ ->
            ( { model | searchResults = RollingList.fromList [], searchTerm = str, selection = NoSelection }, Cmd.none )


jumpToHeightForSync : Maybe String -> Selection -> Float -> Cmd EMsg
jumpToHeightForSync currentLine selection y =
    Dom.setViewportOf "__editor__" 0 (y - 80)
        |> Task.andThen (\_ -> Dom.getViewportOf "__editor__")
        |> Task.attempt (\info -> GotViewportForSync currentLine selection info)


jumpToBottom : EditorModel -> Cmd EMsg
jumpToBottom model =
    if model.cursor.line == (Array.length model.lines - 1) then
        Dom.getViewportOf "__editor__"
            |> Task.andThen (\info -> Dom.setViewportOf "__editor__" 0 info.scene.height)
            |> Task.attempt (\_ -> EditorNoOp)

    else
        Cmd.none


rollSearchSelectionForward : EditorModel -> ( EditorModel, Cmd EMsg )
rollSearchSelectionForward model =
    let
        searchResults_ =
            RollingList.roll model.searchResults

        searchResultList =
            RollingList.toList searchResults_

        maxSearchHitIndex =
            searchResultList |> List.length |> (\x -> x - 1)

        newSearchResultIndex =
            if model.searchResultIndex >= maxSearchHitIndex then
                0

            else
                model.searchResultIndex + 1
    in
    case RollingList.current searchResults_ of
        Just (Selection cursor end) ->
            ( { model
                | cursor = cursor
                , selection = Selection cursor end
                , searchResults = searchResults_
                , searchResultIndex = newSearchResultIndex
              }
            , setEditorViewportForLine model.lineHeight (max 0 (cursor.line - 5))
            )

        _ ->
            ( model, Cmd.none )


rollSearchSelectionBackward : EditorModel -> ( EditorModel, Cmd EMsg )
rollSearchSelectionBackward model =
    let
        searchResults_ =
            RollingList.rollBack model.searchResults

        searchResultList =
            RollingList.toList searchResults_

        maxSearchResultIndex =
            searchResultList |> List.length |> (\x -> x - 1)

        newSearchResultIndex =
            if model.searchResultIndex == 0 then
                maxSearchResultIndex

            else
                model.searchResultIndex - 1
    in
    case RollingList.current searchResults_ of
        Just (Selection cursor end) ->
            ( { model
                | cursor = cursor
                , selection = Selection cursor end
                , searchResults = searchResults_
                , searchResultIndex = newSearchResultIndex
              }
            , setEditorViewportForLine model.lineHeight (max 0 (cursor.line - 5))
            )

        _ ->
            ( model, Cmd.none )


sendLine : EditorModel -> ( EditorModel, Cmd EMsg )
sendLine model =
    {- DOC sync RL and LR: scroll line (2) -}
    let
        y =
            max 0 (model.lineHeight * toFloat model.cursor.line - verticalOffsetInSourceText)

        newCursor =
            { line = model.cursor.line, column = 0 }

        currentLine : Maybe String
        currentLine =
            Array.get newCursor.line model.lines

        paragraphStart : Int
        paragraphStart =
            ArrayUtil.paragraphStart newCursor model.lines

        paragraphEnd : Int
        paragraphEnd =
            ArrayUtil.paragraphEnd newCursor model.lines

        lastLine : Maybe String
        lastLine =
            Array.get paragraphEnd model.lines

        endColumn : Maybe Int
        endColumn =
            Maybe.map String.length lastLine

        selection =
            case endColumn of
                Just column ->
                    Selection (Position paragraphStart 0) (Position paragraphEnd column)

                Nothing ->
                    NoSelection
    in
    ( { model | cursor = newCursor, selection = selection }, jumpToHeightForSync currentLine selection y )


verticalOffsetInSourceText : Float
verticalOffsetInSourceText =
    4
