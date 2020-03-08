module UpdateFunctionTest exposing (ex1, stringFromArray, suite)

import Action
import Array exposing (Array)
import ArrayUtil
import EditorModel exposing (Position, Selection(..))
import Expect exposing (Expectation)
import Function as UF
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


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
            [ test "breakStringAt (no break)" <|
                \_ ->
                    "aaa bbb"
                        |> UF.breakLineBefore 30
                        |> Expect.equal ( "aaa bbb", Nothing )
            , test "breakStringAt, two words" <|
                \_ ->
                    "aaa bbb"
                        |> UF.breakLineBefore 4
                        |> Expect.equal ( "aaa", Just "bbb" )
            , test "breakStringAt, three words" <|
                \_ ->
                    "aaa bbb ccc"
                        |> UF.breakLineBefore 7
                        |> Expect.equal ( "aaa ", Just "bbb ccc" )
            , test "breakStringAt, three words, extra space" <|
                \_ ->
                    "aaa  bbb ccc"
                        |> UF.breakLineBefore 7
                        |> Expect.equal ( "aaa  ", Just "bbb ccc" )
            , test "breakStringAfter (1))" <|
                \_ ->
                    "aaa bbb ccc"
                        |> UF.breakLineAfter 2
                        |> Expect.equal ( "aaa ", Just "bbb ccc" )
            ]
        ]
