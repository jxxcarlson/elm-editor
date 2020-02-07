module Menu.View exposing (toItemGroups, viewContextMenu)

import ContextMenu exposing (ContextMenu)
import Html as H exposing (Attribute, Html)
import Menu.Config
import Menu.Style
import Model exposing (Config, Context(..), Hover(..), Model, Msg(..), Position, Selection(..))


viewContextMenu : Model -> Html Msg
viewContextMenu model =
    H.div
        []
        [ H.div
            (ContextMenu.open ContextMenuMsg Background :: Menu.Style.backgroundStyles)
            [ H.div
                (ContextMenu.open ContextMenuMsg Object :: Menu.Style.objectStyles)
                []
            ]
        , H.div [] []
        , ContextMenu.view
            Menu.Config.winChrome
            ContextMenuMsg
            toItemGroups
            model.contextMenu
        ]



-- MENU --


toItemGroups : Context -> List (List ( ContextMenu.Item, Msg ))
toItemGroups context =
    case context of
        Object ->
            [ [ ( ContextMenu.item "Undo" |> ContextMenu.shortcut "Ctrl-Z", Undo )
              , ( ContextMenu.item "Redo" |> ContextMenu.shortcut "Ctrl-Y", Redo )
              ]
            , [ ( ContextMenu.item "Clear" |> ContextMenu.shortcut "Ctrl-Opt-C", Clear )
              ]
            , [ ( ContextMenu.item "Move up" |> ContextMenu.shortcut "ArrowUp", MoveUp )
              , ( ContextMenu.item "Move down" |> ContextMenu.shortcut "ArrowDown", MoveDown )
              , ( ContextMenu.item "Move left" |> ContextMenu.shortcut "ArrowLeft", MoveLeft )
              , ( ContextMenu.item "Move Right" |> ContextMenu.shortcut "ArrowRight", MoveRight )
              ]
            , [ ( ContextMenu.item "Page up" |> ContextMenu.shortcut "Opt-ArrowUp", PageUp )
              , ( ContextMenu.item "Page down" |> ContextMenu.shortcut "Opt-ArrowDown", PageDown )
              , ( ContextMenu.item "Line start" |> ContextMenu.shortcut "Opt-ArrowLeft", MoveToLineStart )
              , ( ContextMenu.item "Line end" |> ContextMenu.shortcut "Opt-ArrowRight", MoveToLineEnd )
              ]
            , [ ( ContextMenu.item "First line" |> ContextMenu.shortcut "Ctrl-Opt-ArrowUp", FirstLine )
              , ( ContextMenu.item "Last line" |> ContextMenu.shortcut "Ctrl-Opt-ArrowDown", LastLine )
              ]
            ]

        Background ->
            [ [ ( ContextMenu.item "Pen", Item 8 )
              , ( ContextMenu.item "Pineapple", Item 9 )
              , ( ContextMenu.item "Apple", Item 10 )
              , ( ContextMenu.itemWithAnnotation "Item with annotation" "Some annotation here"
                    -- |> ContextMenu.icon Material.tag_faces Color.red
                    |> ContextMenu.disabled False
                , Item 7
                )
              ]
            ]



--[ ( "ArrowUp", FirstLine )
--           , ( "ArrowDown", LastLine )
--
--           --, ( "ArrowRight", CursorToGroupEnd )
--           --, ( "ArrowLeft", CursorToGroupStart )
--           --, ( "∑", ToggleWrapping )
--           , ( "ç", Clear )
--           ]
