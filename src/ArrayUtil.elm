module ArrayUtil exposing
    ( Position
    , cut
    , cutOut
    , insert
    , join
    , put
    , replace
    , split
    , splitStringAt
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


{-|

    arr : Array String
    arr = Array.fromList ["aaa","xyz","ccc"]

    split (Position 1 1) arr
    Array.fromList ["aaa","x","yz","xyz"]

-}
split : Position -> Array String -> Array String
split position array =
    case Array.get position.line array of
        Nothing ->
            array

        Just focus ->
            let
                focusLength =
                    String.length focus

                before =
                    Array.slice 0 position.line array

                after =
                    Array.slice position.line (focusLength - 1) array

                beforeSuffix =
                    String.slice 0 position.column focus

                afterPrefix =
                    String.slice position.column focusLength focus

                firstPart =
                    Array.push beforeSuffix before

                secondPart =
                    put afterPrefix after
            in
            Array.append firstPart secondPart


splitStringAt : Int -> String -> ( String, String )
splitStringAt k str =
    let
        n =
            String.length str
    in
    ( String.slice 0 k str, String.slice k n str )


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

        before_ =
            Array.slice 0 pos1.line array

        ( a, b ) =
            Array.get pos1.line array |> Maybe.withDefault "" |> splitStringAt pos1.column

        middle_ =
            Array.slice (pos1.line + 1) pos2.line array

        m =
            Array.length middle_

        ( c, d ) =
            Array.get pos2.line array |> Maybe.withDefault "" |> splitStringAt (pos2.column + 1)

        after_ =
            Array.slice (pos2.line + 1) n array
    in
    { before = Array.push a before_
    , middle = Array.push c (put b middle_)
    , after = put d after_
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


put : String -> Array String -> Array String
put str array =
    Array.append (Array.fromList [ str ]) array


join : StringZipper -> Array String
join { before, middle, after } =
    let
        lastIndexOfBefore =
            Array.length before - 1

        before_ =
            Array.slice 0 lastIndexOfBefore before

        lastLineOfBefore =
            Array.get lastIndexOfBefore before |> Maybe.withDefault ""

        after_ =
            Array.slice 1 (Array.length after) after

        firstLineOfAfter =
            Array.get 0 after |> Maybe.withDefault ""

        newMiddleLine =
            lastLineOfBefore ++ firstLineOfAfter
    in
    Array.append before_ (put newMiddleLine after_)
