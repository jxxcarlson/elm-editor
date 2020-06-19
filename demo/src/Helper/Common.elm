module Helper.Common exposing
    ( addPostfix
    , dateStringFromPosix
    , listFromString
    , removePostfix
    , stringFromList
    , windowHeight
    , windowWidth
    )

import Date
import List.Extra
import Time exposing (toHour, toMinute, toSecond)


dateStringFromPosix : Time.Posix -> String
dateStringFromPosix t =
    t
        |> Date.fromPosix Time.utc
        |> Date.toIsoString
        |> (\x -> x ++ " at " ++ toUtcString t)


toUtcString : Time.Posix -> String
toUtcString time =
    String.fromInt (toHour Time.utc time)
        ++ ":"
        ++ String.fromInt (toMinute Time.utc time)
        ++ " (UTC)"


windowWidth : Float -> Float
windowWidth appWidth =
    -- min (0.5 * appWidth) 600
    -- 0.5 * appWidth
    min (0.5 * appWidth) 600


windowHeight : Float -> Float
windowHeight appHeight =
    appHeight - 70


addPostfix : String -> String -> String
addPostfix postfix fileName =
    let
        parts =
            String.split "." fileName

        n =
            List.length parts

        extension =
            List.drop (n - 1) parts

        initialParts =
            List.take (n - 1) parts

        newParts =
            initialParts ++ [ postfix ] ++ extension
    in
    String.join "." newParts


removePostfix : String -> String -> String
removePostfix postfix fileName =
    let
        parts =
            String.split "." fileName

        n =
            List.length parts

        extension =
            List.drop (n - 1) parts

        postfix_ =
            List.Extra.getAt (n - 2) parts |> Maybe.withDefault "@%!"

        initialParts =
            List.take (n - 2) parts

        newParts =
            initialParts ++ extension
    in
    case postfix == postfix_ of
        True ->
            String.join "." newParts

        False ->
            fileName


stringFromList : List String -> String
stringFromList list =
    String.join ", " list


listFromString : String -> List String
listFromString str =
    String.split "," str
        |> List.map String.trim
