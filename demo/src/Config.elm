module Config exposing (appMode, tickInterval, messageLifeTime, fileLocation, serverURL, testURL, token)

import Types exposing (AppMode(..), FileLocation(..))


appMode : AppMode
appMode =
    Desktop


viewLineNumbersOn : Bool
viewLineNumbersOn = False


tickInterval : number
tickInterval =
    1000


messageLifeTime : number
messageLifeTime =
    5


fileLocation : FileLocation
fileLocation =
    FilesOnDisk


{-| SERVERS:
<http://localhost:4000/api>
<http://161.35.125.40:80/api>
-}
serverURL : String
serverURL =
    "http://161.35.125.40:80/api"


testURL : String
testURL =
    "http://161.35.125.40:80/api/document/jxxcarlson.test-3f7d-483d.tex"


token : String
token =
    "abracadabra"
