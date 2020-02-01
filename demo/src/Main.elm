module Main exposing (main)

import Array exposing (Array)
import Browser
import Browser.Dom as Dom
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Html.Events as HE
import Html.Lazy
import Json.Decode as JD exposing (Decoder)
import Task


type alias Flags =
    ()


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { lines : Array String
    , cursor : Position
    , hover : Hover
    , selection : Selection
    , numberOfLinesToAdd : Maybe Int
    }


type Hover
    = NoHover
    | HoverLine Int
    | HoverChar Position


stringFromHover : Hover -> String
stringFromHover hover =
    case hover of
        NoHover ->
            "NoHover"

        HoverLine k ->
            "HoverLine: " ++ String.fromInt k

        HoverChar p ->
            "HoverChar: " ++ stringFromPosition p


type Selection
    = NoSelection
    | SelectingFrom Hover
    | SelectedChar Position
    | Selection Position Position


stringFromSelection sel =
    case sel of
        NoSelection ->
            "NoSelection"

        SelectingFrom h ->
            "Hover: " ++ stringFromHover h

        SelectedChar p ->
            "SelectedChar: " ++ stringFromPosition p

        Selection p q ->
            "From " ++ stringFromPosition p ++ " to " ++ stringFromPosition q


type alias Position =
    { line : Int
    , column : Int
    }


stringFromPosition : Position -> String
stringFromPosition p =
    "(" ++ String.fromInt p.line ++ ", " ++ String.fromInt p.column ++ ")"


type Msg
    = NoOp
    | MoveUp
    | MoveDown
    | MoveLeft
    | MoveRight
    | NewLine
    | InsertChar Char
    | RemoveCharBefore
    | RemoveCharAfter
    | Hover Hover
    | GoToHoveredPosition
    | StartSelecting
    | StopSelecting
      --
    | Clear
    | TestLines
    | InputNumberOfLines String


initModel : Model
initModel =
    { lines = Array.fromList [ "" ]
    , cursor = Position 0 0
    , hover = NoHover
    , selection = NoSelection
    , numberOfLinesToAdd = Nothing
    }


init : Flags -> ( Model, Cmd Msg )
init =
    \() ->
        ( initModel
        , Dom.focus "editor"
            |> Task.attempt (always NoOp)
        )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


keyDecoder : Decoder Msg
keyDecoder =
    JD.field "key" JD.string
        |> JD.andThen keyToMsg


keyToMsg : String -> Decoder Msg
keyToMsg string =
    case String.uncons string of
        Just ( char, "" ) ->
            JD.succeed (InsertChar char)

        _ ->
            case string of
                "ArrowUp" ->
                    JD.succeed MoveUp

                "ArrowDown" ->
                    JD.succeed MoveDown

                "ArrowLeft" ->
                    JD.succeed MoveLeft

                "ArrowRight" ->
                    JD.succeed MoveRight

                "Backspace" ->
                    JD.succeed RemoveCharBefore

                "Delete" ->
                    JD.succeed RemoveCharAfter

                "Enter" ->
                    JD.succeed NewLine

                _ ->
                    JD.fail "This key does nothing"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        MoveUp ->
            ( { model | cursor = moveUp model.cursor model.lines }
            , Cmd.none
            )

        MoveDown ->
            ( { model | cursor = moveDown model.cursor model.lines }
            , Cmd.none
            )

        MoveLeft ->
            ( { model | cursor = moveLeft model.cursor model.lines }
            , Cmd.none
            )

        MoveRight ->
            ( { model | cursor = moveRight model.cursor model.lines }
            , Cmd.none
            )

        NewLine ->
            ( newLine model
                |> sanitizeHover
            , Cmd.none
            )

        InsertChar char ->
            ( insertChar char model
            , Cmd.none
            )

        RemoveCharBefore ->
            ( removeCharBefore model
                |> sanitizeHover
            , Cmd.none
            )

        RemoveCharAfter ->
            ( removeCharAfter model
                |> sanitizeHover
            , Cmd.none
            )

        Hover hover ->
            ( { model | hover = hover }
                |> sanitizeHover
            , Cmd.none
            )

        GoToHoveredPosition ->
            ( { model
                | cursor =
                    case model.hover of
                        NoHover ->
                            model.cursor

                        HoverLine line ->
                            { line = line
                            , column = lastColumn model.lines line
                            }

                        HoverChar position ->
                            position
              }
            , Cmd.none
            )

        StartSelecting ->
            ( { model | selection = SelectingFrom model.hover }
            , Cmd.none
            )

        StopSelecting ->
            -- Selection for all other
            let
                endHover =
                    model.hover

                newSelection =
                    case model.selection of
                        NoSelection ->
                            NoSelection

                        SelectingFrom startHover ->
                            if startHover == endHover then
                                case startHover of
                                    NoHover ->
                                        NoSelection

                                    HoverLine _ ->
                                        NoSelection

                                    HoverChar position ->
                                        SelectedChar position

                            else
                                hoversToPositions model.lines startHover endHover
                                    |> Maybe.map (\( from, to ) -> Selection from to)
                                    |> Maybe.withDefault NoSelection

                        SelectedChar _ ->
                            NoSelection

                        Selection _ _ ->
                            NoSelection
            in
            ( { model | selection = newSelection }
            , Cmd.none
            )

        Clear ->
            ( { model | lines = Array.fromList [ "" ] }, Cmd.none )

        TestLines ->
            case model.numberOfLinesToAdd of
                Nothing ->
                    ( model, Cmd.none )

                Just n ->
                    ( { model | lines = Array.append model.lines (testLines n) }, Cmd.none )

        InputNumberOfLines str ->
            ( { model | numberOfLinesToAdd = String.toInt str }, Cmd.none )


