module Helper.Author exposing (persist, createAuthor, signInAuthor, encrypt, encryptForTransmission, validatePassword, validateSignUpInfo, validateChangePassword, passwordsMatch, userNameLongEnough, passwordLongEnough, emailValid)

import Author exposing (AuthorWithPasswordHash)
import Codec.Author
import Codec.Document
import Crypto.HMAC exposing (sha512)
import Http
import Time
import Types exposing (Msg(..))


persist : String -> AuthorWithPasswordHash -> Cmd Msg
persist serverUrl author =
    Http.post
        { url = serverUrl ++ "/authors"
        , body = Http.jsonBody (Codec.Author.encodeAuthor author)
        , expect = Http.expectJson Message Codec.Document.messageDecoder
        }


createAuthor : Time.Posix -> String -> String -> String -> String -> String -> AuthorWithPasswordHash
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
signInAuthor serverUrl userName password =
    Http.post
        { url = serverUrl ++ "/authors/signin"
        , body = Http.jsonBody (Codec.Author.encodeSignUpInfo userName (encryptForTransmission password))
        , expect = Http.expectJson GotSigninReply Codec.Author.decodeAuthorization
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
    if password1 == password2 then
        errorList
    else
        "Passwords don't match" :: errorList


userNameLongEnough : String -> List String -> List String
userNameLongEnough username errorList =
    if String.length username < 6 then
        "Username must have at least six characters" :: errorList
    else
        errorList


passwordLongEnough : String -> List String -> List String
passwordLongEnough password errorList =
    if String.length password < 6 then
            "Password must have at least six characters" :: errorList
    else
        errorList


emailValid : String -> List String -> List String
emailValid email errorList =
    if String.contains "@" email && String.length email > 3 then
        errorList
    else
        "Email is not valid" :: errorList
            
