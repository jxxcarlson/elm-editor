module View exposing (alwaysMsg, displayStyle, handleKey, isSelected, lineNumbersDisplay, nbsp, onHover2, selectedText, transformMsg, viewChar, viewChars, viewContent, viewDebug, viewEditor, viewLine, viewLineNumber, viewLineNumbers, viewLine_, viewLines, wordCountDisplay, yada)

import Array exposing (Array)
import Common exposing (..)
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Html.Events as HE
import Html.Lazy
import Json.Decode as JD exposing (Decoder)
import Model exposing (Hover(..), Model, Position, Selection(..))
import Update exposing (Msg(..))


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


stringFromHover : Hover -> String
stringFromHover hover =
    case hover of
        NoHover ->
            "NoHover"

        HoverLine k ->
            "HoverLine: " ++ String.fromInt k

        HoverChar p ->
            "HoverChar: " ++ stringFromPosition p


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


stringFromPosition : Position -> String
stringFromPosition p =
    "(" ++ String.fromInt p.line ++ ", " ++ String.fromInt p.column ++ ")"


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


nbsp : String
nbsp =
    "\u{00A0}"