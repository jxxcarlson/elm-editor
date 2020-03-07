module ArrayUtil exposing
    ( Position
    , between
    , cut
    , cutOut
    , cutString
    , diceStringAt
    , indent
    , indexOf
    , insert
    , insertLineAfter
    , join
    , joinEnds
    , joinThree
    , paragraphEnd
    , paragraphStart
    , paste
    , put
    , replace
    , replaceLines
    , split
    , splitStringAt
    , stringFromZipper
    )

import Array exposing (Array)
import List.Extra
import String.Extra


type alias Position =
    { line : Int, column : Int }


type alias StringZipper =
    { before : Array String
    , middle : Array String
    , after : Array String
    }


indexOf : String -> Array String -> Maybe ( Int, String )
indexOf key array =
    array
        |> Array.toIndexedList
        |> fuzzyGetOne key


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


fuzzyGetOne : String -> List ( Int, String ) -> Maybe ( Int, String )
fuzzyGetOne key list =
    let
        makePredicate : String -> ( a, String ) -> Bool
        makePredicate a =
            \( _, b ) -> String.contains a b

        predicates : List (( a, String ) -> Bool)
        predicates =
            List.map makePredicate (Debug.log "KWORDS" (String.words key))
    in
    loop { predicates = predicates, pairs = list } nextSearchState


type alias SearchState =
    { predicates : List (( Int, String ) -> Bool), pairs : List ( Int, String ) }


nextSearchState : SearchState -> Step SearchState (Maybe ( Int, String ))
nextSearchState { predicates, pairs } =
    case ( List.head predicates, List.length pairs ) of
        ( _, 0 ) ->
            Done Nothing

        ( _, 1 ) ->
            Done (List.head pairs)

        ( Just p, _ ) ->
            Loop
                { predicates = List.drop 1 predicates
                , pairs = List.filter p pairs
                }

        ( Nothing, _ ) ->
            Done (List.head pairs)


stringFromZipper : StringZipper -> String
stringFromZipper sz =
    stringFromArray sz.before ++ stringFromArray sz.middle ++ stringFromArray sz.after


stringFromArray : Array String -> String
stringFromArray array =
    array
        |> Array.toList
        |> String.join ""


{-|

    arrL = Array.fromList ["aaa", "bbb"]

    insert (Position 0 1) "X" arrL
    --> Array.fromList ["aXaa","bbb"]

    insert (Position 1 1) "X" arrL
    --> Array.fromList ["aaa","bXbb"]

-}
insert : Position -> String -> Array String -> Array String
insert position str array =
    case Array.get position.line array of
        Nothing ->
            array

        Just line ->
            let
                newLine =
                    String.Extra.insertAt str position.column line
            in
            Array.set position.line newLine array


insertLineAfter : Int -> String -> Array String -> Array String
insertLineAfter line str lines =
    let
        ( before, after ) =
            split { line = line + 1, column = 0 } lines
    in
    joinThree before (Array.fromList [ str ]) after


{-|

    arr : Array String
    arr = Array.fromList ["aaa","xyz","ccc"]

    split (Position 1 1) arr
    Array.fromList ["aaa","x","yz","xyz"]

-}
split : Position -> Array String -> ( Array String, Array String )
split position array =
    case Array.get position.line array of
        Nothing ->
            ( array, Array.fromList [ "" ] )

        Just focus ->
            let
                focusLength =
                    String.length focus

                n =
                    Array.length array

                before =
                    Array.slice 0 position.line array

                after =
                    Array.slice (position.line + 1) n array

                beforeSuffix =
                    String.slice 0 position.column focus

                afterPrefix =
                    String.slice position.column focusLength focus

                firstPart =
                    case beforeSuffix == "" of
                        True ->
                            before

                        False ->
                            Array.push beforeSuffix before

                secondPart =
                    put afterPrefix after
            in
            ( firstPart, secondPart )


splitStringAt : Int -> String -> ( String, String )
splitStringAt k str =
    let
        n =
            String.length str
    in
    ( String.slice 0 k str, String.slice k n str )


diceStringAt : Int -> Int -> String -> ( String, String, String )
diceStringAt j k str =
    let
        n =
            String.length str
    in
    ( String.slice 0 j str, String.slice j k str, String.slice k n str )


