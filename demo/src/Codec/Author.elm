module Codec.Author exposing
    ( decodeAuthorWithPasswordHash
    , decodeAuthorization
    , decodeSigninReply
    , encodeAuthor
    , encodeSignUpInfo
    , test
    , testAuthor
    )

import Author exposing (Author, AuthorWithPasswordHash)
import Json.Decode as D exposing (Decoder, bool, int, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Time
import Types exposing (Authorization(..))


encodeSignUpInfo : String -> String -> Encode.Value
encodeSignUpInfo userName passwordHash =
    Encode.object
        [ ( "userName", Encode.string userName )
        , ( "passwordHash", Encode.string passwordHash )
        ]


encodeAuthor : AuthorWithPasswordHash -> Encode.Value
encodeAuthor author =
    Encode.object
        [ ( "name", Encode.string author.name )
        , ( "userName", Encode.string author.userName )
        , ( "id", Encode.string author.id )
        , ( "email", Encode.string author.email )
        , ( "passwordHash", Encode.string author.passwordHash )
        , ( "dateCreated", Encode.int (Time.posixToMillis author.dateModified) )
        , ( "dateModified", Encode.int (Time.posixToMillis author.dateModified) )
        ]


decodeAuthorWithPasswordHash : Decoder AuthorWithPasswordHash
decodeAuthorWithPasswordHash =
    D.succeed AuthorWithPasswordHash
        |> required "name" string
        |> required "userName" string
        |> required "id" string
        |> required "email" string
        |> required "passwordHash" string
        |> required "dateCreated" (int |> D.map Time.millisToPosix)
        |> required "dateModified" (int |> D.map Time.millisToPosix)


decodeAuthorization : Decoder Authorization
decodeAuthorization =
    D.oneOf [ decodeSigninReply |> D.map B, decodeAuthor |> D.map A ]


decodeAuthor : Decoder Author
decodeAuthor =
    D.succeed Author
        |> required "name" string
        |> required "userName" string
        |> required "id" string
        |> required "email" string
        |> required "dateCreated" (int |> D.map Time.millisToPosix)
        |> required "dateModified" (int |> D.map Time.millisToPosix)


decodeSigninReply : Decoder Bool
decodeSigninReply =
    D.succeed identity
        |> required "authorized" bool


testAuthor : AuthorWithPasswordHash
testAuthor =
    { name = "Joan Doe"
    , userName = "jdoe"
    , id = "difuosdmv"
    , email = "jdoe@foo.io"
    , passwordHash = "&^dhfd"
    , dateCreated = Time.millisToPosix 0
    , dateModified = Time.millisToPosix 0
    }


{-| If the encoder and decoder are functioning as they should, then

    > test
    --> Just True

-}
test : Maybe Bool
test =
    case D.decodeValue decodeAuthorWithPasswordHash <| encodeAuthor testAuthor of
        Ok rec ->
            Just <| rec == testAuthor

        Err _ ->
            Nothing
