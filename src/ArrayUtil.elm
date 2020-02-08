module ArrayUtil exposing
    ( Position
    , cut
    , cutOut
    , insert
    , join
    , joinThree
    , paste
    , put
    , replace
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

                before =
                    Array.slice 0 position.line array

                after =
                    Array.slice (position.line + 1) (focusLength - 1) array

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
                            Debug.log "MIDDLE"
                                (Array.get pos1.line array |> Maybe.withDefault "")

                        ( a_, part ) =
                            Debug.log "( a_, part )" <|
                                splitStringAt pos1.column middleLine

                        ( b_, c_ ) =
                            Debug.log "( b_, c_ )" <|
                                splitStringAt (pos2.column - String.length a_ + 1) part

                        before__ =
                            case a_ of
                                "" ->
                                    before_

                                _ ->
                                    Array.push a_ before_

                        after__ =
                            case a_ of
                                "" ->
                                    after_

                                _ ->
                                    put c_ after_
                    in
                    ( before__, Array.fromList [ b_ ], after__ )

                False ->
                    let
                        _ =
                            Debug.log "(P1 P2)" ( pos1, pos2 )

                        firstLine =
                            Array.get pos1.line array |> Maybe.withDefault ""

                        lastLine =
                            Array.get pos2.line array
                                |> Maybe.withDefault ""
                                |> Debug.log "LAST LINE"

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
                            Debug.log "( part_2, c_ )"
                                (splitStringAt (pos2.column + 0) lastLine)

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


put : String -> Array String -> Array String
put str array =
    Array.append (Array.fromList [ str ]) array


join : StringZipper -> ( Array String, Array String )
join z =
    let
        _ =
            Debug.log "JOIN" ( z.before, z.middle, z.after )

        joineEnds =
            Debug.log "DB: joinedEnds" <|
                Array.append z.before z.after

        _ =
            Debug.log "DB: middle" <| z.middle
    in
    ( joineEnds, z.middle )


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
