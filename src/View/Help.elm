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

## Menu

The items in the menu bar are

- Help:  toggles this help page
- (142,  589) or something like that: the number of lines and words
- Go: enter a line number and press this button
- brkOn: toggle automatic line-breaking


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

Type (, [, {, ` and the editor will
match with ), ], }, `.  Works also
if there is a selection.
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

### Selection

Extend selection using shift + an arrow key (left, right, up, down)

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
Toggle edit mode   ctrl-shift-|

The last command is to toggle between normal
editing and Vim mode.
````

### About Vim Mode

Vim mode is not yet
operational and it will be a while before it is.
So far I have installed a primitive scaffolding for
building this feature, but have implemented only the commands listed
below.  I will do a little more, reserving plenty
of things for the April 25 hackathon in Paris.

### Vim commands implemented so far

````
i, ESC
h, j, k, l
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