{-|

    arr =
        Array.fromList [ "abcde", "fghij", "klmn", "opqr" ]

    cut (Position 1 1) (Position 2 1) arr
    --> {  before = Array.fromList ["abcde","f"]
         , middle = Array.fromList ["ghij","k"]
         , after = Array.fromList ["lmn","opqr"]
        }

-}
cut : Position -> Position -> Array String -> StringZipper
cut pos1 pos2 array =
    let
        n =
            Array.length array

        before_ : Array String
        before_ =
            Array.slice 0 pos1.line array

        middle_ : Array String
        middle_ =
            Array.slice pos1.line (pos2.line + 1) array

        after_ : Array String
        after_ =
            Array.slice (pos2.line + 1) n array

        ( before, middle, after ) =
            case pos1.line == pos2.line of
                True ->
                    let
                        middleLine =
                            Array.get pos1.line array |> Maybe.withDefault ""

                        ( a_, part ) =
                            splitStringAt pos1.column middleLine

                        ( _, c_ ) =
                            splitStringAt (pos2.column - String.length a_ + 1) part

                        middle__ =
                            String.slice pos1.column (pos2.column + 1) middleLine

                        before__ =
                            case a_ ++ c_ of
                                "" ->
                                    before_

                                _ ->
                                    Array.push (a_ ++ c_) before_

                        after__ =
                            case a_ of
                                "" ->
                                    after_

                                _ ->
                                    after_
                    in
                    ( before__, Array.fromList [ middle__ ], after__ )

                False ->
                    let
                        firstLine =
                            Array.get pos1.line array |> Maybe.withDefault ""

                        lastLine =
                            Array.get pos2.line array
                                |> Maybe.withDefault ""

                        middle__ =
                            Array.slice (pos1.line + 1) pos2.line array

                        ( a_, part_1 ) =
                            splitStringAt pos1.column firstLine

                        before__ =
                            case a_ of
                                "" ->
                                    before_

                                _ ->
                                    Array.push a_ before_

                        ( part_2, c_ ) =
                            splitStringAt (pos2.column + 0) lastLine

                        after__ =
                            case c_ of
                                "" ->
                                    after_

                                _ ->
                                    put c_ after_

                        b__ =
                            joinThree (Array.fromList [ part_1 ]) middle__ (Array.fromList [ part_2 ])
                    in
                    ( before__, b__, after__ )
    in
    { before = before
    , middle = middle
    , after = after
    }


{-| copy string betwwen two positions
-}
between : Position -> Position -> Array String -> String
between pos1 pos2 array =
    case ( pos1.line == pos2.line, pos1.column == pos2.column ) of
        ( True, True ) ->
            ""

        ( True, False ) ->
            let
                middleLine =
                    Array.get pos1.line array |> Maybe.withDefault ""

                ( a_, part ) =
                    splitStringAt pos1.column middleLine

                ( _, _ ) =
                    splitStringAt (pos2.column - String.length a_ + 1) part

                middle__ =
                    String.slice pos1.column (pos2.column + 1) middleLine
            in
            middle__

        ( False, _ ) ->
            let
                firstLine =
                    Array.get pos1.line array |> Maybe.withDefault ""

                lastLine =
                    Array.get pos2.line array
                        |> Maybe.withDefault ""

                middle__ =
                    Array.slice (pos1.line + 1) pos2.line array

                ( _, part_1 ) =
                    splitStringAt pos1.column firstLine

                ( part_2, _ ) =
                    splitStringAt (pos2.column + 0) lastLine

                b__ =
                    joinThree (Array.fromList [ part_1 ]) middle__ (Array.fromList [ part_2 ])
            in
            b__ |> Array.toList |> String.join "\n"


cutString : Int -> Int -> Int -> Array String -> StringZipper
cutString line col1 col2 array =
    let
        n =
            Array.length array

        before_ =
            Array.slice 0 line array

        ( a, b, c ) =
            Array.get line array |> Maybe.withDefault "" |> diceStringAt col1 (col2 + 1)

        after_ =
            Array.slice (line + 1) n array

        before__ =
            case a of
                "" ->
                    before_

                _ ->
                    Array.push a before_

        after__ =
            case c of
                "" ->
                    after_

                _ ->
                    put c after_
    in
    { before = before__
    , middle = Array.fromList [ b ]
    , after = after__
    }


mapTriple : (a -> b) -> ( a, a, a ) -> ( b, b, b )
mapTriple f ( x, y, z ) =
    ( f x, f y, f z )


{-|

    arr =
        Array.fromList [ "abcde", "fghij", "klmn", "opqr" ]

    cutOut (Position 1 1) (Position 2 1) arr
    --> (Array.fromList ["ghij","k"], Array.fromList ["abcde","f","lmn","opqr"])

-}
cutOut : Position -> Position -> Array String -> ( Array String, Array String )
cutOut pos1 pos2 array =
    cut pos1 pos2 array
        |> (\sz -> ( sz.middle, Array.append sz.before sz.after ))