hoversToPositions : Array String -> Hover -> Hover -> Maybe ( Position, Position )
hoversToPositions lines from to =
    let
        selectionLinePosition : Int -> Position -> ( Position, Position )
        selectionLinePosition line position =
            if line >= position.line then
                ( position
                , { line = line, column = lastColumn lines line }
                )

            else
                ( { line = line + 1, column = 0 }
                , position
                )
    in
    case ( from, to ) of
        ( NoHover, _ ) ->
            Nothing

        ( _, NoHover ) ->
            Nothing

        ( HoverLine line1, HoverLine line2 ) ->
            let
                smaller =
                    min line1 line2

                bigger =
                    max line1 line2
            in
            Just
                ( { line = smaller + 1, column = 0 }
                , { line = bigger, column = lastColumn lines bigger }
                )

        ( HoverLine line, HoverChar position ) ->
            Just (selectionLinePosition line position)

        ( HoverChar position, HoverLine line ) ->
            Just (selectionLinePosition line position)

        ( HoverChar position1, HoverChar position2 ) ->
            let
                ( smaller, bigger ) =
                    if comparePositions position1 position2 == LT then
                        ( position1, position2 )

                    else
                        ( position2, position1 )
            in
            Just ( smaller, bigger )


comparePositions : Position -> Position -> Order
comparePositions from to =
    if from.line < to.line || (from.line == to.line && from.column < to.column) then
        LT

    else if from == to then
        EQ

    else
        GT


sanitizeHover : Model -> Model
sanitizeHover model =
    { model
        | hover =
            case model.hover of
                NoHover ->
                    model.hover

                HoverLine line ->
                    HoverLine (clamp 0 (lastLine model.lines) line)

                HoverChar { line, column } ->
                    let
                        sanitizedLine =
                            clamp 0 (lastLine model.lines) line

                        sanitizedColumn =
                            clamp 0 (lastColumn model.lines sanitizedLine) column
                    in
                    HoverChar
                        { line = sanitizedLine
                        , column = sanitizedColumn
                        }
    }


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
            String.dropLeft column (lineContent lines line)

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


insertChar : Char -> Model -> Model
insertChar char ({ cursor, lines } as model) =
    let
        { line, column } =
            cursor

        lineWithCharAdded : String -> String
        lineWithCharAdded content =
            String.left column content
                ++ String.fromChar char
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


