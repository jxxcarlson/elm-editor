module UuidHelper exposing (getRandomNumber, handleResponseFromRandomDotOrg)

import Http
import Random
import Types exposing (Model, Msg(..))


getRandomNumber : Cmd Msg
getRandomNumber =
    Http.get
        { url = randomNumberUrl 9
        , expect = Http.expectString GotAtmosphericRandomNumber
        }


{-| maxDigits < 10
-}
randomNumberUrl : Int -> String
randomNumberUrl maxDigits =
    let
        maxNumber =
            10 ^ maxDigits

        prefix =
            "https://www.random.org/integers/?num=1&min=1&max="

        suffix =
            "&col=1&base=10&format=plain&rnd=new"
    in
    prefix ++ String.fromInt maxNumber ++ suffix


handleResponseFromRandomDotOrg : Model -> Result error String -> Model
handleResponseFromRandomDotOrg model result =
    case result of
        Ok str ->
            case String.toInt (String.trim str) of
                Nothing ->
                    model

                Just rn ->
                    let
                        newRandomSeed =
                            Random.initialSeed rn
                    in
                    { model
                        | randomAtmosphericInt = Just rn
                        , randomSeed = newRandomSeed
                    }

        Err _ ->
            model
