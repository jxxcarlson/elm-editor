module View.AuthorPopup exposing (..)

import Element
    exposing
        ( Element
        , alignRight
        , column
        , el
        , height
        , paddingXY
        , px
        , row
        , scrollbarY
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Element.Font as Font
import Helper.Common
import Types exposing (Model, Msg(..), PopupStatus(..), PopupWindow(..), SignInMode(..))
import View.Widget as Widget
import Widget.TextField as TextField exposing (LabelPosition(..))


view : Model -> Element Msg
view model =
    case model.signInMode of
        SigningIn ->
            viewSignIn model

        SignedIn ->
            Element.none

        SigningUp ->
            viewSignUp model


viewSignIn : Model -> Element Msg
viewSignIn model =
    case model.popupStatus of
        PopupClosed ->
            Element.none

        PopupOpen AuthorPopup ->
            column
                [ width (px 500)
                , height (px <| round <| Helper.Common.windowHeight model.height + 28)
                , paddingXY 30 30
                , Background.color (Element.rgba 1.0 0.75 0.75 0.8)
                , spacing 16
                ]
                [ titleLine model
                , userNameInput model
                , passwordInput model
                , Widget.signInButton
                ]

        PopupOpen _ ->
            Element.none


viewSignUp : Model -> Element Msg
viewSignUp model =
    case model.popupStatus of
        PopupClosed ->
            Element.none

        PopupOpen AuthorPopup ->
            column
                [ width (px 500)
                , height (px <| round <| Helper.Common.windowHeight model.height + 28)
                , paddingXY 30 30
                , Background.color (Element.rgba 1.0 0.75 0.75 0.8)
                , spacing 16
                ]
                [ titleLine model
                , authorNameInput model
                , userNameInput model
                , emailInput model
                , passwordInput model
                , passwordAgainInput model
                , Widget.createAuthorButton
                ]

        PopupOpen _ ->
            Element.none


titleLine model =
    row [ width (px 450) ] [ text "Author", el [ alignRight ] (Widget.closePopupButton model) ]


authorInput msg text label =
    TextField.make msg text label
        |> TextField.withHeight 30
        |> TextField.withWidth 170
        |> TextField.withLabelWidth 90
        |> TextField.withLabelPosition LabelAbove
        |> TextField.toElement


authorNameInput model =
    authorInput InputAuthorname model.authorName "Name"


userNameInput model =
    authorInput InputUsername model.userName "User Name"


emailInput model =
    authorInput InputEmail model.email "Email"


passwordInput model =
    authorInput InputPassword model.password "Password"


passwordAgainInput model =
    authorInput InputPasswordAgain model.passwordAgain "Password again"
