module Sync exposing (ST, Step(..), f, filterMany, fuzzyGet, fuzzyGetOne, g, getId, getText, loop)

import BiDict exposing (BiDict)
import Set


{-|

    kv =
        [ ( "a x a", "1" ), ( "b x x", "2" ), ( "c a a", "3" ), ( "x a x", "4" ), ( "abc", "5" ) ]

    dict =
        Dict.fromList kv

-}
getId : String -> BiDict String String -> Maybe String
getId text_ dict_ =
    let
        text =
            clean text_

        idSet =
            BiDict.getReverse text dict_
    in
    case BiDict.getReverse text dict_ |> Set.isEmpty of
        False ->
            idSet
                |> Set.toList
                |> List.head

        True ->
            fuzzyGetOne text dict_



-- getText : String -> BiDict String String -> Maybe String


getText : String -> BiDict String String -> Maybe String
getText id dict_ =
    BiDict.get id dict_



--
--
--get_ :
--    String
--    -> (String -> Dict String String -> Maybe String)
--    -> Dict String String
--    -> Maybe String
--get_ key lookup dict_ =
--    case Dict.get (clean key) dict_ of
--        Just str ->
--            Just str
--
--        --Nothing ->
--        --    fuzzyGet key dict_ |> List.head
--        Nothing ->
--            lookup key dict_
--


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
fuzzyGet : String -> BiDict String String -> Maybe String
fuzzyGet key dict_ =
    let
        associationList : List ( String, String )
        associationList =
            BiDict.toList dict_

        makePredicate : String -> ( a, String ) -> Bool
        makePredicate a =
            \( _, b_ ) -> String.contains a b_

        predicates : List (( b, String ) -> Bool)
        predicates =
            List.map makePredicate (String.words key)
    in
    filterMany predicates associationList
        |> List.map Tuple.second
        |> List.head


fuzzyGetOne : String -> BiDict String String -> Maybe String
fuzzyGetOne key dict_ =
    let
        associationList =
            BiDict.toList dict_

        makePredicate a =
            \( _, b ) -> String.contains a b

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
            Done (List.head pairs |> Maybe.map Tuple.first)

        ( Just p, _ ) ->
            Loop
                { predicates = List.drop 1 predicates
                , pairs = List.filter p pairs
                }

        ( Nothing, _ ) ->
            Done (List.head pairs |> Maybe.map Tuple.first)


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
