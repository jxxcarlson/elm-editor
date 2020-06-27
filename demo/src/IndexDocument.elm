module IndexDocument exposing (render)

import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Parser.Advanced exposing (..)
import Render.Types exposing (IndexMsg(..), RenderMsg(..))
import Types exposing (Msg(..))


type alias Parser a =
    Parser.Advanced.Parser Context Problem a


type Problem
    = Expecting String


type Context
    = Definition String
    | List
    | Record


render : String -> String -> String -> Html RenderMsg
render userName currentFileName str =
    case getIndexBlock str of
        Ok fileList ->
            renderBlock userName currentFileName (String.lines fileList)

        Err _ ->
            Html.span [] [ Html.text "Error constructing file list" ]


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


renderBlock : String -> String -> List String -> Html RenderMsg
renderBlock userName currentFileName list =
    Html.div [] (List.map (viewFileName userName currentFileName) list)


viewFileName : String -> String -> String -> Html RenderMsg
viewFileName userName currentFileName fileName =
    Html.button [ HE.onClick (GetDocumentForIndex fileName) ] [ Html.text (prettify userName fileName) ]
        |> Html.map IndexMsg


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
