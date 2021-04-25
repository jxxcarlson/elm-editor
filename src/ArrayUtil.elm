module ArrayUtil exposing
    ( between
    , cut
    , cutOut
    , cutString
    , diceStringAt
    , firstLine_
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
import Position exposing (Position, deltaLine)
import String.Extra



{-

   Functions:

       stringFromZipper : StringZipper -> String

       cut : Position -> Position -> Array String -> StringZipper

       cutString : Int -> Int -> Int -> Array String -> StringZipper
       cutString line col1 col2 array = ...

       joinEnds : StringZipper -> ( Array String, Array String )
       joinEnds z = ... ( joinedEnds, z.middle )

       join : StringZipper -> Array String
       join z = joinThree z.before z.middle z.after

-}


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
            List.map makePredicate (String.words key)
    in
    loop { predicates = predicates, pairs = list } nextSearchState


type alias SearchState =
    { predicates : List (( Int, String ) -> Bool)
    , pairs : List ( Int, String )
    }


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
                    if beforeSuffix == "" then
                        before

                    else
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

        after_ : Array String
        after_ =
            Array.slice (pos2.line + 1) n array

        ( before, middle, after ) =
            if pos1.line == pos2.line then
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

            else
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
    if pos1.line == pos2.line then
        case Array.get pos1.line array of
            Nothing ->
                array

            Just line ->
                let
                    newLine =
                        String.Extra.replaceSlice str pos1.column pos2.column line
                in
                Array.set pos1.line newLine array

    else
        let
            sz =
                cut pos1 pos2 array
        in
        Array.append (Array.push str sz.before) sz.after


replaceLines : Position -> Position -> Array String -> Array String -> Array String
replaceLines pos1 pos2 newLines targetLines =
    if pos1.line == pos2.line then
        case ( Array.length newLines == 1, lengthOfLine 0 newLines /= lengthOfLine pos1.line targetLines ) of
            ( True, True ) ->
                let
                    _ =
                        Debug.log "BR 1 (pos1, pos2)" ( pos1, pos2 )

                    _ =
                        Debug.log "target lines" targetLines

                    _ =
                        Debug.log "CUT" (cutOut pos1 pos2 targetLines)

                    targetLines_ =
                        if pos1 == pos2 then
                            targetLines

                        else
                            cutOut pos1 pos2 targetLines |> Tuple.second
                in
                insert pos1 (firstLine_ newLines) targetLines_

            ( True, False ) ->
                let
                    _ =
                        Debug.log "BR" "2"
                in
                insertLineAfter (pos1.line - 1) (firstLine_ newLines) targetLines

            ( False, _ ) ->
                let
                    _ =
                        Debug.log "BR" "3"

                    _ =
                        Debug.log "newlines" newLines

                    { before, middle, after } =
                        cut pos1 pos2 targetLines |> Debug.log "CT"
                in
                joinThree before newLines after |> Debug.log "JOIN"

    else
        let
            sz =
                cut pos1 pos2 targetLines
        in
        join { sz | middle = newLines }


lengthOfLine line targetLines =
    Array.get line targetLines
        |> Maybe.map String.length


firstLine_ : Array String -> String
firstLine_ newLines =
    Array.get 0 newLines |> Maybe.withDefault ""


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
    if offset >= 0 then
        indentLinePos offset line

    else
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
    if String.left offset line == leadingBlanks then
        String.dropLeft offset line

    else
        line


paragraphStart : Position -> Array String -> Int
paragraphStart position lines =
    let
        start =
            paragraphBoundary BeginParagraph position lines
    in
    if start == position.line then
        start

    else
        start + 1


paragraphEnd : Position -> Array String -> Int
paragraphEnd position lines =
    let
        start =
            paragraphBoundary EndParagraph position lines
    in
    if start == position.line then
        start

    else
        start - 1


type alias ST =
    { lastIndex : Int
    , lines : Array String
    , currentLine : Int
    }


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
    if Array.get st.currentLine st.lines == Just "" then
        Done st.currentLine

    else
        case direction of
            Forward ->
                if st.currentLine < st.lastIndex then
                    Loop { st | currentLine = st.currentLine + 1 }

                else
                    Done st.lastIndex

            Backward ->
                if st.currentLine == 0 then
                    Done 0

                else
                    Loop { st | currentLine = st.currentLine - 1 }
