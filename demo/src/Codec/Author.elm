module Codec.Author exposing
    ( decodeAuthor
    , encodeAuthor
    , encodeSignUpInfo
    , test
    , testAuthor
    )

import Author exposing (Author)
import Json.Decode as D exposing (Decoder, bool, int, list, nullable, string)
import Json.Decode.Pipeline as JP exposing (required)
import Json.Encode as Encode
import Time


encodeSignUpInfo userName passwordHash =
    Encode.object
        [ ( "userName", Encode.string userName )
        , ( "passwordHash", Encode.string passwordHash )
        ]


encodeAuthor : Author -> Encode.Value
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


decodeAuthor : Decoder Author
decodeAuthor =
    D.succeed Author
        |> required "name" string
        |> required "userName" string
        |> required "id" string
        |> required "email" string
        |> required "passwordHash" string
        |> required "dateCreated" (int |> D.map Time.millisToPosix)
        |> required "dateModified" (int |> D.map Time.millisToPosix)


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
    case D.decodeValue decodeAuthor <| encodeAuthor testAuthor of
        Ok rec ->
            Just <| rec == testAuthor

        Err _ ->
            Nothing
