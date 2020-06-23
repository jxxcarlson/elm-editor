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


serverURL =
    "http://161.35.125.40:80/api"


token =
    "abracadabra"