removeCharBefore : Model -> Model
removeCharBefore ({ cursor, lines } as model) =
    if isStartOfDocument cursor then
        model

    else
        let
            { line, column } =
                cursor

            lineIsEmpty : Bool
            lineIsEmpty =
                lineContent lines line
                    |> String.isEmpty

            removeCharFromLine : ( Int, String ) -> List String
            removeCharFromLine ( lineNum, content ) =
                if lineNum == line - 1 then
                    if isFirstColumn column then
                        [ content ++ lineContent lines line ]

                    else
                        [ content ]

                else if lineNum == line then
                    if isFirstColumn column then
                        []

                    else
                        [ String.left (column - 1) content
                            ++ String.dropLeft column content
                        ]

                else
                    [ content ]

            newLines : Array String
            newLines =
                lines
                    |> Array.toIndexedList
                    |> List.concatMap removeCharFromLine
                    |> Array.fromList
        in
        { model
            | lines = newLines
            , cursor = moveLeft cursor lines
        }


removeCharAfter : Model -> Model
removeCharAfter ({ cursor, lines } as model) =
    if isEndOfDocument lines cursor then
        model

    else
        let
            { line, column } =
                cursor

            isOnLastColumn : Bool
            isOnLastColumn =
                isLastColumn lines line column

            removeCharFromLine : ( Int, String ) -> List String
            removeCharFromLine ( lineNum, content ) =
                if lineNum == line then
                    if isOnLastColumn then
                        [ content ++ lineContent lines (line + 1) ]

                    else
                        [ String.left column content
                            ++ String.dropLeft (column + 1) content
                        ]

                else if lineNum == line + 1 then
                    if isOnLastColumn then
                        []

                    else
                        [ content ]

                else
                    [ content ]

            newLines : Array String
            newLines =
                lines
                    |> Array.toIndexedList
                    |> List.concatMap removeCharFromLine
                    |> Array.fromList
        in
        { model
            | lines = newLines
            , cursor = cursor
        }


moveUp : Position -> Array String -> Position
moveUp { line, column } lines =
    if isFirstLine line then
        startOfDocument

    else
        let
            line_ : Int
            line_ =
                previousLine line
        in
        { line = line_
        , column = clampColumn lines line_ column
        }


moveDown : Position -> Array String -> Position
moveDown { line, column } lines =
    if isLastLine lines line then
        endOfDocument lines

    else
        let
            line_ : Int
            line_ =
                nextLine lines line
        in
        { line = line_
        , column = clampColumn lines line_ column
        }


moveLeft : Position -> Array String -> Position
moveLeft ({ line, column } as position) lines =
    if isStartOfDocument position then
        position

    else if isFirstColumn column then
        let
            line_ : Int
            line_ =
                previousLine line
        in
        { line = line_
        , column = lastColumn lines line_
        }

    else
        { line = line
        , column = column - 1
        }


moveRight : Position -> Array String -> Position
moveRight ({ line, column } as position) lines =
    if isEndOfDocument lines position then
        position

    else if isLastColumn lines line column then
        { line = nextLine lines line
        , column = 0
        }

    else
        { line = line
        , column = column + 1
        }


startOfDocument : Position
startOfDocument =
    { line = 0
    , column = 0
    }


endOfDocument : Array String -> Position
endOfDocument lines =
    { line = lastLine lines
    , column = lastColumn lines (lastLine lines)
    }


isStartOfDocument : Position -> Bool
isStartOfDocument { line, column } =
    isFirstLine line
        && isFirstColumn column


isEndOfDocument : Array String -> Position -> Bool
isEndOfDocument lines { line, column } =
    isLastLine lines line
        && isLastColumn lines line column


isFirstLine : Int -> Bool
isFirstLine line =
    line == 0


isLastLine : Array String -> Int -> Bool
isLastLine lines line =
    line == lastLine lines


isFirstColumn : Int -> Bool
isFirstColumn column =
    column == 0


isLastColumn : Array String -> Int -> Int -> Bool
isLastColumn lines line column =
    column == lastColumn lines line


lastLine : Array String -> Int
lastLine lines =
    Array.length lines - 1


previousLine : Int -> Int
previousLine line =
    (line - 1)
        |> max 0


nextLine : Array String -> Int -> Int
nextLine lines line =
    (line + 1)
        |> min (maxLine lines)


