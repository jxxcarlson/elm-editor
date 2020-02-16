module Sync exposing (filterMany, fuzzyGet, get)

import Dict exposing (Dict)


{-|

    kv =
        [ ( "a x a", "1" ), ( "b x x", "2" ), ( "c a a", "3" ), ( "x a x", "4" ), ( "abc", "5" ) ]

    dict =
        Dict.fromList kv

-}
get : String -> Dict String String -> Maybe String
get key dict_ =
    case Dict.get key dict_ of
        Just str ->
            Just str

        Nothing ->
            fuzzyGet key dict_ |> List.head


{-|

    kv = [("a x a", "1"), ("b x x", "2"),  ("c a a", "3"), ("x a x", "4")]
    dict = Dict.fromList kv

    fuzzyGet "a x" dict
    --> ["1","4"] : List String

    fuzzyGet "x a" dict
    --> ["1","4"]

-}
fuzzyGet : String -> Dict String String -> List String
fuzzyGet key dict_ =
    let
        associationList =
            Dict.toList dict_

        makePredicate a =
            \( b, _ ) -> String.contains a b

        predicates =
            List.map makePredicate (String.words key)
    in
    filterMany predicates associationList
        |> List.map Tuple.second


{-|

    ps = [\str -> String.contains "a" str, \str -> String.contains "x" str]


    filterMany ps ["aaa", "xxx", "xax", "axa"]
    --> ["xax","axa"]

-}
filterMany : List (a -> Bool) -> List a -> List a
filterMany predicates items =
    let
        makeFilter : (a -> Bool) -> List a -> List a
        makeFilter predicate list =
            List.filter predicate list
    in
    List.foldl makeFilter items predicates
