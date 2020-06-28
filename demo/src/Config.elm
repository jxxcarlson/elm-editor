module Config exposing (..)

import Types exposing (AppMode(..), FileLocation(..))


appMode =
    Desktop


tickInterval =
    1000


messageLifeTime =
    5


fileLocation =
    FilesOnDisk


{-| SERVERS:
"<http://localhost:4000/api">
"<http://161.35.125.40:80/api">
-}
serverURL =
    "http://localhost:4000/api"


testURL =
    "http://161.35.125.40:80/api/document/jxxcarlson.test-3f7d-483d.tex"


token =
    "abracadabra"
