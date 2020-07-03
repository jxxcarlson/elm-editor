module Helper.Diff exposing (compareDocuments)

import Diff exposing (Change(..))
import Document exposing (Document)


compareDocuments : Document -> Document -> Document
compareDocuments localDoc remoteDoc =
    { localDoc | content = compare localDoc.content remoteDoc.content }


compare : String -> String -> String
compare a b =
    Diff.diffLines a b
        |> List.map stringValue
        |> String.join "\n"


stringValue : Change String -> String
stringValue change =
    case change of
        Added str ->
            case str == "" of
                True ->
                    str

                False ->
                    "@added[" ++ str ++ "]"

        Removed str ->
            case str == "" of
                True ->
                    str

                False ->
                    "@removed[" ++ str ++ "]"

        NoChange str ->
            str
