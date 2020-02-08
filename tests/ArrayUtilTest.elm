module ArrayUtilTest exposing (suite)

import Action
import Array exposing (Array)
import ArrayUtil
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Model exposing (Position, Selection(..))
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
    describe "The ArrayUtil module"
        [ describe "String.reverse"
            [ test "Cut a single line" <|
                \_ ->
                    let
                        result =
                            { before = Array.fromList [ "abcde", "0145" ]
                            , middle = Array.fromList [ "23" ]
                            , after = Array.fromList [ "pqrst" ]
                            }
                    in
                    Array.fromList [ "abcde", "012345", "pqrst" ]
                        |> ArrayUtil.cut (Position 1 2) (Position 1 3)
                        |> Expect.equal result
            , test "Cut several lines" <|
                \_ ->
                    let
                        result =
                            { before = Array.fromList [ "abcde", "01" ]
                            , middle = Array.fromList [ "234", "567" ]
                            , after = Array.fromList [ "89", "pqrst" ]
                            }
                    in
                    Array.fromList [ "abcde", "01234", "56789", "pqrst" ]
                        |> ArrayUtil.cut (Position 1 2) (Position 2 3)
                        |> Expect.equal result
            , test "Cut even more lines" <|
                \_ ->
                    let
                        result =
                            { before = Array.fromList [ "abcde", "01" ]
                            , middle = Array.fromList [ "234", "567" ]
                            , after = Array.fromList [ "89", "aeiou", "pqrst" ]
                            }
                    in
                    Array.fromList [ "abcde", "01234", "56789", "aeiou", "pqrst" ]
                        |> ArrayUtil.cut (Position 1 2) (Position 2 3)
                        |> Expect.equal result
            , test "Cut lines, wider spread" <|
                \_ ->
                    let
                        result =
                            { before = Array.fromList [ "abcde", "01" ]
                            , middle = Array.fromList [ "234", "56789", "aei" ]
                            , after = Array.fromList [ "ou", "pqrst" ]
                            }
                    in
                    Array.fromList [ "abcde", "01234", "56789", "aeiou", "pqrst" ]
                        |> ArrayUtil.cut (Position 1 2) (Position 3 3)
                        |> Expect.equal result
            , test "Cut, trouble" <|
                \_ ->
                    let
                        result =
                            { before = Array.fromList [ "abcde", "034" ]
                            , middle = Array.fromList [ "12" ]
                            , after = Array.fromList [ "pqrst" ]
                            }
                    in
                    Array.fromList [ "abcde", "01234", "pqrst" ]
                        |> ArrayUtil.cut (Position 1 1) (Position 1 2)
                        |> Expect.equal
                            result
            , test "Cut lines (Action), simple (1)" <|
                \_ ->
                    let
                        result =
                            { before = Array.fromList [ "abc" ]
                            , middle = Array.fromList [ "012" ]
                            , after = Array.fromList [ "def" ]
                            }
                    in
                    Array.fromList [ "abc", "012", "def" ]
                        |> ArrayUtil.cut (Position 1 0) (Position 1 2)
                        |> Expect.equal result
            , test "Cut lines (Action), simple (2)" <|
                \_ ->
                    let
                        result =
                            ( Array.fromList [ "abc", "def" ]
                            , Array.fromList [ "012" ]
                            )
                    in
                    Array.fromList [ "abc", "012", "def" ]
                        |> Action.deleteSelection (Selection (Position 1 0) (Position 1 2))
                        |> Expect.equal result
            , test "Cut two lines (Action), simple " <|
                \_ ->
                    let
                        result =
                            { before = Array.fromList [ "abc" ]
                            , middle = Array.fromList [ "012", "345" ]
                            , after = Array.fromList [ "def" ]
                            }
                    in
                    Array.fromList [ "abc", "012", "345", "def" ]
                        |> ArrayUtil.cut (Position 1 0) (Position 2 3)
                        |> Expect.equal result
            , test "Cut parts of two lines (Action), simple " <|
                \_ ->
                    let
                        result =
                            { before = Array.fromList [ "abc", "0" ]
                            , middle = Array.fromList [ "123", "456" ]
                            , after = Array.fromList [ "7", "def" ]
                            }
                    in
                    Array.fromList [ "abc", "0123", "4567", "def" ]
                        |> ArrayUtil.cut (Position 1 1) (Position 2 3)
                        |> Expect.equal result
            , test "Cut lines (Action), wider spread" <|
                \_ ->
                    let
                        result =
                            ( Array.fromList [ "abcde", "01", "ou", "pqrst" ]
                            , Array.fromList [ "234", "56789", "aei" ]
                            )
                    in
                    Array.fromList [ "abcde", "01234", "56789", "aeiou", "pqrst" ]
                        |> Action.deleteSelection (Selection (Position 1 2) (Position 3 3))
                        |> Expect.equal result
            , test "Cut passes rejoin test" <|
                \_ ->
                    let
                        result =
                            ( Array.fromList [ "abcde", "01", "ou", "pqrst" ]
                            , Array.fromList [ "234", "56789", "aei" ]
                            )

                        input =
                            Array.fromList [ "abcde", "01234", "56789", "aeiou", "pqrst" ]

                        output =
                            Array.fromList [ "abcde", "01", "ou", "pqrst" ]
                    in
                    input
                        |> Action.deleteSelection (Selection (Position 1 2) (Position 3 3))
                        |> Tuple.first
                        |> stringFromArray
                        |> Expect.equal (stringFromArray output)
            , test "split" <|
                \_ ->
                    let
                        input =
                            Array.fromList [ "abcdef" ]

                        output =
                            Array.append (Array.fromList [ "abc" ]) (Array.fromList [ "def" ])
                                |> stringFromArray
                    in
                    input
                        |> ArrayUtil.split (Position 1 2)
                        |> Tuple.first
                        |> stringFromArray
                        |> Expect.equal output
            , test "paste" <|
                \_ ->
                    let
                        lines =
                            Array.fromList [ "abcdef", "01234", "pqrst" ]

                        newContent =
                            Array.fromList [ "XYZ" ]

                        output =
                            Array.fromList [ "abcdef", "01", "XYZ", "234", "pqrst" ]
                    in
                    lines
                        |> ArrayUtil.paste (Position 1 2) newContent
                        |> Expect.equal output
            ]
        ]
