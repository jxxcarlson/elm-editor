module View.Search exposing (replacePanel, searchPanel)

import EditorModel exposing (AutoLineBreak(..), Config, Context(..), EditorModel, Hover(..), Msg(..), Position, Selection(..))
import EditorStyle
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import RollingList
import Widget


searchPanel model =
    showIf model.showSearchPanel (searchPanel_ model)


searchPanel_ model =
    H.div
        [ HA.style "width" (px model.width)
        , HA.style "padding-top" "5px"
        , HA.style "display" "flex"
        , HA.style "flex-direction" "row"
        , HA.style "justify-content" "space-evenly"
        , HA.style "align-items" "baseline"
        , HA.style "height" "30px"

        -- , HA.style "padding-left" "8px"
        , HA.style "background-color" EditorStyle.lightGray
        , HA.style "opacity" "0.9"
        , HA.style "font-size" "14px"
        ]
        [ searchTextButton
        , acceptSearchText
        , numberOfHitsDisplay model
        , searchForwardButton
        , searchBackwardButton
        , dismissSearchPanel
        , openReplaceField
        ]


replacePanel model =
    showIf (model.canReplace && model.showSearchPanel) (replacePanel_ model)


replacePanel_ model =
    H.div
        [ HA.style "width" (px model.width)
        , HA.style "padding-top" "5px"
        , HA.style "display" "flex"
        , HA.style "flex-direction" "row"
        , HA.style "justify-content" "flex-start"
        , HA.style "align-items" "baseline"
        , HA.style "height" "30px"
        , HA.style "background-color" EditorStyle.mediumGray
        , HA.style "opacity" "0.9"
        , HA.style "font-size" "14px"
        ]
        [ replaceTextButton
        , acceptReplaceText
        , dismissReplacePanel
        ]


dismissSearchPanel =
    Widget.lightRowButton 25
        ToggleSearchPanel
        "X"
        [ HA.style "float" "left", HA.style "float" "left" ]


dismissReplacePanel =
    Widget.lightRowButton 25
        ToggleReplacePanel
        "X"
        [ HA.style "float" "left", HA.style "float" "left" ]


openReplaceField =
    Widget.rowButton 25
        OpenReplaceField
        "R"
        []


numberOfHitsDisplay : EditorModel -> Html Msg
numberOfHitsDisplay model =
    let
        n =
            model.searchResults
                |> RollingList.toList
                |> List.length

        txt =
            String.fromInt (model.searchResultIndex + 1) ++ "/" ++ String.fromInt n
    in
    Widget.rowButton 40 EditorNoOp txt [ HA.style "float" "left" ]


searchForwardButton =
    Widget.rowButton 30 RollSearchSelectionForward ">" [ HA.style "float" "left" ]


searchBackwardButton =
    Widget.rowButton 30 RollSearchSelectionBackward "<" [ HA.style "float" "left" ]


searchTextButton =
    Widget.rowButton 60 EditorNoOp "Search" [ HA.style "float" "left" ]


replaceTextButton =
    Widget.rowButton 70 ReplaceCurrentSelection "Replace" [ HA.style "margin-left" "10px" ]


acceptLineNumber =
    Widget.textField 30
        AcceptLineNumber
        ""
        [ HA.style "margin-top" "5px", HA.style "float" "left" ]
        [ setHtmlId "line-number-input" ]


acceptSearchText =
    Widget.textField 130
        AcceptSearchText
        ""
        [ HA.style "float" "left"
        ]
        [ setHtmlId "editor-search-box" ]


acceptReplaceText =
    Widget.textField 130 AcceptReplacementText "" [ HA.style "float" "left" ] [ setHtmlId "replacement-box" ]


setHtmlId : String -> Attribute msg
setHtmlId id =
    HA.attribute "id" id


showIf : Bool -> Html Msg -> Html Msg
showIf flag el =
    case flag of
        True ->
            el

        False ->
            H.div [] []


px : Float -> String
px f =
    String.fromFloat f ++ "px"
