module View.Editor exposing (view, viewDebug, viewHeader)

import Array exposing (Array)
import Common exposing (hoversToPositions, isLastColumn, lineContent)
import EditorModel exposing (AutoLineBreak(..), EditMode(..), EditorModel, ViewMode(..), VimMode(..))
import EditorMsg exposing (Context(..), EMsg(..), Hover(..), Position, Selection(..))
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Html.Events as HE
import Html.Lazy
import Json.Decode as JD
import Keymap
import OuterConfig
import String exposing (String)
import View.Helper
import Widget
import Window


statisticsDisplay : EditorModel -> Html EMsg
statisticsDisplay model =
    let
        w =
            model.lines
                |> Array.map (String.words >> List.length)
                |> Array.toList
                |> List.sum
                |> String.fromInt

        l =
            String.fromInt (Array.length model.lines)
    in
    H.span
        displayStyle
        [ H.text <| "(" ++ l ++ ", " ++ w ++ ")" ]


statisticsDisplay2 : EditorModel -> Html EMsg
statisticsDisplay2 model =
    H.span
        displayStyle
        [ H.text <| "(" ++ String.fromInt model.window.offset ++ ", " ++ String.fromInt model.cursor.line ++ ", " ++ String.fromInt model.cursor.column ++ ")" ]


displayStyle : List (Attribute msg)
displayStyle =
    [ HA.style "margin-left" "12px"
    , HA.style "font-size" "16px"
    , HA.style "margin-top" "8px"
    ]


viewDebug : EditorModel -> Html EMsg
viewDebug model =
    if model.debugOn then
        H.div
            [ HA.style "max-width" (px model.width), HA.style "padding" "8px" ]
            [ H.pre [] [ H.text <| "cursor: " ++ stringFromPosition model.cursor ]
            , H.pre [] [ H.text <| "hover: " ++ stringFromHover model.hover ]
            , H.pre [] [ H.text (stringFromSelection model.selection) ]
            , H.pre [] [ H.text <| "selected text:\n" ++ selectedText_ model.selection model.hover model.lines ]
            ]

    else
        H.div [] []


selectedText_ : Selection -> Hover -> Array String -> String
selectedText_ selection currentHover lines =
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


editorBackgroundColor : ViewMode -> Attribute msg
editorBackgroundColor viewMode_ =
    case viewMode_ of
        Light ->
            HA.style "background-color" "#f0f0f0"

        Dark ->
            HA.style "background-color" "#444444"


editorFontColor : ViewMode -> Attribute msg
editorFontColor viewMode_ =
    case viewMode_ of
        Light ->
            HA.style "color" "#444"

        Dark ->
            HA.style "color" "#f0f0f0"


borderBackgroundColor : ViewMode -> Attribute msg
borderBackgroundColor viewMode_ =
    --case viewMode_ of
    --    Light ->
    --        HA.style "background-color" "#bbb"
    --
    --    Dark ->
    HA.style "background-color" "#252525"


borderFontColor : ViewMode -> Attribute msg
borderFontColor viewMode_ =
    --case viewMode_ of
    --    Light ->
    --        HA.style "color" "#444          "
    --
    --    Dark ->
    HA.style "color" "#aaa"


view : EditorModel -> Html EMsg
view model =
    H.div
        [ HA.style "display" "flex"
        , HA.style "flex-direction" "row"
        , HA.style "font-family" "monospace"
        , HA.style "font-size" (px model.fontSize)
        , HA.style "line-height" (px model.lineHeight)
        , HA.style "white-space" "wrap"
        , HA.style "height" (px (editorHeight model))
        , HA.style "overflow" "scroll"
        , HA.style "width" (px model.width)
        , HA.style "background-color" "#555"
        , Keymap.handle
        , HA.tabindex 0

        -- , onDoubleClick SelectGroup
        --, onTripleClick SelectLine
        -- The line below dispatches code to handle double and triple clicks
        , onMultiplelick SelectGroup SelectLine
        , HA.id "__editor__"
        ]
        [ View.Helper.showIf model.viewLineNumbersOn (viewLineNumbers model)
        , viewContent model
        ]


editorHeight : EditorModel -> Float
editorHeight model =
    let
        defaultHeight =
            model.height - 16

        barHeight =
            35
    in
    case ( model.showSearchPanel, model.canReplace ) of
        ( False, False ) ->
            defaultHeight

        ( True, False ) ->
            defaultHeight - barHeight

        ( True, True ) ->
            defaultHeight - (2 * barHeight)

        ( False, True ) ->
            defaultHeight


onMultiplelick : msg -> msg -> Attribute msg
onMultiplelick msg1 msg2 =
    HE.on
        "click"
        (JD.field "detail" JD.int
            |> JD.andThen
                (\detail ->
                    if detail == 2 then
                        JD.succeed msg1

                    else if detail >= 3 then
                        JD.succeed msg2

                    else
                        JD.fail ""
                )
        )


