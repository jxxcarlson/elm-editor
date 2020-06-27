module IndexDocument exposing (render)

import Element
    exposing
        ( Element
        , alignRight
        , column
        , el
        , height
        , paddingXY
        , px
        , row
        , scrollbarY
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Element.Font as Font
import Parser.Advanced exposing (..)
import Types exposing (Msg(..))


type alias Parser a =
    Parser.Advanced.Parser Context Problem a


type Problem
    = Expecting String


type Context
    = Definition String
    | List
    | Record


render : String -> String -> String -> Element Msg
render userName currentFileName str =
    case getIndexBlock str of
        Ok fileList ->
            renderBlock userName currentFileName (String.lines fileList)

        Err _ ->
            Element.el [] (Element.text "Error constructing file list")


{-|

    getIndexBlock "\nho ho ho\n  @@index\none\ntwo\n\nha ha ha!\n\n "
    --> Ok "\none\ntwo"

-}
getIndexBlock : String -> Result (List (DeadEnd Context Problem)) String
getIndexBlock str =
    run extensionBlock str


extensionBlock : Parser String
extensionBlock =
    succeed identity
        |. chompWhile (\c -> c /= '@')
        |. symbol (Token "@@index" (Expecting "expecting '@@' to begin extended block"))
        |= restOfBlock


restOfBlock : Parser String
restOfBlock =
    getChompedString <|
        succeed ()
            |. chompUntil (Token "\n\n" (Expecting "expecting blank line"))


renderBlock : String -> String -> List String -> Element Msg
renderBlock userName currentFileName list =
    Element.column [] (List.map (viewFileName userName currentFileName) list)


viewFileName : String -> String -> String -> Element Msg
viewFileName userName currentFileName fileName =
    let
        bgColor =
            case currentFileName == fileName of
                True ->
                    Background.color (Element.rgba 0.7 0.7 1.0 0.5)

                False ->
                    Background.color (Element.rgba 0 0 0 0)
    in
    Widget.plainButton 350
        (prettify userName fileName)
        (GetDocument fileName)
        [ Font.color (Element.rgb 0 0 0.9), bgColor, Element.padding 2 ]


prettify : String -> String -> String
prettify userName str =
    let
        parts =
            String.split "-" str
    in
    case List.length parts == 3 of
        False ->
            String.replace userName "" str

        True ->
            let
                a =
                    List.take 1 parts
                        |> List.head
                        |> Maybe.withDefault "???"

                b =
                    parts
                        |> List.drop 2
                        |> List.map (String.split ".")
                        |> List.concat
                        |> List.drop 1
                        |> List.head
                        |> Maybe.withDefault "???"
            in
            a ++ "." ++ b |> String.replace userName ""
