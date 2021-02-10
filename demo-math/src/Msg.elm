module Msg exposing(..)

import Editor exposing(EditorMsg)
import Debounce
import Browser.Dom as Dom
import MiniLatex.Edit exposing(LaTeXMsg)

type Msg
    = MyEditorMsg Editor.EditorMsg
    | NoOp
    | Clear
    | Render String
    | GetContent String
    | GetMacroText String
    | DebounceMsg Debounce.Msg
    | GenerateSeed
    | NewSeed Int
    | FullRender
    | RestoreText
    | ExampleText
    | SetViewPortForElement (Result Dom.Error ( Dom.Element, Dom.Viewport ))
    | LaTeXMsg MiniLatex.Edit.LaTeXMsg
    | Export
