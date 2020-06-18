module Update.User exposing (createAuthor, gotSigninReply)

import Cmd.Extra exposing (withCmd, withNoCmd)
import Helper.Author
import Types exposing (Authorization(..), Model, Msg, PopupStatus(..), SignInMode(..))
import Update.Helper
import UuidHelper


createAuthor : Model -> ( Model, Cmd Msg )
createAuthor model =
    let
        ( uuid, seed ) =
            UuidHelper.generate model.randomSeed

        newAuthor =
            Helper.Author.createAuthor model.currentTime
                uuid
                model.password
                model.authorName
                model.userName
                model.email
    in
    { model | randomSeed = seed }
        |> Update.Helper.postMessage ("Created: " ++ model.userName)
        |> withCmd (Helper.Author.persist model.fileStorageUrl newAuthor)


gotSigninReply : Result error Authorization -> Model -> ( Model, Cmd msg )
gotSigninReply result model =
    case result of
        Ok reply ->
            case reply of
                A author ->
                    { model
                        | currentUser = Just author
                        , popupStatus = PopupClosed
                        , signInMode = SignedIn
                    }
                        |> Update.Helper.postMessage (author.userName ++ " signed in")
                        |> withNoCmd

                B _ ->
                    { model | currentUser = Nothing, signInMode = SigningIn }
                        |> Update.Helper.postMessage "Could not verify user/password"
                        |> withNoCmd

        Err _ ->
            model
                |> Update.Helper.postMessage "Error authenticating user"
                |> withNoCmd
