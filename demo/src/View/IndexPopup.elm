module View.IndexPopup exposing (view)

import Element exposing (Element)
import Index
import Types exposing (FileLocation(..), HandleIndex(..), Model, Msg(..), PopupStatus(..), PopupWindow(..))



view : Model -> Element Msg
view model =
    case model.popupStatus of
        PopupClosed ->
            Element.none

        PopupOpen IndexPopup ->
            let
                userName =
                    case model.preferences of
                        Nothing ->
                            "noUserName"

                        Just prefs ->
                            prefs.userName ++ "."
            in
            Index.view model.height userName model.fileName model.indexName model.index

        PopupOpen _ ->
            Element.none

