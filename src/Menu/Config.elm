module Menu.Config exposing (deepBlue, googleSpreadsheet, gray, lightBlue, lightGray, mac, white, winChrome, winDesktop, winEdge, winFirefox)

import ContextMenu exposing (Cursor(..), Direction(..), Overflow(..), defaultConfig)


type alias Color =
    String


winDesktop : ContextMenu.Config
winDesktop =
    { defaultConfig
        | direction = LeftBottom
        , overflowX = Shift
        , overflowY = Mirror
        , containerColor = lightGray
        , hoverColor = gray
        , invertText = False
        , cursor = Arrow
        , rounded = False
    }


winChrome : ContextMenu.Config
winChrome =
    { defaultConfig
        | direction = RightBottom
        , overflowX = Shift
        , overflowY = Mirror
        , containerColor = white
        , hoverColor = lightGray
        , invertText = False
        , cursor = Arrow
        , rounded = False
    }


winFirefox : ContextMenu.Config
winFirefox =
    { defaultConfig
        | direction = RightBottom
        , overflowX = Shift
        , overflowY = Mirror
        , containerColor = lightGray
        , hoverColor = lightBlue
        , invertText = False
        , cursor = Arrow
        , rounded = False
    }


winEdge : ContextMenu.Config
winEdge =
    { defaultConfig
        | direction = RightBottom
        , overflowX = Mirror
        , overflowY = Mirror
        , containerColor = lightGray
        , hoverColor = gray
        , invertText = False
        , cursor = Arrow
        , rounded = False
    }


mac : ContextMenu.Config
mac =
    { defaultConfig
        | direction = RightBottom
        , overflowX = Mirror
        , overflowY = Shift
        , containerColor = lightGray
        , hoverColor = deepBlue
        , invertText = True
        , cursor = Arrow
        , rounded = True
    }


googleSpreadsheet : ContextMenu.Config
googleSpreadsheet =
    { defaultConfig
        | direction = RightBottom
        , overflowX = Shift
        , overflowY = Shift
        , containerColor = white
        , hoverColor = lightGray
        , invertText = False
        , cursor = Pointer
        , rounded = False
    }



---- COLORS


white : Color
white =
    "rgb(255, 255, 255)"


lightGray : Color
lightGray =
    "rgb(238, 238, 238)"


gray : Color
gray =
    "rgb(217, 217, 217)"


lightBlue : Color
lightBlue =
    "rgb(117, 199, 253)"


deepBlue : Color
deepBlue =
    "rgb(62,126,255)"