maxLine : Array String -> Int
maxLine lines =
    Array.length lines - 1


lastColumn : Array String -> Int -> Int
lastColumn lines line =
    lineLength lines line


clampColumn : Array String -> Int -> Int -> Int
clampColumn lines line column =
    column
        |> clamp 0 (lineLength lines line)


lineContent : Array String -> Int -> String
lineContent lines lineNum =
    lines
        |> Array.get lineNum
        |> Maybe.withDefault ""


lineLength : Array String -> Int -> Int
lineLength lines lineNum =
    lineContent lines lineNum
        |> String.length


view : Model -> Html Msg
view model =
    H.div [ HA.style "margin" "50px" ]
        [ viewHeader model
        , viewEditor model
        , viewDebug model
        , viewFooter model
        ]


viewFooter : Model -> Html Msg
viewFooter model =
    H.div
        [ HA.style "display" "flex"
        , HA.style "flex-direction" "column"
        , HA.style "margin-top" "20px"
        ]
        [ H.p [ HA.style "margin-top" "0px" ]
            [ H.text "This demo is an Elm 0.19 version of"
            , H.a [ HA.href "https://janiczek.github.io/elm-editor/" ] [ H.text " Martin Janiczek's elm-editor" ]
            , H.span [] [ H.text ". See also his " ]
            , H.a [ HA.href "https://discourse.elm-lang.org/t/text-editor-done-in-pure-elm/1365/" ] [ H.text " Discourse article" ]
            , H.span [] [ H.text ". " ]
            ]
        , H.p [ HA.style "margin-top" "0px" ]
            [ H.a [ HA.href "https://github.com/jxxcarlson/elm-editor" ] [ H.text "Github repo" ]
            , H.span [] [ H.text " forked from " ]
            , H.a [ HA.href "https://janiczek.github.io/elm-editor/" ] [ H.text " Martin Janiczek. " ]
            ]
        ]


viewHeader : Model -> Html Msg
viewHeader model =
    H.div
        [ HA.style "display" "flex"
        , HA.style "font-family" "monospace"
        , HA.style "margin-bottom" "20px"
        ]
        [ H.span [ HA.style "font-size" "24px" ] [ H.text "Text editor" ]
        , lineNumbersDisplay model
        , wordCountDisplay model
        , rowButton 40 "Clear" Clear [ HA.style "margin-left" "24px", HA.style "margin-top" "4px" ]
        , rowButton 100 "Add test lines: " TestLines [ HA.style "margin-left" "24px", HA.style "margin-top" "4px" ]
        , textField 40 "n" InputNumberOfLines [ HA.style "margin-left" "4px", HA.style "margin-top" "4px" ] [ HA.style "font-size" "14px" ]
        ]


lineNumbersDisplay : Model -> Html Msg
lineNumbersDisplay model =
    H.span
        displayStyle
        [ H.text <| "Lines: " ++ String.fromInt (Array.length model.lines) ]


wordCountDisplay : Model -> Html Msg
wordCountDisplay model =
    let
        words =
            model.lines
                |> Array.map (String.words >> List.length)
                |> Array.toList
                |> List.sum
    in
    H.span
        displayStyle
        [ H.text <| "Words: " ++ String.fromInt words ]


displayStyle =
    [ HA.style "margin-left" "24px"
    , HA.style "font-size" "16px"
    , HA.style "margin-top" "8px"
    ]


viewDebug : Model -> Html Msg
viewDebug { lines, cursor, hover, selection } =
    H.div
        [ HA.style "max-width" "100%" ]
        [ --H.pre
          --   [ HA.style  "white-space"  "pre-wrap"  ]
          --   [ H.text <| "Lines: \n" ++ (lines |> Array.toList |> String.join "\n") ]
          H.pre [] [ H.text <| "cursor: " ++ stringFromPosition cursor ]
        , H.pre [] [ H.text <| "hover: " ++ stringFromHover hover ]
        , H.pre [] [ H.text (stringFromSelection selection) ]
        , H.pre [] [ H.text <| "selected text:\n" ++ selectedText selection hover lines ]
        ]