{-| Assume pos1 < pos2

    replace (Position 1 1) (Position 2 1) "UVW" arr
    --> Array.fromList ["abcde","f","UVW","lmn","opqr"]

-}
replace : Position -> Position -> String -> Array String -> Array String
replace pos1 pos2 str array =
    case pos1.line == pos2.line of
        True ->
            case Array.get pos1.line array of
                Nothing ->
                    array

                Just line ->
                    let
                        newLine =
                            String.Extra.replaceSlice str pos1.column pos2.column line
                    in
                    Array.set pos1.line newLine array

        False ->
            let
                sz =
                    cut pos1 pos2 array
            in
            Array.append (Array.push str sz.before) sz.after


replaceLines : Position -> Position -> Array String -> Array String -> Array String
replaceLines pos1 pos2 newLines targetLines =
    case pos1.line == pos2.line of
        True ->
            let
                sz =
                    cutString pos1.line pos1.column pos2.column targetLines
            in
            join { sz | middle = newLines }

        False ->
            let
                sz =
                    cut pos1 pos2 targetLines
            in
            join { sz | middle = newLines }


put : String -> Array String -> Array String
put str array =
    Array.append (Array.fromList [ str ]) array


joinEnds : StringZipper -> ( Array String, Array String )
joinEnds z =
    let
        joinedEnds =
            Array.append z.before z.after
    in
    ( joinedEnds, z.middle )


join : StringZipper -> Array String
join z =
    joinThree z.before z.middle z.after


joinThree : Array a -> Array a -> Array a -> Array a
joinThree before middle after =
    Array.append (Array.append before middle) after


paste : Position -> Array String -> Array String -> Array String
paste position newContent lines =
    let
        ( before, after ) =
            split position lines
    in
    joinThree before newContent after


{-| Indent a range of lines by 'offset'; 'offset' may be negative
-}
indent : Int -> Int -> Int -> Array String -> Array String
indent offset first last lines =
    let
        f lineNumber line =
            if lineNumber >= first && lineNumber <= last then
                indentLine offset line

            else
                line
    in
    Array.indexedMap f lines


indentLine : Int -> String -> String
indentLine offset line =
    case offset >= 0 of
        True ->
            indentLinePos offset line

        False ->
            indentLineNeg -offset line


indentLinePos : Int -> String -> String
indentLinePos offset line =
    String.repeat offset " " ++ line


indentLineNeg : Int -> String -> String
indentLineNeg offset line =
    let
        leadingBlanks =
            String.repeat offset " "
    in
    case String.left offset line == leadingBlanks of
        True ->
            String.dropLeft offset line

        False ->
            line


paragraphStart : Position -> Array String -> Int
paragraphStart position lines =
    let
        start =
            paragraphBoundary BeginParagraph position lines
    in
    case start == position.line of
        True ->
            start

        False ->
            start + 1


paragraphEnd : Position -> Array String -> Int
paragraphEnd position lines =
    let
        start =
            paragraphBoundary EndParagraph position lines
    in
    case start == position.line of
        True ->
            start

        False ->
            start - 1



--paragraphEnd : Position -> Array String -> Maybe Int
--paragraphEnd position lines =
--    lines
--        |> Array.indexedMap (\i line -> ( i, line ))
--        |> Array.filter (\( i, line ) -> i > position.line && line == "")
--        |> Array.toList
--        |> List.head
--        |> Maybe.map Tuple.first


type alias ST =
    { lastIndex : Int, lines : Array String, currentLine : Int }


type Direction
    = Forward
    | Backward


type ParagraphBoundary
    = BeginParagraph
    | EndParagraph


paragraphBoundary : ParagraphBoundary -> Position -> Array String -> Int
paragraphBoundary boundary position lines =
    let
        initialState =
            { lastIndex = Array.length lines - 1, lines = lines, currentLine = position.line }
    in
    case boundary of
        BeginParagraph ->
            loop initialState (next Backward)

        EndParagraph ->
            loop initialState (next Forward)


next : Direction -> ST -> Step ST Int
next direction st =
    case Array.get st.currentLine st.lines == Just "" of
        True ->
            Done st.currentLine

        False ->
            case direction of
                Forward ->
                    case st.currentLine < st.lastIndex of
                        True ->
                            Loop { st | currentLine = st.currentLine + 1 }

                        False ->
                            Done st.lastIndex

                Backward ->
                    case st.currentLine == 0 of
                        True ->
                            Done 0

                        False ->
                            Loop { st | currentLine = st.currentLine - 1 }



--
--type alias STX =
--    { counter : Int, value : Int }
--
--
--{-|
--
--    Add integers 1 .. 5
--    > loop {counter = 5, value = 0} f
--    15
--
---}
--f : STX -> Step STX Int
--f st =
--    case st.counter of
--        0 ->
--            Done st.value
--
--        _ ->
--            Loop { st | counter = st.counter - 1, value = st.value + st.counter }
