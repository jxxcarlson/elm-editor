module View.Help exposing (data, view)

import EditorModel exposing (EditorModel, HelpState(..))
import Html exposing (Html)
import Html.Attributes as HA
import Markdown.Option exposing (MarkdownOption(..), OutputOption(..))
import Markdown.Render exposing (MarkdownMsg(..))



--, "Open file" |> ContextMenu.shortcut "ctrl-O", RequestFile )
--"Save file" |> ContextMenu.shortcut "ctrl-opt-S", SaveFile )
--  ]


data : String
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

```nolang
Search                ctrl-S
Next search hit       ctrl-.   (Think >)
Previous search hit   ctrl-,   (Think <)
```
    
### Content

```nolang
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
```

### Sync

Press `ctrl-\\` in the source text to sync
it to the rendered text.  Click in the rendered
text to sync to the source text.

### Cursor

```nolang
Up       ArrowUp
Down     ArrowDown
Left     ArrowLeft
Right    ArrowRight

Page up     ArrowUp
Page down   opt-ArrowDown
```

### Selection

Extend selection using shift + an arrow key (left, right, up, down).
Double-click (or ctrl-J) to select a word, triple-click (or ctrl-L)
to select a line.

### Lines

```nolang
Line start   opt-ArrowLeft,  ctrl-A
Line end     opt-ArrowRight, ctrl-E

First line   ctrl-opt-ArrowUp
Last line    ctrl-opt-ArrowDown
```

### Wrap 

```nolang
Wrap selection   ctrl-W
Wrap all         ctrl-shift-W
```

### Other

```nolang
Toggle dark mode   option-D
Toggle help        ctrl-H
Toggle Vim mode    option-V
```

### About Vim Mode

Vim mode is not yet
operational and it will be a while before it is.
So far I have installed a primitive scaffolding for
building this feature, but have implemented only the commands listed
below.  I will do a little more, reserving plenty
of things for the April 25 hackathon in Paris.

### Vim commands implemented so far

```nolang
i, ESC
h, j, k, l
```

For LaTeX command execution, use sequences like `"= \\pi ="`
to insert `$\\pi$`.


"""


view : EditorModel -> Html MarkdownMsg
view model =
    case model.helpState of
        HelpOff ->
            Html.div [] []

        HelpOn ->
            Html.div
                [ HA.style "position" "absolute"
                , HA.style "left" "0"
                , HA.style "top" "37px"
                , HA.style "background-color" "#fff"
                , HA.style "z-index" "1000"
                , HA.style "width" (px (model.width - 20))
                , HA.style "height" (px model.height)
                , HA.style "overflow-y" "scroll"
                , HA.style "padding-left" "20px"
                , HA.style "font-size" "14px"
                , HA.style "line-height" "1.3"
                ]
                [ Markdown.Render.toHtml ExtendedMath data
                ]


px : Float -> String
px p =
    String.fromFloat p ++ "px"
