port module Outside exposing
    ( InfoForElm(..)
    , InfoForOutside(..)
    , decodeFileList
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
    | GotFileList (List String)
    | GotFileContents String


type InfoForOutside
    = AskForClipBoard E.Value
    | WriteToClipBoard String
    | Highlight ( Maybe String, String )
    | WriteFile ( String, String )
    | AskForFileList
    | AskForFile String
    | DeleteFileFromLocalStorage String


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

                "GotFileList" ->
                    case D.decodeValue decodeFileList outsideInfo.data of
                        Ok fileList ->
                            tagger <| GotFileList fileList

                        Err _ ->
                            onError <| "Error getting file list"

                "GotFileContents" ->
                    case D.decodeValue D.string outsideInfo.data of
                        Ok fileContents ->
                            tagger <| GotFileContents fileContents

                        Err _ ->
                            onError <| "Error getting file contents"

                _ ->
                    onError <| "Unexpected info from outside"
        )


sendInfo : InfoForOutside -> Cmd msg
sendInfo info =
    case info of
        AskForClipBoard _ ->
            infoForOutside { tag = "AskForClipBoard", data = E.null }

        WriteToClipBoard str ->
            infoForOutside { tag = "WriteToClipboard", data = E.string str }

        Highlight idPair ->
            infoForOutside { tag = "Highlight", data = encodeSelectedIdData idPair }

        WriteFile ( fileName, fileContents ) ->
            infoForOutside { tag = "WriteFile", data = encodeFile ( fileName, fileContents ) }

        AskForFileList ->
            infoForOutside { tag = "AskForFileList", data = E.null }

        AskForFile fileName ->
            infoForOutside { tag = "AskForFile", data = E.string fileName }

        DeleteFileFromLocalStorage fileName ->
            infoForOutside { tag = "DeleteFileFromLocalStorage", data = E.string fileName }


encodeSelectedIdData : ( Maybe String, String ) -> E.Value
encodeSelectedIdData ( maybeLastId, id ) =
    E.object
        [ ( "lastId", E.string (maybeLastId |> Maybe.withDefault "nonexistent") )
        , ( "id", E.string id )
        ]


encodeFile : ( String, String ) -> E.Value
encodeFile ( fileName, fileContents ) =
    E.object
        [ ( "fileName", E.string fileName )
        , ( "fileContents", E.string fileContents )
        ]



-- DECODERS --


decodeFileList : D.Decoder (List String)
decodeFileList =
    D.list D.string


clipboardDecoder : D.Decoder String
clipboardDecoder =
    --    D.field "data" D.string
    D.string