selectedText : Selection -> Hover -> Array String -> String
selectedText selection currentHover lines =
    let
        positionsToString : Position -> Position -> String
        positionsToString from to =
            let
                numberOfLines =
                    to.line - from.line + 1
            in
            lines
                |> Array.toList
                |> List.drop from.line
                |> List.take numberOfLines
                |> List.indexedMap
                    (\i line ->
                        if numberOfLines == 1 then
                            line
                                |> String.dropLeft from.column
                                |> String.left (to.column - from.column + 1)

                        else if i == 0 then
                            String.dropLeft from.column line

                        else if i == numberOfLines - 1 then
                            String.left (to.column + 1) line

                        else
                            line
                    )
                |> String.join "\n"
    in
    case selection of
        NoSelection ->
            ""

        SelectingFrom startHover ->
            hoversToPositions lines startHover currentHover
                |> Maybe.map (\( from, to ) -> positionsToString from to)
                |> Maybe.withDefault ""

        SelectedChar { line, column } ->
            lineContent lines line
                |> String.dropLeft column
                |> String.left 1

        Selection from to ->
            positionsToString from to


viewEditor : Model -> Html Msg
viewEditor model =
    H.div
        [ HA.style "display" "flex"
        , HA.style "flex-direction" "row"
        , HA.style "font-family" "monospace"
        , HA.style "font-size" (px fontSize)
        , HA.style "line-height" (px lineHeight)
        , HA.style "white-space" "pre"
        , HA.style "height" "200px"
        , HA.style "overflow-y" "scroll"
        , handleKey
        , HA.tabindex 0
        , HA.id "editor"
        ]
        [ viewLineNumbers model
        , viewContent model
        ]


handleKey : Attribute Msg
handleKey =
    HE.custom "keydown" (JD.map transformMsg keyDecoder)


transformMsg : a -> { message : a, stopPropagation : Bool, preventDefault : Bool }
transformMsg msg =
    { message = msg, stopPropagation = True, preventDefault = True }


alwaysMsg : msg -> ( msg, Bool )
alwaysMsg msg =
    ( msg, True )


yada =
    HE.custom "keydown"


onHover2 : Position -> Attribute Msg
onHover2 position =
    HE.custom "mouseover" <|
        JD.succeed
            { message = Hover (HoverChar position)
            , stopPropagation = True
            , preventDefault = True
            }


viewLineNumbers : Model -> Html Msg
viewLineNumbers model =
    H.div
        [ HA.style "width" "2.5em"
        , HA.style "text-align" "left"
        , HA.style "color" "#444"
        , HA.style "display" "flex"
        , HA.style "flex-direction" "column"
        ]
        (List.range 1 (Array.length model.lines)
            |> List.map viewLineNumber
        )


viewLineNumber : Int -> Html Msg
viewLineNumber n =
    H.span [ HA.style "background-color" "#bbc", HA.style "padding-left" "6px" ] [ H.text (String.fromInt n) ]


viewContent : Model -> Html Msg
viewContent model =
    H.div
        [ HA.style "position" "relative"
        , HA.style "flex" "1"
        , HA.style "background-color" "#f0f0f0"
        , HA.style "user-select" "none"
        , HA.style "user-select" "none"
        , HE.onMouseDown StartSelecting
        , HE.onMouseUp StopSelecting
        , HE.onClick GoToHoveredPosition
        , HE.onMouseOut (Hover NoHover)
        ]
        [ viewLines model.cursor model.hover model.selection model.lines ]


viewLines : Position -> Hover -> Selection -> Array String -> Html Msg
viewLines position hover selection lines =
    H.div []
        (lines
            |> Array.indexedMap (viewLine position hover selection lines)
            |> Array.toList
        )


viewLine : Position -> Hover -> Selection -> Array String -> Int -> String -> Html Msg
viewLine position hover selection lines line content =
    Html.Lazy.lazy6 viewLine_ position hover selection lines line content


