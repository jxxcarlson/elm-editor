module Search exposing (do, hits)

import Array exposing (Array)
import EditorModel exposing (EditorModel)
import EditorMsg exposing (Selection(..))
import Position exposing (Position)
import RollingList


{-| Search for str and scroll to first hit. Used internally.
-}
do : String -> EditorModel -> EditorModel
do str model =
    let
        searchResults =
            hits str model.lines
    in
    case List.head searchResults of
        Nothing ->
            { model | searchResults = RollingList.fromList [], searchTerm = str, selection = NoSelection }

        Just ((Selection first _) as selection) ->
            { model
                | cursor = first
                , selection = selection
                , searchResults = RollingList.fromList searchResults
                , searchTerm = str
                , searchResultIndex = 0
            }

        Just _ ->
            { model | searchResults = RollingList.fromList [], searchTerm = str, selection = NoSelection }


{-|

    hits "ab" <| Array.fromList ["about this, we know", "that Babs is the best in the lab", "a stitch in time saves nine"]
    --> [Selection { column = 0, line = 0 } { column = 2, line = 0 },Selection { column = 6, line = 1 } { column = 8, line = 1 },Selection { column = 30, line = 1 } { column = 32, line = 1 }]

-}
hits : String -> Array String -> List Selection
hits key lines =
    let
        keyLen =
            String.length key

        expand : ( Int, List Int ) -> List ( Int, Int )
        expand ( i, list ) =
            list |> List.map (\item -> ( i, item ))

        makePositions : ( Int, Int ) -> Selection
        makePositions ( line, column ) =
            Selection (Position line column) (Position line (column + (keyLen - 1)))
    in
    Array.indexedMap
        (\i line -> ( i, String.indexes key line ))
        lines
        |> Array.map expand
        |> Array.toList
        |> List.concat
        |> List.map makePositions



--
--
--{-|
--
--    positions (5, "This is about our lab.", ["about", "lab"])
--    --> [({ column = 8, line = 5 },{ column = 13, line = 5 }),({ column = 18, line = 5 },{ column = 21, line = 5 })]
--
---}
--positions : ( Int, String, List String ) -> List ( Position, Position )
--positions ( line, source, hits ) =
--    List.map (\hit -> stringIndices hit source) hits
--        |> List.concat
--        |> List.map (\( start, end ) -> ( Position line start, Position line end ))
--
--
--{-|
--
--    stringIndices "ab" "This is about our lab."
--    --> [(8,10),(19,21)] : List ( Int, Int )
--
---}
--stringIndices : String -> String -> List ( Int, Int )
--stringIndices key source =
--    let
--        n =
--            String.length key
--    in
--    String.indices key source
--        |> List.map (\i -> ( i, i + n ))
--
--
--{-|
--
--    matches "ab" "abc, hoorAy, yada, Blab about it"
--    ["abc,","blab","about"] : List String
--
---}
--matches : String -> String -> List Int
--matches key str =
--    str
--        |> String.words
--        |> List.filter (\word -> key == word)
--
--
--{-|
--
--    indexedFilterMap (\i x -> i >= 1 && i <= 3) [0,1,2,3,4,5,6]
--    --> [(1,1),(2,2),(3,3)]
--
---}
--indexedFilterMap : (Int -> a -> Bool) -> List a -> List ( Int, a )
--indexedFilterMap filter list =
--    list
--        |> List.indexedMap (\k item -> ( k, item ))
--        |> List.filter (\( i, item ) -> filter i item)
