module Test exposing (ensureNonBreakingSpace)

import Array exposing (Array)
import Browser
import Browser.Dom as Dom
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Html.Events as HE
import Html.Lazy
import Json.Decode as JD exposing (Decoder)
import Task


nonBreakingSpace : Char
nonBreakingSpace =
    Char.fromCode 160


ensureNonBreakingSpace : Char -> Char
ensureNonBreakingSpace char =
    case char of
        ' ' ->
            nonBreakingSpace

        _ ->
            char
