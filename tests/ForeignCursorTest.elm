module ForeignCursorTest exposing (suite)

import Expect exposing (Expectation)
import ForeignCursor
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


fc1 =
    { id = "abc", position = { line = 0, column = 0 } }


fc1b =
    { id = "abc", position = { line = 10, column = 10 } }


fc2 =
    { id = "xyz", position = { line = 10, column = 5 } }


fcs =
    []


suite : Test
suite =
    describe "Foreign Cursor"
        [ test "set cursor on empty list" <|
            \_ ->
                []
                    |> ForeignCursor.set fc1
                    |> Expect.equal [ fc1, fc2 ]
        ]