viewLineNumbers : EditorModel -> Html EMsg
viewLineNumbers model =
    let
        offset =
            if model.cursor.line <= 2 * model.window.height - 2 then
                model.cursor.line

            else
                model.cursor.line - 2 * model.window.height

        lineHeightString =
            String.fromFloat (model.lineHeight + 0.7) ++ "px"
    in
    H.div
        [ HA.style "width" "3.5em"
        , HA.style "text-align" "left"
        , HA.style "display" "flex"
        , HA.style "flex-direction" "column"
        , HA.style "line-height" lineHeightString
        , borderBackgroundColor model.viewMode
        , borderFontColor model.viewMode
        ]
        (List.range 1 (4 * model.window.height)
            |> List.map (viewLineNumber model.viewMode offset)
        )


viewLineNumber : ViewMode -> Int -> Int -> Html EMsg
viewLineNumber viewMode_ offset n =
    H.span [ HA.style "padding-left" "6px", borderBackgroundColor viewMode_, borderFontColor viewMode_ ] [ H.text (String.fromInt (n + offset)) ]


viewContent : EditorModel -> Html EMsg
viewContent model =
    -- TODO: handle option mouseclick for LR sync
    let
        cursor =
            model.cursor

        selection =
            model.selection

        offset =
            model.window.offset

        windowLines =
            Window.lines model.window model.lines

        cursor2 =
            Window.shiftPosition -offset cursor

        selection2 =
            Window.shiftSelection -offset selection

        hover2 =
            Window.shiftHover -offset model.hover
    in
    H.div
        [ HA.style "position" "relative"
        , HA.style "flex" "1"
        , HA.style "user-select" "none"
        , HA.style "user-select" "none"
        , editorBackgroundColor model.viewMode
        , HE.onMouseDown StartSelecting
        , HE.onMouseUp StopSelecting
        , HE.onClick GoToHoveredPosition
        , HE.onMouseOut (Hover NoHover)
        ]
        [ viewLines model.viewMode model.lineHeight cursor2 hover2 selection2 windowLines ]


viewLines : ViewMode -> Float -> Position -> Hover -> Selection -> Array String -> Html EMsg
viewLines viewMode_ lineHeight position hover selection lines =
    H.div
        []
        (lines
            |> Array.indexedMap (viewLine viewMode_ lineHeight position hover selection lines)
            |> Array.toList
        )


viewLine : ViewMode -> Float -> Position -> Hover -> Selection -> Array String -> Int -> String -> Html EMsg
viewLine viewMode_ lineHeight position hover selection lines line content =
    Html.Lazy.lazy8 viewLine_ viewMode_ lineHeight position hover selection lines line content


viewLine_ : ViewMode -> Float -> Position -> Hover -> Selection -> Array String -> Int -> String -> Html EMsg
viewLine_ viewMode_ lineHeight position hover selection lines line content =
    H.div
        [ HA.style "position" "absolute"
        , HA.style "left" "0"
        , HA.style "right" "0"
        , HA.style "padding-left" "14px" -- Left margin in editor set here
        , editorBackgroundColor viewMode_
        , editorFontColor viewMode_
        , HA.style "height" (px lineHeight)
        , HA.style "top" (px (toFloat line * lineHeight))
        , HE.onMouseOver (Hover (HoverLine line))
        ]
        (if position.line == line && isLastColumn lines line position.column then
            viewChars viewMode_ position hover selection lines line content
                ++ [ viewCursor position nbsp ]

         else
            viewChars viewMode_ position hover selection lines line content
        )


viewChars : ViewMode -> Position -> Hover -> Selection -> Array String -> Int -> String -> List (Html EMsg)
viewChars viewMode_ position hover selection lines line content =
    content
        |> String.toList
        |> List.indexedMap (viewChar viewMode_ position hover selection lines line)


viewChar : ViewMode -> Position -> Hover -> Selection -> Array String -> Int -> Int -> Char -> Html EMsg
viewChar viewMode_ position hover selection lines line column char =
    if position.line == line && position.column == column then
        viewCursor
            position
            (String.fromChar char)

    else if selection /= NoSelection && isSelected lines selection hover line column then
        viewSelectedChar viewMode_
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


stringFromSelection : Selection -> String
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


viewCursor : Position -> String -> Html EMsg
viewCursor position char =
    H.span
        [ HA.style "background-color" "orange"
        , onHover position
        ]
        [ H.text char ]


shift : Int -> Position -> Position
shift k pos =
    { pos | line = pos.line - k }


viewSelectedChar : ViewMode -> Position -> String -> Html EMsg
viewSelectedChar viewMode_ position char =
    H.span
        [ selectedColor viewMode_
        , onHover position
        ]
        [ H.text char ]


