module Helper.Common exposing (windowHeight, windowWidth)


windowWidth : Float -> Float
windowWidth appWidth =
    min (0.5 * appWidth) 600


windowHeight : Float -> Float
windowHeight appHeight =
    appHeight - 140