viewLine_ : Position -> Hover -> Selection -> Array String -> Int -> String -> Html Msg
viewLine_ position hover selection lines line content =
    H.div
        [ HA.style "position" "absolute"
        , HA.style "position" "absolute"
        , HA.style "position" "absolute"
        , HA.style "left" "0"
        , HA.style "right" "0"
        , HA.style "padding-left" "4px"
        , HA.style "height" (px lineHeight)
        , HA.style "top" (px (toFloat line * lineHeight))
        , HE.onMouseOver (Hover (HoverLine line))
        ]
        (if position.line == line && isLastColumn lines line position.column then
            viewChars position hover selection lines line content
                ++ [ viewCursor position nbsp ]

         else
            viewChars position hover selection lines line content
        )


viewChars : Position -> Hover -> Selection -> Array String -> Int -> String -> List (Html Msg)
viewChars position hover selection lines line content =
    content
        |> String.toList
        |> List.indexedMap (viewChar position hover selection lines line)


viewChar : Position -> Hover -> Selection -> Array String -> Int -> Int -> Char -> Html Msg
viewChar position hover selection lines line column char =
    if position.line == line && position.column == column then
        viewCursor
            position
            (String.fromChar char)

    else if selection /= NoSelection && isSelected lines selection hover line column then
        viewSelectedChar
            { line = line, column = column }
            (String.fromChar char)

    else
        H.span
            [ onHover { line = line, column = column } ]
            [ H.text (String.fromChar char) ]


isSelected : Array String -> Selection -> Hover -> Int -> Int -> Bool
isSelected lines selection currentHover line column =
    let
        isSelectedPositions : Position -> Position -> Bool
        isSelectedPositions from to =
            (from.line <= line)
                && (to.line >= line)
                && (if from.line == line then
                        from.column <= column

                    else
                        True
                   )
                && (if to.line == line then
                        to.column >= column

                    else
                        True
                   )
    in
    case selection of
        NoSelection ->
            False

        SelectingFrom startHover ->
            hoversToPositions lines startHover currentHover
                |> Maybe.map (\( from, to ) -> isSelectedPositions from to)
                |> Maybe.withDefault False

        SelectedChar position ->
            position == { line = line, column = column }

        Selection from to ->
            isSelectedPositions from to


nbsp : String
nbsp =
    "\u{00A0}"


ensureNonBreakingSpace : Char -> Char
ensureNonBreakingSpace char =
    case char of
        ' ' ->
            nonBreakingSpace

        _ ->
            char


{-| The non-breaking space character will not get whitespace-collapsed like a
regular space.
-}
nonBreakingSpace : Char
nonBreakingSpace =
    Char.fromCode 160


viewCursor : Position -> String -> Html Msg
viewCursor position char =
    H.span
        [ HA.style "background-color" "orange"
        , onHover position
        ]
        [ H.text char ]


viewSelectedChar : Position -> String -> Html Msg
viewSelectedChar position char =
    H.span
        [ HA.style "background-color" "#ccc"
        , onHover position
        ]
        [ H.text char ]


onHover : Position -> Attribute Msg
onHover position =
    HE.custom "mouseover" <|
        JD.succeed
            { message = Hover (HoverChar position)
            , stopPropagation = True
            , preventDefault = True
            }


fontSize : Float
fontSize =
    20


px : Float -> String
px f =
    String.fromFloat f ++ "px"


lineHeight : Float
lineHeight =
    fontSize * 1.2


rowButton width str msg attr =
    H.div (rowButtonStyle ++ attr)
        [ H.button ([ HE.onClick msg ] ++ rowButtonLabelStyle width) [ H.text str ] ]


textField width str msg attr innerAttr =
    H.div ([ HA.style "margin-bottom" "10px" ] ++ attr)
        [ H.input
            ([ HA.style "height" "18px"
             , HA.style "width" (String.fromInt width ++ "px")
             , HA.type_ "text"
             , HA.placeholder str
             , HA.style "margin-right" "8px"
             , HE.onInput msg
             ]
                ++ innerAttr
            )
            []
        ]


rowButtonStyle =
    [ HA.style "font-size" "12px"
    , HA.style "border" "none"
    ]


rowButtonLabelStyle width =
    [ HA.style "font-size" "12px"
    , HA.style "background-color" "#666"
    , HA.style "color" "#eee"
    , HA.style "width" (String.fromInt width ++ "px")
    , HA.style "height" "24px"
    , HA.style "border" "none"
    ]



