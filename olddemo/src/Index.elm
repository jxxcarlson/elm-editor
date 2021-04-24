module Index exposing (extensionBlock, get, testStr, view)

import Element exposing (Element, height, paddingXY, px, spacing, width)
import Element.Background as Background
import Element.Font as Font
import Helper.Common
import Parser.Advanced
    exposing
        ( (|.)
        , (|=)
        , Nestable(..)
        , Parser
        , Step(..)
        , Token(..)
        , Trailing(..)
        , chompUntil
        , chompWhile
        , getChompedString
        , map
        , run
        , succeed
        , symbol
        )
import Types exposing (HandleIndex(..), Msg(..))
import View.Widget as Widget


type alias Parser a =
    Parser.Advanced.Parser String Problem a


type Problem
    = Expecting String


testStr : String
testStr =
    """
# Index test

## Subsection

@@index
jxxcarlson.TUG_talk-2c8b-4072.md
jxxcarlson.extended_markdown-cfeb-49bf.md
jxxcarlson.test-3f7d-483d.tex


"""


view : Float -> String -> String -> String -> List String -> Element Msg
view height_ userName currentFileName indexName list =
    Element.column
        [ width (px 500)
        , height (px <| round <| Helper.Common.windowHeight height_ + 28)
        , paddingXY 30 30
        , Background.color (Element.rgba 1.0 0.75 0.75 0.8)
        , spacing 16
        ]
        (closePopup "Index" indexName :: List.map (viewFileName userName currentFileName) list)


editIndexButton : String -> Element Msg
editIndexButton fileName =
    Widget.plainButton 90
        "edit"
        (GetDocument EditIndex fileName)
        [ Font.color (Element.rgb 0 0 0.9), Element.padding 2 ]


closePopup : String -> String -> Element Msg
closePopup title indexName =
    Element.row [ width (px 450), spacing 24 ] [ Element.text title, editIndexButton indexName, Element.el [ Element.alignRight ] Widget.closePopupButton ]


{-|

    getIndexBlock "\nho ho ho\n  @@index\none\ntwo\n\nha ha ha!\n\n "
    --> Ok "\none\ntwo"

-}
get : String -> List String
get data =
    case run extensionBlock data of
        Ok indexAsString ->
            indexAsString
                |> String.lines
                |> List.filter (\line -> line /= "")

        Err _ ->
            []


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


viewFileName : String -> String -> String -> Element Msg
viewFileName userName currentFileName fileName =
    let
        bgColor =
            if currentFileName == fileName then
                Background.color (Element.rgba 0.7 0.7 1.0 0.5)

            else
                Background.color (Element.rgba 0 0 0 0)
    in
    Widget.plainButton 350
        (prettify userName fileName)
        (GetDocument UseIndex fileName)
        [ Font.color (Element.rgb 0 0 0.9), bgColor, Element.padding 2 ]


prettify : String -> String -> String
prettify userName str =
    let
        parts =
            String.split "-" str
    in
    if List.length parts == 3 then
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

    else
        String.replace userName "" str
