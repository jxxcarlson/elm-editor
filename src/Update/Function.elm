module Update.Function exposing
    ( breakLineAfter
    , breakLineBefore
    , copySelection
    , deleteSelection
    , insertChar
    , insertLineAfter
    , newLine
    , pasteSelection
    , replaceLineAt
    , replaceLines
    , toggleViewMode
    , unload
    )

import Action
import Array exposing (Array)
import ArrayUtil
import Common
import Debounce exposing (Debounce)
import Model exposing (Model, Msg(..), Position, Selection(..), ViewMode(..))
import Task


copySelection : Model -> ( Model, Cmd Msg )
copySelection model =
    let
        ( debounce, debounceCmd ) =
            Debounce.push Model.debounceConfig "RCB" model.debounce
    in
    case model.selection of
        (Selection beginSel endSel) as sel ->
            let
                ( _, selectedText ) =
                    Action.deleteSelection sel model.lines
            in
            ( { model
                | cursor = { endSel | column = endSel.column + 1 }
                , selection = NoSelection
                , selectedText = selectedText
              }
                |> Common.sanitizeHover
            , debounceCmd
            )
                |> Common.recordHistory model

        _ ->
            ( model, Cmd.none )


pasteSelection : Model -> ( Model, Cmd Msg )
pasteSelection model =
    let
        n =
            Array.length model.selectedText

        newCursor =
            { line = model.cursor.line + n, column = model.cursor.column }
    in
    ( { model
        | lines = ArrayUtil.paste model.cursor model.selectedText model.lines
        , cursor = newCursor
      }
    , Cmd.none
    )


replaceLines : Model -> Array String -> Model
replaceLines model strings =
    let
        n =
            Array.length strings

        newCursor =
            { line = model.cursor.line + n, column = model.cursor.column }
    in
    case model.selection of
        Selection p1 p2 ->
            { model
                | lines = ArrayUtil.replaceLines p1 p2 strings model.lines

                -- , cursor = newCursor
            }

        _ ->
            model


deleteSelection : Model -> ( Model, Cmd Msg )
deleteSelection model =
    let
        ( debounce, debounceCmd ) =
            Debounce.push Model.debounceConfig "RCB" model.debounce
    in
    case model.selection of
        NoSelection ->
            ( Common.removeCharBefore { model | debounce = debounce }
                |> Common.sanitizeHover
            , debounceCmd
            )
                |> Common.recordHistory model

        (Selection beginSel endSel) as sel ->
            let
                ( newLines, selectedText ) =
                    Action.deleteSelection sel model.lines
            in
            ( { model
                | lines = newLines
                , cursor = beginSel
                , selection = NoSelection
                , selectedText = selectedText
              }
                |> Common.sanitizeHover
            , debounceCmd
            )
                |> Common.recordHistory model

        SelectedChar _ ->
            ( Common.removeCharBefore { model | debounce = debounce }
                |> Common.sanitizeHover
            , debounceCmd
            )
                |> Common.recordHistory model

        _ ->
            ( Common.removeCharBefore { model | debounce = debounce }
                |> Common.sanitizeHover
            , debounceCmd
            )
                |> Common.recordHistory model



-- BREAK LINES


breakLineBefore : Int -> String -> ( String, Maybe String )
breakLineBefore k str =
    case String.length str > k of
        False ->
            ( str, Nothing )

        True ->
            let
                indexOfPrecedingBlank =
                    str
                        |> String.indexes " "
                        |> List.filter (\i -> i < k)
                        |> List.reverse
                        |> List.head
                        |> Maybe.withDefault k
            in
            case indexOfPrecedingBlank <= k of
                False ->
                    ( str, Nothing )

                True ->
                    splitStringAt (indexOfPrecedingBlank + 1) str
                        |> (\( a, b ) -> ( a, Just b ))


breakLineAfter : Int -> String -> ( String, Maybe String )
breakLineAfter k str =
    case String.length str > k of
        False ->
            ( str, Nothing )

        True ->
            let
                indexOfSucceedingBlank =
                    str
                        |> String.indexes " "
                        |> List.filter (\i -> i > k)
                        |> List.head
                        |> Maybe.withDefault k
            in
            splitStringAt (indexOfSucceedingBlank + 1) str
                |> (\( a, b ) -> ( a, Just b ))


splitStringAt : Int -> String -> ( String, String )
splitStringAt k str =
    let
        n =
            String.length str
    in
    ( String.slice 0 k str, String.slice k n str )


replaceLineAt : Int -> String -> Model -> Model
replaceLineAt k str model =
    { model | lines = Array.set k str model.lines }


insertLineAfter : Int -> String -> Model -> Model
insertLineAfter k str model =
    { model | lines = ArrayUtil.insertLineAfter k str model.lines }



-- MORE STUFF


newLine : Model -> Model
newLine ({ cursor, lines } as model) =
    let
        { line, column } =
            cursor

        linesList : List String
        linesList =
            Array.toList lines

        line_ : Int
        line_ =
            line + 1

        contentUntilCursor : List String
        contentUntilCursor =
            linesList
                |> List.take line_
                |> List.indexedMap
                    (\i content ->
                        if i == line then
                            String.left column content

                        else
                            content
                    )

        restOfLineAfterCursor : String
        restOfLineAfterCursor =
            String.dropLeft column (Common.lineContent lines line)

        restOfLines : List String
        restOfLines =
            List.drop line_ linesList

        newLines : Array String
        newLines =
            (contentUntilCursor
                ++ [ restOfLineAfterCursor ]
                ++ restOfLines
            )
                |> Array.fromList

        newCursor : Position
        newCursor =
            { line = line_
            , column = 0
            }
    in
    { model
        | lines = newLines
        , cursor = newCursor
    }


insertChar : String -> Model -> Model
insertChar char ({ cursor, lines } as model) =
    let
        { line, column } =
            cursor

        maxLineLength =
            20

        lineWithCharAdded : String -> String
        lineWithCharAdded content =
            String.left column content
                ++ char
                ++ String.dropLeft column content

        newLines : Array String
        newLines =
            lines
                |> Array.indexedMap
                    (\i content ->
                        if i == line then
                            lineWithCharAdded content

                        else
                            content
                    )

        newCursor : Position
        newCursor =
            { line = line
            , column = column + 1
            }
    in
    { model
        | lines = newLines
        , cursor = newCursor
    }



-- DEBOUNCE


unload : String -> Cmd Msg
unload s =
    Task.perform Unload (Task.succeed s)



--


toggleViewMode : Model -> Model
toggleViewMode model =
    case model.viewMode of
        Light ->
            { model | viewMode = Dark }

        Dark ->
            { model | viewMode = Light }
