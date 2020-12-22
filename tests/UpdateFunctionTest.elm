module UpdateFunctionTest exposing (ex1, stringFromArray, suite)


import Array exposing (Array)
import EditorMsg exposing (Selection(..))
import Expect
import Test exposing (Test, describe, test)
import Update.Line as UL


ex1 : Array String
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
                        |> UL.breakLineBefore 30
                        |> Expect.equal ( "aaa bbb", Nothing )
            , test "breakStringAt, two words" <|
                \_ ->
                    "aaa bbb"
                        |> UL.breakLineBefore 4
                        |> Expect.equal ( "aaa", Just "bbb" )
            , test "breakStringAt, three words" <|
                \_ ->
                    "aaa bbb ccc"
                        |> UL.breakLineBefore 7
                        |> Expect.equal ( "aaa ", Just "bbb ccc" )
            , test "breakStringAt, three words, extra space" <|
                \_ ->
                    "aaa  bbb ccc"
                        |> UL.breakLineBefore 7
                        |> Expect.equal ( "aaa  ", Just "bbb ccc" )
            , test "breakStringAfter (1))" <|
                \_ ->
                    "aaa bbb ccc"
                        |> UL.breakLineAfter 2
                        |> Expect.equal ( "aaa ", Just "bbb ccc" )
            ]
        ]
