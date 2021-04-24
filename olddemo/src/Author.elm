module Author exposing (Author, AuthorWithPasswordHash)

import Time


type alias AuthorWithPasswordHash =
    { name : String
    , userName : String
    , id : String
    , email : String
    , passwordHash : String
    , dateCreated : Time.Posix
    , dateModified : Time.Posix
    }


type alias Author =
    { name : String
    , userName : String
    , id : String
    , email : String
    , dateCreated : Time.Posix
    , dateModified : Time.Posix
    }
