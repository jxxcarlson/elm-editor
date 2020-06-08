module Author exposing (..)

import Time


type alias Author =
    { name : String
    , userName : String
    , id : String
    , email : String
    , passwordHash : String
    , dateCreated : Time.Posix
    , dateModified : Time.Posix
    }
