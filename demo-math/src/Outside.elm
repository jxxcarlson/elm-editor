port module Outside exposing
    ( InfoForElm(..)
    , InfoForOutside(..)
    , getInfo
    , sendInfo
    )

{-| This module manages all interactions with the external JS-world.
At the moment, there is just one: external copy-paste.
-}

import Json.Decode as D exposing (string)
import Json.Encode as Encode


port infoForOutside : GenericOutsideData -> Cmd msg


port infoForElm : (GenericOutsideData -> msg) -> Sub msg


type alias GenericOutsideData =
    { tag : String
    , data : Encode.Value
    }


type InfoForElm
    = GotClipboard String


type InfoForOutside
    = AskForClipBoard Encode.Value
    | WriteToClipBoard String


getInfo : (InfoForElm -> msg) -> (String -> msg) -> Sub msg
getInfo tagger onError =
    infoForElm
        (\outsideInfo ->
            case outsideInfo.tag of
                "GotClipboard" ->
                    case D.decodeValue clipboardDecoder outsideInfo.data of
                        Ok result ->
                            tagger <| GotClipboard result

                        Err _ ->
                            onError <| ""

                _ ->
                    onError <| "Unexpected info from outside"
        )


sendInfo : InfoForOutside -> Cmd msg
sendInfo info =
    case info of
        AskForClipBoard _ ->
            infoForOutside { tag = "AskForClipBoard", data = Encode.null }

        WriteToClipBoard str ->
            infoForOutside { tag = "WriteToClipboard", data = Encode.string str }


encodeSelectedIdData : ( Maybe String, String ) -> Encode.Value
encodeSelectedIdData ( maybeLastId, id ) =
    Encode.object
        [ ( "lastId", Encode.string (maybeLastId |> Maybe.withDefault "nonexistent") )
        , ( "id", Encode.string id )
        ]



-- DECODERS --


clipboardDecoder : D.Decoder String
clipboardDecoder =
    --    D.field "data" D.string
    D.string
