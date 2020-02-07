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
            [ [ ( ContextMenu.item "Undo" |> ContextMenu.shortcut "Ctrl-Z", Item 1 )
              , ( ContextMenu.item "Redo" |> ContextMenu.shortcut "Ctrl-Y", Item 2 )
              ]
            , [ ( ContextMenu.item "Clear" |> ContextMenu.shortcut "Ctrl-Opt-C", Item 9 )
              ]
            , [ ( ContextMenu.item "Move up" |> ContextMenu.shortcut "ArrowUp", Item 3 )
              , ( ContextMenu.item "Move down" |> ContextMenu.shortcut "ArrowDown", Item 4 )
              , ( ContextMenu.item "Move left" |> ContextMenu.shortcut "ArrowLeft", Item 5 )
              , ( ContextMenu.item "Move Right" |> ContextMenu.shortcut "ArrowRight", Item 6 )
              ]
            , [ ( ContextMenu.item "Page up" |> ContextMenu.shortcut "Opt-ArrowUp", Item 7 )
              , ( ContextMenu.item "Page down" |> ContextMenu.shortcut "Opt-ArrowDown", Item 8 )
              , ( ContextMenu.item "Line start" |> ContextMenu.shortcut "Opt-ArrowLeft", Item 9 )
              , ( ContextMenu.item "Line endt" |> ContextMenu.shortcut "Opt-ArrowRight", Item 10 )
              ]
            , [ ( ContextMenu.item "Firt line" |> ContextMenu.shortcut "Ctrl-Opt-ArrowUp", Item 7 )
              , ( ContextMenu.item "Last line" |> ContextMenu.shortcut "Ctrl-Opt-ArrowDown", Item 8 )
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
