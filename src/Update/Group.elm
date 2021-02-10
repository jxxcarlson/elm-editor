module Update.Group exposing (groupRange)

import Array exposing (Array)
import EditorMsg exposing (Position)
import Maybe.Extra


type Group
    = None
    | Word
    | NonWord


type Direction
    = Forward
    | Backward


{-| If the position is in the middle or on the edge of a group, the edges of the
group are returned. Otherwise `Nothing` is returned.
-}
groupRange : Position -> Array String -> Maybe ( Int, Int )
groupRange { line, column } strArray =
    Array.get line strArray
        |> Maybe.andThen
            (\text ->
                let
                    chars : ( Maybe Char, Maybe Char, Maybe Char )
                    chars =
                        charsAround column text

                    range : (Char -> Bool) -> Maybe ( Int, Int )
                    range pred =
                        case tuple3CharsPred pred chars of
                            ( True, True, True ) ->
                                Just
                                    ( groupStart column text + 1
                                    , groupEnd column text - 1
                                    )

                            ( False, True, True ) ->
                                Just
                                    ( column
                                    , groupEnd column text - 1
                                    )

                            ( True, True, False ) ->
                                Just
                                    ( groupStart column text + 1
                                    , column + 1
                                    )

                            ( True, False, _ ) ->
                                Just
                                    ( groupStart column text + 1
                                    , column
                                    )

                            ( False, True, False ) ->
                                Just
                                    ( column, column + 1 )

                            _ ->
                                Nothing
                in
                range isWordChar
                    |> Maybe.Extra.orElseLazy (\() -> range isNonWordChar)
            )


charsAround : Int -> String -> ( Maybe Char, Maybe Char, Maybe Char )
charsAround index string =
    ( stringCharAt (index - 1) string
    , stringCharAt index string
    , stringCharAt (index + 1) string
    )


stringCharAt : Int -> String -> Maybe Char
stringCharAt index string =
    String.slice index (index + 1) string
        |> String.uncons
        |> Maybe.map Tuple.first


tuple3MapAll : (a -> b) -> ( a, a, a ) -> ( b, b, b )
tuple3MapAll fn ( a1, a2, a3 ) =
    ( fn a1, fn a2, fn a3 )


tuple3CharsPred :
    (Char -> Bool)
    -> ( Maybe Char, Maybe Char, Maybe Char )
    -> ( Bool, Bool, Bool )
tuple3CharsPred pred =
    tuple3MapAll (Maybe.map pred >> Maybe.withDefault False)


{-| Start at the position and move right using the rules of `groupHelp`.
-}
groupEnd : Int -> String -> Int
groupEnd column str =
    groupHelp Forward (String.dropLeft column str) column None


{-| Start at the position and move left using the rules of `groupHelp`.
-}
groupStart : Int -> String -> Int
groupStart column str =
    groupHelp Backward (String.slice 0 column str) column None


{-| Start at the position and move in the direction using the following rules:

  - Skip consecutive whitespace.
  - If the next character is a non-word character, skip consecutive non-word
    characters then stop
  - If the next character is a word character, skip consecutive word characters
    then stop

-}
groupHelp : Direction -> String -> Int -> Group -> Int
groupHelp direction string column group =
    let
        parts =
            case direction of
                Forward ->
                    String.uncons string

                Backward ->
                    String.uncons (String.reverse string)
                        |> Maybe.map (Tuple.mapSecond String.reverse)
    in
    case parts of
        Just ( char, rest ) ->
            let
                nextColumn =
                    case direction of
                        Forward ->
                            column + 1

                        Backward ->
                            max (column - 1) 0

                next =
                    groupHelp
                        direction
                        rest
                        nextColumn
            in
            case group of
                None ->
                    if isWhitespace char then
                        next None

                    else if isNonWordChar char then
                        next NonWord

                    else
                        next Word

                Word ->
                    if not (isWordChar char) then
                        nextColumn

                    else
                        next Word

                NonWord ->
                    if isNonWordChar char then
                        next NonWord

                    else
                        nextColumn

        Nothing ->
            column


isWhitespace : Char -> Bool
isWhitespace =
    String.fromChar >> String.trim >> (==) ""


isNonWordChar : Char -> Bool
isNonWordChar =
    String.fromChar >> (\a -> String.contains a "/\\()\"':,.;<>~!@#$%^&*|+=[]{}`?-…")


isWordChar : Char -> Bool
isWordChar char =
    not (isNonWordChar char) && not (isWhitespace char)
