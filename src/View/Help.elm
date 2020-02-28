module View.Help exposing (data, view)

import Array exposing (Array)
import Common exposing (..)
import Html exposing (Attribute, Html)
import Html.Attributes as HA
import Html.Events as HE
import Html.Lazy
import Json.Decode as JD exposing (Decoder)
import Keymap
import Markdown.Option exposing (..)
import Markdown.Render exposing (MarkdownMsg(..))
import Model exposing (HelpState(..), Model)



--, "Open file" |> ContextMenu.shortcut "ctrl-O", RequestFile )
--"Save file" |> ContextMenu.shortcut "ctrl-opt-S", SaveFile )
--  ]


data =
    """
## Key Commands

Type `ctrl-H` to toggle this window.

### Search

````
Search                ctrl-S
Next search hit       ctrl-.   (Think >)
Previous search hit   ctrl-,   (Think <)
````
    
### Content

````
Undo       ctrl-Z
Redo       ctrl-Y

Copy       ctrl-C
Cut        ctrl-X
Paste      ctrl-V
Clear      ctrl-opt-C

Delete Forward   ctrl-D

Kill Line     ctrl-K   (from cursor to end)
Delete Line   ctrl-U
Paste         ctrl-V

For now, Google Chrome only:
Copy to system clipboard       ctrl-shift-C
Paste from system clipboard    ctrl-shift-V

Indent     TAB
Deindent   shift-TAB
````

### Cursor

````
Up       ArrowUp
Down     ArrowDown
Left     ArrowLeft
Right    ArrowRight

Page up     ArrowUp
Page down   opt-ArrowDown
````

### Lines

````
Line start   opt-ArrowLeft,  ctrl-A
Line end     opt-ArrowRight, ctrl-E

First line   ctrl-opt-ArrowUp
Last line    ctrl-opt-ArrowDown
````

### Wrap 

````
Wrap selection   ctrl-W
Wrap all         ctrl-shift-W
````

### Other

````
Toggle dark mode   ctrl-Shift-D
Toggle help        ctrl-H
````

"""


view : Model -> Html MarkdownMsg
view model =
    case model.helpState of
        HelpOff ->
            Html.div [] []

        HelpOn ->
            Html.div
                [ HA.style "position" "absolute"
                , HA.style "left" "0"
                , HA.style "top" "37px"
                , HA.style "background-color" "#FEF8F1"
                , HA.style "z-index" "1000"
                , HA.style "width" (px (model.width - 20))
                , HA.style "height" (px model.height)
                , HA.style "overflow-y" "scroll"
                , HA.style "padding-left" "20px"
                ]
                [ Markdown.Render.toHtml ExtendedMath data
                ]


px : Float -> String
px p =
    String.fromFloat p ++ "px"