selectedColor : ViewMode -> Attribute msg
selectedColor viewMode_ =
    case viewMode_ of
        Light ->
            HA.style "background-color" highlightColorLight

        Dark ->
            HA.style "background-color" "#03a199"



--"#a10303"
-- "#0367a1"
-- "#03a199"
-- "#a10303"


highlightColorLight : String
highlightColorLight =
    "#d7d6ff"



-- TODO: background color


onHover : Position -> Attribute EMsg
onHover position =
    HE.custom "mouseover" <|
        JD.succeed
            { message = Hover (HoverChar position)
            , stopPropagation = True
            , preventDefault = True
            }


px : Float -> String
px f =
    String.fromFloat f ++ "px"


rowButton : Int -> String -> msg -> List (Attribute msg) -> Html msg
rowButton width str msg attr =
    H.div (rowButtonStyle ++ attr)
        [ H.button (HE.onClick msg :: rowButtonLabelStyle width) [ H.text str ] ]


textField : Int -> String -> (String -> msg) -> List (Attribute msg) -> List (Attribute msg) -> Html msg
textField width str msg attr innerAttr =
    H.div attr
        [ H.input
            ([ HA.style "height" "20px"
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


rowButtonStyle : List (Attribute msg)
rowButtonStyle =
    [ HA.style "font-size" "12px"
    , HA.style "border" "none"
    ]


rowButtonLabelStyle : Int -> List (Attribute msg)
rowButtonLabelStyle width =
    [ HA.style "font-size" "14px"
    , HA.style "background-color" "#222"
    , HA.style "color" "#eee"
    , HA.style "width" (String.fromInt width ++ "px")
    , HA.style "height" "26px"
    , HA.style "border" "none"
    ]


nbsp : String
nbsp =
    "\u{00A0}"



-- HEADER


viewHeader : EditorModel -> Html EMsg
viewHeader model =
    H.div
        [ HA.style "display" "flex"
        , HA.style "font-family" "monospace"
        , HA.style "background-color" "#c0c0c0"
        , HA.style "padding-top" "2px"
        , HA.style "padding-bottom" "6px"
        , HA.style "align-items" "baseline"
        , HA.style "width" (px model.width)
        , borderFontColor model.viewMode
        , borderBackgroundColor model.viewMode
        ]
        [ rowButton 60 "Help" ToggleHelp [ HA.style "margin-left" "12px", HA.style "margin-top" "4px" ]
        , if model.devModeOn then
            statisticsDisplay2 model

          else
            statisticsDisplay model
        , rowButton 32 "Search" ToggleSearchPanel [ HA.style "margin-left" "24px", HA.style "margin-top" "4px", HA.title "Toggle search panel" ]
        , View.Helper.showIf model.showSearchPanel toggleReplacePanel
        , rowButton 32 "Go" GoToLine [ HA.style "margin-left" "24px", HA.style "margin-top" "4px", HA.title "Go to line number" ]
        , textField 56 "" AcceptLineToGoTo [ HA.style "margin-left" "4px", HA.style "margin-top" "4px" ] [ textFieldFontColor model, textFieldBackgroundColor model, HA.style "font-size" "14px" ]
        , rowButton 60 (autoLinBreakTitle model) ToggleAutoLineBreak [ HA.style "margin-left" "24px", HA.style "margin-top" "4px", HA.title "Toggle auto line break/wrap" ]

        -- , editModeDisplay model
        -- , rowButton 60 "Open" RequestFile [ HA.style "margin-left" "24px", HA.style "margin-top" "4px" ]
        ]


toggleReplacePanel : Html EMsg
toggleReplacePanel =
    Widget.lightRowButton 25
        ToggleReplacePanel
        "R"
        [ HA.style "float" "left", HA.style "float" "left", HA.title "Toggle replace text panel" ]


editModeDisplay : EditorModel -> Html msg
editModeDisplay model =
    let
        message =
            case model.editMode of
                StandardEditor ->
                    "Standard"

                VimEditor VimNormal ->
                    "Vim"

                VimEditor VimInsert ->
                    "Vim - insert"
    in
    H.span [ HA.style "font-style" "bold", HA.style "font-size" "14px", HA.style "margin-left" "25px", HA.style "color" "#e44" ] [ H.text message ]


textFieldBackgroundColor : EditorModel -> Attribute msg
textFieldBackgroundColor model =
    HA.style "background-color" "#ccc"


textFieldFontColor : EditorModel -> Attribute msg
textFieldFontColor model =
    HA.style "color" "#222"


autoLinBreakTitle : EditorModel -> String
autoLinBreakTitle model =
    case model.autoLineBreak of
        AutoLineBreakON ->
            "brk ON"

        AutoLineBreakOFF ->
            "brk OFF"
