module UuidHelper exposing
    ( getRandomNumber
    , handleResponseFromRandomDotOrg
    , newUuid
    )

import Http
import Random
import Types exposing (Model, Msg(..))
import UUID


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
                        ( uuidString, seed ) =
                            generate (Random.initialSeed rn)
                    in
                    { model
                        | uuid = uuidString
                        , randomSeed = seed
                    }

        Err _ ->
            model


generate : Random.Seed -> ( String, Random.Seed )
generate randomSeed =
    Random.step UUID.generator randomSeed
        |> (\( u, s ) -> ( UUID.toString u, s ))


newUuid : Model -> Model
newUuid model =
    let
        ( uuid, seed ) =
            generate model.randomSeed
    in
    { model | uuid = uuid, randomSeed = seed }
