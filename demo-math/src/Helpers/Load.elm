module Helpers.Load exposing (config)

import EditorModel
import EditorMsg exposing (EMsg(..), WrapOption(..))


config : EditorModel.Config
config =
    { width = windowWidth 1200
    , height = windowHeight 800
    , fontSize = 16
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
