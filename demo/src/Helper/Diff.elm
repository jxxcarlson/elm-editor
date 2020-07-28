module Helper.Diff exposing
    ( acceptLocal
    , acceptOneLocal
    , acceptOneRemote
    , acceptRemote
    , compareDocuments
    , conflictsResolved
    , rejectOneLocal
    , rejectOneRemote
    , rxLocal
    , rxRemote
    , t1
    , t2
    )

import Diff exposing (Change(..))
import Document exposing (Document)
import Maybe.Extra
import Regex


rxLocal =
    regexFromString "@local\\[([^]+?)\\]"


rxRemote =
    regexFromString "@remote\\[([^]+?)\\]"


regexFromString : String -> Regex.Regex
regexFromString string =
    Regex.fromStringWith { caseInsensitive = False, multiline = True } string
        |> Maybe.withDefault Regex.never


replacer match =
    List.head match.submatches
        |> Maybe.Extra.join
        |> Maybe.withDefault ""


acceptLocal : String -> String
acceptLocal str =
    str
        |> acceptLocal_
        |> rejectRemote_


acceptRemote : String -> String
acceptRemote str =
    str
        |> acceptRemote_
        |> rejectLocal_


acceptLocal_ : String -> String
acceptLocal_ str =
    Regex.replace rxLocal replacer str


acceptOneLocal : String -> String
acceptOneLocal str =
    Regex.replaceAtMost 1 rxLocal replacer str


rejectLocal_ : String -> String
rejectLocal_ str =
    Regex.replace rxLocal (.match >> (\s -> "")) str


rejectOneLocal : String -> String
rejectOneLocal str =
    Regex.replaceAtMost 1 rxLocal (.match >> (\s -> "")) str


acceptRemote_ : String -> String
acceptRemote_ str =
    Regex.replace rxRemote replacer str


acceptOneRemote : String -> String
acceptOneRemote str =
    Regex.replaceAtMost 2 rxRemote replacer str


rejectRemote_ : String -> String
rejectRemote_ str =
    Regex.replace rxRemote (.match >> (\s -> "")) str


rejectOneRemote : String -> String
rejectOneRemote str =
    Regex.replaceAtMost 1 rxRemote (.match >> (\s -> "")) str


t1 =
    """a
b
@local[c
d
e]
@remote[f
g
h]
i
j
"""


t2 =
    """a
b
@local[c
d
e]
t
y
@local[U
V
V]
x
y
@remote[f
g
h]
i
j
"""


t3 =
    """# AAA

a
b
@local[cL
dL
e
f]
@remote[c
d
eR
fR]

"""


{-|

    Does the string represent a document with merge conflicts?

-}
conflictsResolved : String -> Bool
conflictsResolved str =
    if String.contains "@remote[" str then
        False
    else 
        not <| String.contains "@local[" str



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
            if str == "" then
                str
            else
                "@remote[" ++ str ++ "]"

        Removed str ->
            if str == "" then
                str
            else
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
