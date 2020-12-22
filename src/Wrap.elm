module Wrap exposing (WrapParams, runFSM, stringArray)

import Array exposing (Array)
import Dict exposing (Dict)
import EditorMsg exposing (WrapOption(..))
import Paragraph


{-| Wrap text preserving paragraph structure and code blocks
-}
stringArray : WrapParams -> Array String -> Array String
stringArray wrapParams stringArray_ =
    Array.push "\n" stringArray_
        |> Array.toList
        |> runFSM
        |> List.filter (\( _, s ) -> s /= "")
        |> List.map (wrapParagraph wrapParams >> String.lines >> appendBlankLine)
        |> List.concat
        |> Array.fromList
        |> (\a -> Array.slice 0 (Array.length a - 1) a)


appendBlankLine : List String -> List String
appendBlankLine list =
    list ++ [ "" ]


{-| Code for wrapping text. This needs more thought/work.
-}
type alias WrapParams =
    { maximumWidth : Int
    , optimalWidth : Int
    , stringWidth : String -> Int
    }



--
--{-| Wrap text preserving paragraph structure and code blocks
---}
--paragraphs : WrapParams -> String -> String
--paragraphs wrapParams str =
--    str
--        ++ "\n"
--        |> runFSM
--        |> List.filter (\( t, s ) -> s /= "")
--        |> List.map (wrapParagraph wrapParams >> String.trim)
--        |> String.join "\n\n"
--


{-| Wrap text in paragraph if it is of ParagraphType,
but not if it is code or block
-}
wrapParagraph : WrapParams -> ( ParagraphType, String ) -> String
wrapParagraph wrapParams ( paragraphType, str ) =
    case paragraphType of
        TextParagraph ->
            Paragraph.lines wrapParams str |> String.join "\n"

        CodeParagraph ->
            str

        BlockParagraph ->
            str


