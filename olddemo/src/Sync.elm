module Sync exposing
    ( ST
    , Step(..)
    , f
    , filterMany
    , fuzzyGet
    , fuzzyGetOne
    , getId
    , getIdFromString
    , getText
    , loop
    , stringFromId
    )

import BiDict exposing (BiDict)
import Parser exposing ((|.), (|=), Parser)
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
        idSet =
            BiDict.getReverse text_ dict_
    in
    if BiDict.getReverse text_ dict_ |> Set.isEmpty then
        fuzzyGetOne text_ dict_
            |> List.head

    else
        idSet
            |> Set.toList
            |> List.head



-- fuzzyGet text dict_


getIdFromString : String -> Maybe ( Int, Int )
getIdFromString str =
    case Parser.run parseId str of
        Ok result ->
            Just result

        Err _ ->
            Nothing


stringFromId : ( Int, Int ) -> String
stringFromId ( i, v ) =
    "i" ++ String.fromInt i ++ "v" ++ String.fromInt v


parseId : Parser ( Int, Int )
parseId =
    Parser.succeed (\i v -> ( i, v ))
        |. Parser.symbol "i"
        |= Parser.int
        |. Parser.symbol "v"
        |= Parser.int


getText : String -> BiDict String String -> Maybe String
getText id dict_ =
    BiDict.get id dict_


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

        makePredicate_ : String -> ( a, String ) -> Bool
        makePredicate_ a =
            \( _, b_ ) -> String.contains a b_

        predicates : List (( b, String ) -> Bool)
        predicates =
            List.map makePredicate_ (String.words key)
    in
    filterMany predicates associationList
        |> List.map Tuple.second
        |> List.head


fuzzyGetOne : String -> BiDict String String -> List String
fuzzyGetOne key dict_ =
    let
        associationList =
            BiDict.toList dict_
    in
    loop { keywords = String.words key, pairs = associationList } nextSearchState


makePredicate : String -> ( a, String ) -> Bool
makePredicate a =
    \( _, b ) -> String.contains a b


type alias SearchState =
    { keywords : List String
    , pairs : List ( String, String )
    }


nextSearchState : SearchState -> Step SearchState (List String)
nextSearchState { keywords, pairs } =
    case ( List.head keywords, List.length pairs ) of
        ( Nothing, _ ) ->
            Done (List.map Tuple.first pairs)

        ( _, 0 ) ->
            Done []

        ( _, 1 ) ->
            Done (List.map Tuple.first pairs)

        ( Just key, _ ) ->
            Loop
                { keywords = List.drop 1 keywords
                , pairs = List.filter (makePredicate key) pairs
                }


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
    { counter : Int
    , value : Int
    }


{-|

    Add integers 1 .. 5
    > loop {counter = 5, value = 0} f
    15

-}
f : ST -> Step ST Int
f st =
    case st.counter of
        0 ->
            Done st.value

        _ ->
            Loop { st | counter = st.counter - 1, value = st.value + st.counter }
