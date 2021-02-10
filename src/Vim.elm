module Vim exposing (..)


type alias VimModel =
    { buffer : String
    , state : VState
    }


init : VimModel
init =
    { buffer = ""
    , state = VNormal
    }


type VState
    = VAccumulate
    | VNormal


type VimMsg
    = StartCommand
    | ToBuffer String
