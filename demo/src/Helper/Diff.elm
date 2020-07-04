module Helper.Diff exposing (compareDocuments, conflictsResolved)

import Diff exposing (Change(..))
import Document exposing (Document)


{-|

    Does the string represent a document with merge conflicts?

-}
conflictsResolved : String -> Bool
conflictsResolved str =
    if String.contains "@remote[" str then
        False

    else if String.contains "@local[" str then
        False

    else
        True



-- COMPARISON


{-|

    Compare the local and remote documents, flagging
    insertions and deletions with @local[...] and
    @remote[...]

-}
compareDocuments : Document -> Document -> Document
compareDocuments localDoc remoteDoc =
    { localDoc | content = compare localDoc.content remoteDoc.content }


compare : String -> String -> String
compare a b =
    Diff.diffLines a b
        |> coalesce
        |> List.map stringValue
        |> String.join "\n"


stringValue : Change String -> String
stringValue change =
    case change of
        Added str ->
            case str == "" of
                True ->
                    str

                False ->
                    "@remote[" ++ str ++ "]"

        Removed str ->
            case str == "" of
                True ->
                    str

                False ->
                    "@local[" ++ str ++ "]"

        NoChange str ->
            str



-- COALESCING


coalesce : List (Change String) -> List (Change String)
coalesce diffData =
    loop { input = diffData, currentItem = NoChange "", output = [] } nextState
        |> List.reverse


type alias ST =
    { input : List (Change String)
    , currentItem : Change String
    , output : List (Change String)
    }


nextState : ST -> Step ST (List (Change String))
nextState st =
    case List.head st.input of
        Nothing ->
            Done (st.currentItem :: st.output)

        Just item ->
            Loop (advance item { st | input = List.drop 1 st.input })


advance : Change String -> ST -> ST
advance item st =
    case ( item, st.currentItem ) of
        ( NoChange _, NoChange str ) ->
            { st | currentItem = item, output = NoChange str :: st.output }

        ( NoChange _, Added str ) ->
            { st | currentItem = item, output = Added str :: st.output }

        ( NoChange _, Removed str ) ->
            { st | currentItem = item, output = Removed str :: st.output }

        ( Removed str, NoChange str2 ) ->
            { st | currentItem = Removed str, output = NoChange str2 :: st.output }

        ( Removed str, Removed str2 ) ->
            { st | currentItem = Removed (str2 ++ "\n" ++ str) }

        ( Removed str, Added str2 ) ->
            { st | currentItem = Removed str, output = Added str2 :: st.output }

        ( Added str, NoChange str2 ) ->
            { st | currentItem = Added str, output = NoChange str2 :: st.output }

        ( Added str, Removed str2 ) ->
            { st | currentItem = Added str, output = Removed str2 :: st.output }

        ( Added str, Added str2 ) ->
            { st | currentItem = Added (str2 ++ "\n" ++ str) }



-- LOOP


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



-- TEST DATA


d1 =
    [ NoChange "one", NoChange "two" ]


d2 =
    d1 ++ [ Added "three", Added "four" ]


d3 =
    d2 ++ [ NoChange "five" ]


d4 =
    d3 ++ [ Added "six", Removed "seven" ]
