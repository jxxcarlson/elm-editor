module Index exposing (extensionBlock, get, testStr, view)

import Element exposing (Element, height, paddingXY, px, spacing, width)
import Element.Background as Background
import Element.Font as Font
import Helper.Common
import Parser.Advanced exposing (..)
import Types exposing (HandleIndex(..), Msg(..))
import View.Widget as Widget


type alias Parser a =
    Parser.Advanced.Parser Context Problem a


type Problem
    = Expecting String


type Context
    = Definition String
    | List
    | Record


testStr =
    """
# Index test

## Subsection

@@index
jxxcarlson.TUG_talk-2c8b-4072.md
jxxcarlson.extended_markdown-cfeb-49bf.md
jxxcarlson.test-3f7d-483d.tex


"""


view : Float -> String -> String -> List String -> Element Msg
view height_ userName currentFileName list =
    Element.column
        [ width (px 500)
        , height (px <| round <| Helper.Common.windowHeight height_ + 28)
        , paddingXY 30 30
        , Background.color (Element.rgba 1.0 0.75 0.75 0.8)
        , spacing 16
        ]
        (closePopup "Index" :: List.map (viewFileName userName currentFileName) list)


closePopup title =
    Element.row [ width (px 450) ] [ Element.text title, Element.el [ Element.alignRight ] Widget.closePopupButton ]


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
        (GetDocument UseIndex fileName)
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
