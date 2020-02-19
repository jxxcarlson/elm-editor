port module Outside exposing
    ( InfoForElm(..)
    , InfoForOutside(..)
    , getInfo
    , sendInfo
    )

{-| This module manages all interactions with the external JS-world.
At the moment, there is just one: external copy-paste.
-}

import Json.Decode as D
import Json.Encode as E


port infoForOutside : GenericOutsideData -> Cmd msg


port infoForElm : (GenericOutsideData -> msg) -> Sub msg


type alias GenericOutsideData =
    { tag : String, data : E.Value }


type InfoForElm
    = GotClipboard String


type InfoForOutside
    = AskForClipBoard E.Value
    | WriteToClipBoard String
    | Highlight ( Maybe String, String )


getInfo : (InfoForElm -> msg) -> (String -> msg) -> Sub msg
getInfo tagger onError =
    infoForElm
        (\outsideInfo ->
            case outsideInfo.tag of
                "GotClipboard" ->
                    case D.decodeValue clipboardDecoder outsideInfo.data of
                        Ok result ->
                            tagger <| GotClipboard result

                        Err e ->
                            onError <| ""

                _ ->
                    onError <| "Unexpected info from outside"
        )


sendInfo : InfoForOutside -> Cmd msg
sendInfo info =
    case info of
        AskForClipBoard value ->
            infoForOutside { tag = "AskForClipBoard", data = E.null }

        WriteToClipBoard str ->
            infoForOutside { tag = "WriteToClipboard", data = E.string str }

        Highlight idPair ->
            infoForOutside { tag = "Highlight", data = encodeSelectedIdData idPair }


encodeSelectedIdData : ( Maybe String, String ) -> E.Value
encodeSelectedIdData ( maybeLastId, id ) =
    E.object
        [ ( "lastId", E.string (maybeLastId |> Maybe.withDefault "nonexistent") )
        , ( "id", E.string id )
        ]



-- DECODERS --


clipboardDecoder : D.Decoder String
clipboardDecoder =
    --    D.field "data" D.string
    D.string