-- TEST


testLines n =
    Array.fromList (List.repeat n "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")


loremIpsum =
    """


Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce feugiat non eros
eu vehicula. Nullam non metus congue, mattis nisi tempus, volutpat diam. Proin
rutrum arcu ut dolor egestas commodo. Nunc lacinia nec magna id rutrum. In id
orci eu arcu ultrices vulputate nec eget leo. Nunc porttitor enim augue, id
iaculis magna blandit at. Donec eu sem non libero vestibulum volutpat a sed
magna.

Etiam sit amet odio et odio placerat finibus sit amet non mauris. Integer quis
lacus ut massa sodales maximus imperdiet vel ex. Etiam efficitur ipsum id
lacinia aliquet. Pellentesque habitant morbi tristique senectus et netus et
malesuada fames ac turpis egestas. Suspendisse potenti. Vivamus blandit mollis
luctus. Sed nisl risus, lobortis ut leo id, vestibulum interdum est. Phasellus
posuere lorem nulla, et congue augue pharetra in.

Curabitur faucibus nisi metus, sit amet lacinia augue pharetra id. Nullam
rhoncus lacus ut varius vestibulum. Nam non porttitor enim, id porttitor urna.
Fusce id pellentesque erat. Pellentesque feugiat auctor erat, ut eleifend risus
porta ac. Pellentesque nec tempus nulla. Vivamus lobortis dui vitae rutrum
bibendum.

Praesent semper enim arcu, vitae dictum tortor fermentum ac. Proin varius
viverra massa, vel cursus justo malesuada eu. Maecenas volutpat at ligula vel
lobortis. Aenean justo ligula, congue ac consectetur eget, tincidunt feugiat
urna. Vivamus semper tortor quis odio viverra tempor. Aliquam sit amet dui quis
lectus viverra tincidunt in at enim. Nullam volutpat sem sit amet auctor rutrum.
Duis dictum turpis non risus vulputate, quis iaculis ligula vulputate.
Vestibulum ut accumsan nibh. Donec ullamcorper vitae nulla non semper. Proin
quis risus nisi.

Morbi bibendum lacus luctus diam ornare gravida. Aenean tortor augue, ultrices
ornare pretium non, tempus ut augue. Nulla a urna nec elit lacinia fringilla.
Etiam fermentum aliquam sollicitudin. Nam suscipit turpis a vestibulum egestas.
Aenean elementum mollis quam, sit amet laoreet tortor. Nunc eros justo, euismod
vitae nisl quis, molestie tempor est. Donec dapibus condimentum massa, sed
imperdiet libero commodo in. Vivamus bibendum egestas massa, quis interdum mi.
Nunc feugiat volutpat lorem. Duis lacinia sapien non cursus varius. Sed lectus
purus, viverra et enim eu, sagittis suscipit sapien. Sed risus nisi, dictum eu
elit in, dignissim lobortis lacus. Aliquam sed malesuada felis.

Cras nulla dolor, iaculis id ornare at, egestas nec ipsum. Pellentesque in
dignissim tellus. Curabitur id gravida lacus. Praesent vitae quam facilisis mi
commodo posuere eu sit amet turpis. Phasellus pretium, diam sit amet hendrerit
viverra, tellus sem bibendum massa, luctus pretium turpis augue et lacus. Nulla
pharetra mi nunc, non vestibulum ex tristique a. Proin dui elit, luctus sed
luctus id, finibus et est. Donec finibus hendrerit feugiat. Quisque vulputate
turpis arcu, eu consequat enim congue sit amet. Nulla at leo justo. Proin
sollicitudin augue ante, id interdum lacus tempor et. Aliquam auctor ligula nec
dui tincidunt luctus. In eu dui vel odio pellentesque blandit. Nam vestibulum
faucibus consectetur. Donec fringilla erat sapien, sed fringilla ipsum ultricies
eget. Proin dapibus leo sit amet cursus venenatis. Pellentesque gravida ante non
risus faucibus, sed tincidunt diam vulputate. Integer non.
"""
