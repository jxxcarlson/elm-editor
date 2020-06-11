module Helper.Author exposing (..)

import Author exposing (Author)
import Codec.Author
import Codec.Document
import Crypto.HMAC exposing (sha512)
import Http
import Json.Decode as D
import Time
import Types exposing (Msg(..))


persist : String -> Author -> Cmd Msg
persist serverUrl author =
    Http.post
        { url = serverUrl ++ "/authors"
        , body = Http.jsonBody (Codec.Author.encodeAuthor author)
        , expect = Http.expectJson Message Codec.Document.messageDecoder
        }


createAuthor : Time.Posix -> String -> String -> String -> String -> String -> Author
createAuthor t uuid password name userName email =
    { name = name
    , userName = userName
    , id = uuid
    , email = email
    , passwordHash = encryptForTransmission password
    , dateCreated = t
    , dateModified = t
    }


signInAuthor : String -> String -> String -> Cmd Msg
signInAuthor serverUrl userName passwordHash =
    Http.post
        { url = serverUrl ++ "/authors/signin"
        , body = Http.jsonBody (Codec.Author.encodeSignUpInfo userName passwordHash)
        , expect = Http.expectJson Message Codec.Document.messageDecoder
        }



-- HELPERS


encrypt : String -> String
encrypt str =
    Crypto.HMAC.digest sha512 "YoKO-blah-yada-BM0L#10&%F.7.041-hoH0" str


encryptForTransmission : String -> String
encryptForTransmission str =
    Crypto.HMAC.digest sha512 "mairabaka-&^1-HuM5_go*+!ETA-kiFoOFo7918" str


validatePassword : String -> String -> Bool
validatePassword password encryptedPassword =
    encrypt password == encryptedPassword


validateSignUpInfo : String -> String -> String -> List String
validateSignUpInfo username password passwordAgain =
    []
        |> userNameLongEnough username
        |> passwordLongEnough password
        |> passwordsMatch password passwordAgain


validateChangePassword : String -> String -> List String
validateChangePassword password1 password2 =
    []
        |> passwordsMatch password1 password2
        |> passwordLongEnough password1


passwordsMatch : String -> String -> List String -> List String
passwordsMatch password1 password2 errorList =
    case password1 == password2 of
        True ->
            errorList

        False ->
            "Passwords don't match" :: errorList


userNameLongEnough username errorList =
    case String.length username < 6 of
        True ->
            "Username must have at least six characters" :: errorList

        False ->
            errorList


passwordLongEnough password errorList =
    case String.length password < 6 of
        True ->
            "Password must have at least six characters" :: errorList

        False ->
            errorList


emailValid email errorList =
    case String.contains "@" email && String.length email > 3 of
        False ->
            "Email is not valid" :: errorList

        True ->
            errorList
