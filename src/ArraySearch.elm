module ArraySearch exposing (filter)

import Array exposing (Array)


type Step state a
    = Loop state
    | Done a


loop : state -> (state -> Step state a) -> a
loop s nextState_ =
    case nextState_ s of
        Loop s_ ->
            loop s_ nextState_

        Done b ->
            b


type alias State =
    { pairs : List ( Int, String )
    , keywords : List String
    , span : Int
    }


filterWithKey : String -> Array String -> List ( Int, String )
filterWithKey key array =
    array
        |> Array.indexedMap (\index line -> ( index, line ))
        |> Array.filter (\( _, line ) -> String.contains key line)
        |> Array.toList


expandPair : Int -> Array String -> ( Int, String ) -> ( Int, String )
expandPair span array ( index, _ ) =
    ( index, getString index span array )


expandPairs : Int -> Array String -> List ( Int, String ) -> List ( Int, String )
expandPairs span array pairs =
    List.map (expandPair span array) pairs


getString : Int -> Int -> Array String -> String
getString start length array =
    array
        |> Array.slice start (start + length)
        |> Array.toList
        |> String.join "\n"


init : List String -> Array String -> State
init keywords array =
    case List.head keywords of
        Nothing ->
            { pairs = [], keywords = [], span = 0 }

        Just key ->
            { pairs = filterWithKey key array, keywords = List.drop 1 keywords, span = 1 }


getIndices : State -> List Int
getIndices state =
    state.pairs |> List.map Tuple.first


filter : List String -> Array String -> List Int
filter keywords array =
    let
        initialState =
            init keywords array

        indices =
            getIndices initialState
    in
    if List.length indices < 2 then
        indices

    else
        loop initialState (nextState array)


nextState : Array String -> State -> Step State (List Int)
nextState array state =
    case List.head state.keywords of
        Nothing ->
            Done (getIndices state)

        Just key ->
            if List.length state.pairs < 2 || state.span > 5 then
                Done (getIndices state)

            else
                let
                    span =
                        state.span + 1

                    keywords =
                        List.drop 1 state.keywords

                    pairs =
                        expandPairs span array state.pairs |> filterPairs key
                in
                Loop { span = span, keywords = keywords, pairs = pairs }


filterPairs : String -> List ( Int, String ) -> List ( Int, String )
filterPairs key pairs =
    List.filter (\( _, str ) -> String.contains key str) pairs
