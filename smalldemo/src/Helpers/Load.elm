module Helpers.Load exposing(config)

import EditorMsg exposing (EMsg(..), WrapOption(..))
import EditorModel


config : EditorModel.Config
config =
    { width = windowWidth 1800 -- 1200
    , height = windowHeight 700
    , fontSize = 16
    , lineNumbersOn = False
    , verticalScrollOffset = 3
    , viewMode = EditorModel.Dark
    , debugOn = False
    , viewLineNumbersOn = False
    , wrapOption = DontWrap
    }

windowWidth : Float -> Float
windowWidth appWidth =
    min (0.5 * appWidth) 900


windowHeight : Float -> Float
windowHeight appHeight =
    appHeight - 70