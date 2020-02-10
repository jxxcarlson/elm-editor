module UpdateFunctionTest exposing (ex1, stringFromArray, suite)

import Action
import Array exposing (Array)
import ArrayUtil
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Model exposing (Position, Selection(..))
import Test exposing (..)
import UpdateFunction as UF


ex1 =
    Array.fromList [ "abcde", "01234", "pqrst" ]


stringFromArray : Array String -> String
stringFromArray array =
    array
        |> Array.toList
        |> String.join ""


suite : Test
suite =
    describe "Update functions"
        [ describe "String rwapping"
            [ only <|
                test "breakStringAt (no break)" <|
                    \_ ->
                        "aaa bbb"
                            |> UF.breakLineBefore 30
                            |> Expect.equal ( "aaa bbb", Nothing )
            , skip <|
                test "breakStringAt, two words" <|
                    \_ ->
                        "aaa bbb"
                            |> UF.breakLineBefore 4
                            |> Expect.equal ( "aaa", Just "bbb" )
            , skip <|
                test "breakStringAt, three words" <|
                    \_ ->
                        "aaa bbb ccc"
                            |> UF.breakLineBefore 7
                            |> Expect.equal ( "aaa ", Just "bbb ccc" )
            , skip <|
                test "breakStringAt, three words, extra space" <|
                    \_ ->
                        "aaa  bbb ccc"
                            |> UF.breakLineBefore 7
                            |> Expect.equal ( "aaa  ", Just "bbb ccc" )
            , only <|
                test "breakStringAfter (1))" <|
                    \_ ->
                        "aaa bbb ccc"
                            |> UF.breakLineAfter 2
                            |> Expect.equal ( "aaa ", Just "bbb ccc" )
            ]
        ]