{-| Run a finite-state machine that gathers logical paragraphs
into a list of tuples ( ParagraphType, String ) where the
first component classifies the type of paragraph (as ParagraphType
or CodeType
-}
runFSM : List String -> List ( ParagraphType, String )
runFSM lines =
    let
        initialData =
            ( Start, { currentParagraph = [], paragraphList = [], tick = 0 } )
    in
    List.foldl nextState initialData lines
        |> Tuple.second
        |> .paragraphList
        |> List.reverse


{-| Then next-state function for the finite-state machine.
-}
nextState : String -> ( State, Data ) -> ( State, Data )
nextState line ( state, data ) =
    let
        ( newState, action ) =
            nextStateAndAction line state
    in
    ( newState, action line data )


{-| A dictionary of functions which carry out the actions
of the finite-state machine.
-}
opDict : Dict String (String -> Data -> Data)
opDict =
    Dict.fromList
        [ ( "NoOp", \_ d -> d )

        --
        , ( "StartParagraph", \s d -> { d | currentParagraph = [ s ], tick = d.tick + 1 } )
        , ( "AddToParagraph", \s d -> { d | currentParagraph = s :: d.currentParagraph, tick = d.tick + 1 } )
        , ( "EndParagraph", \_ d -> { d | currentParagraph = [], paragraphList = ( TextParagraph, joinLines d.currentParagraph ) :: d.paragraphList } )

        --
        , ( "StartCodeFromBlank", \s d -> { d | currentParagraph = [ s ], paragraphList = ( TextParagraph, joinLines d.currentParagraph ) :: d.paragraphList, tick = d.tick + 1 } )
        , ( "StartCodeFromParagraph", \s d -> { d | currentParagraph = [ s ], paragraphList = ( TextParagraph, joinLines d.currentParagraph ) :: d.paragraphList, tick = d.tick + 1 } )
        , ( "StartCode", \s d -> { d | currentParagraph = [ s ], tick = d.tick + 1 } )
        , ( "AddToCode", \s d -> { d | currentParagraph = s :: d.currentParagraph, tick = d.tick + 1 } )
        , ( "EndCode", \s d -> { d | currentParagraph = [], paragraphList = ( CodeParagraph, joinLinesForCode <| s :: d.currentParagraph ) :: d.paragraphList } )

        --
        , ( "StartBlockFromBlank", \s d -> { d | currentParagraph = [ s ], paragraphList = ( TextParagraph, joinLines d.currentParagraph ) :: d.paragraphList, tick = d.tick + 1 } )
        , ( "StartBlockFromParagraph", \s d -> { d | currentParagraph = [ s ], paragraphList = ( TextParagraph, joinLines d.currentParagraph ) :: d.paragraphList, tick = d.tick + 1 } )
        , ( "StartBlock", \s d -> { d | currentParagraph = [ s ], tick = d.tick + 1 } )
        , ( "AddToBlock", \s d -> { d | currentParagraph = s :: d.currentParagraph, tick = d.tick + 1 } )
        , ( "EndBlock", \s d -> { d | currentParagraph = [], paragraphList = ( BlockParagraph, joinLinesForCode <| s :: d.currentParagraph ) :: d.paragraphList } )
        ]


{-| Look up the FSM function given its name.
-}
op : String -> (String -> Data -> Data)
op opName =
    Dict.get opName opDict |> Maybe.withDefault (\_ d -> d)


{-| Join the elements of a string lists with spaces.
-}
joinLines : List String -> String
joinLines list =
    list
        |> List.reverse
        |> List.filter (\s -> s /= "")
        |> String.join " "


{-| Join the elements of a string lists with newlines.
-}
joinLinesForCode : List String -> String
joinLinesForCode list =
    list
        |> List.reverse
        |> String.join "\n"


{-| Define the Finite State Machine
-}
nextStateAndAction : String -> State -> ( State, String -> Data -> Data )
nextStateAndAction line state =
    case ( state, classifyLine line ) of
        ( InParagraph, Text ) ->
            ( InParagraph, op "AddToParagraph" )

        ( InParagraph, Blank ) ->
            ( InBlank, op "EndParagraph" )

        ( InParagraph, CodeDelimiter ) ->
            ( InCode, op "StartCodeFromParagraph" )

        ( InBlank, Blank ) ->
            ( InBlank, op "EndParagraph" )

        ( InBlank, Text ) ->
            ( InParagraph, op "StartParagraph" )

        ( InBlank, CodeDelimiter ) ->
            ( InCode, op "StartCodeFromBlank" )

        ( Start, Text ) ->
            ( InParagraph, op "StartParagraph" )

        ( Start, CodeDelimiter ) ->
            ( InCode, op "StartCode" )

        ( Start, Blank ) ->
            ( Start, op "NoOp" )

        ( InCode, CodeDelimiter ) ->
            ( Start, op "EndCode" )

        ( InCode, Blank ) ->
            ( InCode, op "AddToCode" )

        ( InCode, Text ) ->
            ( InCode, op "AddToCode" )

        ( InBlank, BeginBlock ) ->
            ( InBlock, op "StartBlockFromBlank" )

        ( InParagraph, BeginBlock ) ->
            ( InBlock, op "StartBlockFromParagraph" )

        ( Start, BeginBlock ) ->
            ( InBlock, op "StartBlock" )

        ( InBlock, EndBlock ) ->
            ( Start, op "EndBlock" )

        ( InBlock, Blank ) ->
            ( InBlock, op "AddToBlock" )

        ( InBlock, Text ) ->
            ( InBlock, op "AddToBlock" )

        ( _, _ ) ->
            ( Start, op "NoOp" )


type State
    = Start
    | InParagraph
    | InBlank
    | InCode
    | InBlock


type LineType
    = Blank
    | Text
    | CodeDelimiter
    | BeginBlock
    | EndBlock


type ParagraphType
    = TextParagraph
    | CodeParagraph
    | BlockParagraph


{-| Classify a line as Blank | CodeDelimiter or Text
-}
classifyLine : String -> LineType
classifyLine str =
    let
        prefix =
            String.trimLeft str
    in
    if prefix == "" then
        Blank

    else if String.left 3 prefix == "```" then
        CodeDelimiter

    else if String.left 2 prefix == "$$" then
        CodeDelimiter
        -- haha

    else if String.left 6 prefix == "\\begin" then
        BeginBlock

    else if String.left 4 prefix == "\\end" then
        EndBlock

    else
        Text


{-| The data structure on which the finite-state machine operates.
-}
type alias Data =
    { currentParagraph : List String
    , paragraphList : List ( ParagraphType, String )
    , tick : Int
    }
