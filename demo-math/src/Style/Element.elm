module Style.Element exposing (..)

import Element exposing (..)


gray g =
    rgb g g g


noFocus : Element.FocusStyle
noFocus =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }
