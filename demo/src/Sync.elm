module Sync exposing (ST, Step(..), f, filterMany, fuzzyGet, g, get, loop)

import Dict exposing (Dict)


{-|

    kv =
        [ ( "a x a", "1" ), ( "b x x", "2" ), ( "c a a", "3" ), ( "x a x", "4" ), ( "abc", "5" ) ]

    dict =
        Dict.fromList kv

-}
get : String -> Dict String String -> Maybe String
get key_ dict_ =
    let
        key =
            clean key_
    in
    case Dict.get key dict_ of
        Just str ->
            Just str

        Nothing ->
            fuzzyGetOne key dict_


get_ :
    String
    -> (String -> Dict String String -> Maybe String)
    -> Dict String String
    -> Maybe String
get_ key lookup dict_ =
    case Dict.get (clean key) dict_ of
        Just str ->
            Just str

        --Nothing ->
        --    fuzzyGet key dict_ |> List.head
        Nothing ->
            lookup key dict_


clean : String -> String
clean str =
    str
        |> String.replace "}" " "
        |> String.replace "{" " "
        |> String.replace "\\" ""


{-|

    kv = [("a x a", "1"), ("b x x", "2"),  ("c a a", "3"), ("x a x", "4")]
    dict = Dict.fromList kv

    fuzzyGet "a x" dict
    --> ["1","4"] : List String

    fuzzyGet "x a" dict
    --> ["1","4"]

-}
fuzzyGet : String -> Dict String String -> Maybe String
fuzzyGet key dict_ =
    let
        associationList =
            Dict.toList dict_

        makePredicate a =
            \( b, _ ) -> String.contains a b

        predicates : List (( String, b ) -> Bool)
        predicates =
            List.map makePredicate (String.words key)
    in
    filterMany predicates associationList
        |> List.map Tuple.second
        |> List.head


fuzzyGetOne : String -> Dict String String -> Maybe String
fuzzyGetOne key dict_ =
    let
        associationList =
            Dict.toList dict_

        makePredicate a =
            \( b, _ ) -> String.contains a b

        predicates =
            List.map makePredicate (String.words key)
    in
    loop { predicates = predicates, pairs = associationList } nextSearchState


type alias SearchState =
    { predicates : List (( String, String ) -> Bool), pairs : List ( String, String ) }


nextSearchState : SearchState -> Step SearchState (Maybe String)
nextSearchState { predicates, pairs } =
    case ( List.head predicates, List.length pairs ) of
        ( _, 0 ) ->
            Done Nothing

        ( _, 1 ) ->
            Done (List.head pairs |> Maybe.map Tuple.second)

        ( Just p, _ ) ->
            Loop
                { predicates = List.drop 1 predicates
                , pairs = List.filter p pairs
                }

        ( _, _ ) ->
            Done Nothing


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



--filterToOne : (List (a -> Bool)) ->
--clean : String -> String
--clean str =


type Step state a
    = Loop state
    | Done a


loop : state -> (state -> Step state a) -> a
loop s nextState =
    case nextState s of
        Loop s_ ->
            loop s_ nextState

        Done b ->
            b


type alias ST =
    { counter : Int, value : Int }


f : ST -> Step ST Int
f st =
    case st.counter of
        0 ->
            Done st.value

        _ ->
            Loop { st | counter = st.counter - 1, value = st.value + st.counter }


g : ST -> Step ST Int
g st =
    if st.counter == 0 then
        Done st.value

    else
        f { st | counter = st.counter - 1, value = st.value + 1 }
