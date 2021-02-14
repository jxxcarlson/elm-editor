module Helper.Load exposing (config, makeConfig)

import EditorModel
import EditorMsg exposing (EMsg(..), WrapOption(..))


makeConfig : Int -> Int -> EditorModel.Config
makeConfig appWidth appHeight =
    let
        w =
            windowWidth (toFloat appWidth)

        h =
            windowHeight (toFloat appHeight)
    in
    { width = w
    , height = h
    , fontSize = 16
    , verticalScrollOffset = 3
    , viewMode = EditorModel.Dark
    , debugOn = False
    , viewLineNumbersOn = False
    , wrapOption = DontWrap
    }


config : EditorModel.Config
config =
    { width = windowWidth 1100
    , height = windowHeight 720
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
