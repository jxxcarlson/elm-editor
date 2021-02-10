module View.Search exposing (replacePanel, searchPanel)

import EditorModel exposing (AutoLineBreak(..), EditorModel)
import EditorMsg exposing (Context(..), EMsg(..), Hover(..), Selection(..))
import EditorStyle
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import RollingList
import Widget


searchPanel : EditorModel -> Html EMsg
searchPanel model =
    showIf model.showSearchPanel (searchPanel_ model)


searchPanel_ : EditorModel -> Html EMsg
searchPanel_ model =
    H.div
        [ HA.style "width" (px model.width)
        , HA.style "padding-top" "5px"
        , HA.style "padding-left" "25px"
        , HA.style "display" "flex"
        , HA.style "flex-direction" "row"
        , HA.style "justify-content" "left"
        , HA.style "align-items" "baseline"
        , HA.style "height" "30px"
        , HA.style "background-color" EditorStyle.mediumGray
        , HA.style "opacity" "0.9"
        , HA.style "font-size" "14px"
        , HA.style "width" (px (model.width - 25))
        ]
        [ -- searchTextButton
          acceptSearchText
        , numberOfHitsDisplay model
        , searchForwardButton
        , searchBackwardButton
        ]


replacePanel : EditorModel -> Html EMsg
replacePanel model =
    showIf (model.canReplace && model.showSearchPanel) (replacePanel_ model)


replacePanel_ : EditorModel -> Html EMsg
replacePanel_ model =
    H.div
        [ HA.style "width" (px model.width)
        , HA.style "padding-top" "5px"
        , HA.style "padding-left" "15px"
        , HA.style "display" "flex"
        , HA.style "flex-direction" "row"
        , HA.style "justify-content" "flex-start"
        , HA.style "align-items" "baseline"
        , HA.style "height" "30px"
        , HA.style "background-color" EditorStyle.mediumGray

        --, HA.style "border-width" "1px"
        --, HA.style "border-style" "solid"
        , HA.style "opacity" "0.9"
        , HA.style "font-size" "14px"
        , HA.style "width" (px (model.width - 15))
        ]
        [ replaceTextButton
        , acceptReplaceText

        -- , dismissReplacePanel
        ]


numberOfHitsDisplay : EditorModel -> Html EMsg
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


searchForwardButton : Html EMsg
searchForwardButton =
    Widget.rowButton 30
        RollSearchSelectionForward
        ">"
        [ HA.style "float" "left"
        , HA.title "Next search hit"
        ]


searchBackwardButton : Html EMsg
searchBackwardButton =
    Widget.rowButton 30
        RollSearchSelectionBackward
        "<"
        [ HA.style "float" "left"
        , HA.title "Previous search hit"
        ]


replaceTextButton : Html EMsg
replaceTextButton =
    Widget.rowButton 70
        ReplaceCurrentSelection
        "Replace"
        [ HA.style "margin-left" "10px"
        , HA.title "Replace current search hit"
        ]


acceptSearchText : Html EMsg
acceptSearchText =
    Widget.textField 220
        AcceptSearchText
        ""
        [ HA.style "float" "left"
        ]
        [ setHtmlId "editor-search-box" ]


acceptReplaceText : Html EMsg
acceptReplaceText =
    Widget.textField 267 AcceptReplacementText "" [ HA.style "float" "left" ] [ setHtmlId "replacement-box" ]


setHtmlId : String -> Attribute msg
setHtmlId id =
    HA.attribute "id" id


showIf : Bool -> Html EMsg -> Html EMsg
showIf flag el =
    if flag then
        el

    else
        H.div [] []


px : Float -> String
px f =
    String.fromFloat f ++ "px"
