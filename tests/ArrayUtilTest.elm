module ArrayUtilTest exposing (suite)

import Action
import Array exposing (Array)
import ArrayUtil
import EditorMsg exposing (Position, Selection(..))
import Expect
import Test exposing (Test, describe, only, test)


stringFromArray : Array String -> String
stringFromArray array =
    array
        |> Array.toList
        |> String.join ""


suite : Test
suite =
    describe "The ArrayUtil module"
        [ describe "String Ops"
            [ test "Dice string" <|
                \_ ->
                    "ABCDEF"
                        |> ArrayUtil.diceStringAt 1 3
                        |> Expect.equal ( "A", "BC", "DEF" )
            ]
        , describe "Array ops"
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
            , test "Cut two lines (Action), simple 3 " <|
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
            , test "Cut parts of two lines (Action), simple 4" <|
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
            , test "Cut lines (Action), wider spread 5" <|
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
                    Array.fromList [ "abcdef" ]
                        |> ArrayUtil.split (Position 0 2)
                        |> Expect.equal ( Array.fromList [ "abc", "def" ], Array.fromList [ "" ] )
            , test "split (2)" <|
                \_ ->
                    Array.fromList [ "abc", "def", "hij" ]
                        |> ArrayUtil.split (Position 1 0)
                        |> Expect.equal ( Array.fromList [ "abc" ], Array.fromList [ "def", "hij" ] )
            , test "paste one line" <|
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
            , test "paste several lines" <|
                \_ ->
                    let
                        lines =
                            Array.fromList [ "abcdef", "01234", "pqrst" ]

                        newContent =
                            Array.fromList [ "XYZ", "U1234U" ]

                        output =
                            Array.fromList [ "abcdef", "01", "XYZ", "U1234U", "234", "pqrst" ]
                    in
                    lines
                        |> ArrayUtil.paste (Position 1 2) newContent
                        |> Expect.equal output
            , test "replace lines, aligned with a line" <|
                \_ ->
                    let
                        lines =
                            Array.fromList [ "abcdef", "01234", "pqrst" ]

                        newContent =
                            Array.fromList [ "XYZ", "U1234U" ]

                        output =
                            Array.fromList [ "abcdef", "XYZ", "U1234U", "pqrst" ]
                    in
                    lines
                        |> ArrayUtil.replaceLines (Position 1 0) (Position 1 4) newContent
                        |> Expect.equal output
            , test "cutString line col1 col2 array" <|
                \_ ->
                    let
                        lines =
                            Array.fromList [ "abcde", "01234", "pqrst" ]

                        output =
                            { before = Array.fromList [ "abcde", "0" ]
                            , middle = Array.fromList [ "12" ]
                            , after = Array.fromList [ "34", "pqrst" ]
                            }
                    in
                    lines
                        |> ArrayUtil.cutString 1 1 2
                        |> Expect.equal output
            , test "replace lines, section within a line" <|
                \_ ->
                    let
                        lines =
                            Array.fromList [ "abcde", "01234", "pqrst" ]

                        newContent =
                            Array.fromList [ "XYZ", "UVW" ]

                        output =
                            Array.fromList [ "abcde", "0", "XYZ", "UVW", "4", "pqrst" ]
                    in
                    lines
                        |> ArrayUtil.replaceLines (Position 1 1) (Position 1 3) newContent
                        |> Expect.equal output
            , test "replace lines, section is a line" <|
                \_ ->
                    let
                        lines =
                            Array.fromList [ "abcde", "01234", "pqrst" ]

                        newContent =
                            Array.fromList [ "XYZ", "UVW" ]

                        output =
                            Array.fromList [ "abcde", "XYZ", "UVW", "pqrst" ]
                    in
                    lines
                        |> ArrayUtil.replaceLines (Position 1 0) (Position 1 4) newContent
                        |> Expect.equal output
            , test "insert line after given index" <|
                \_ ->
                    let
                        lines =
                            Array.fromList [ "AAA", "BBB", "CCC" ]
                    in
                    lines
                        |> ArrayUtil.insertLineAfter 1 "XXX"
                        |> Expect.equal (Array.fromList [ "AAA", "BBB", "XXX", "CCC" ])
            , test "insert line after given index 2" <|
                \_ ->
                    let
                        lines =
                            Array.fromList [ "AAA", "BBB", "CCC" ]
                    in
                    lines
                        |> ArrayUtil.insertLineAfter 1 "XXX"
                        |> Expect.equal (Array.fromList [ "AAA", "BBB", "XXX", "CCC" ])
            ]
        ]
