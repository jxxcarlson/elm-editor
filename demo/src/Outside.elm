port module Outside exposing
    ( InfoForElm(..)
    , InfoForOutside(..)
    , getInfo
    , sendInfo
    )

{-| This module manages all interactions with the external JS-world.
At the moment, there is just one: external copy-paste.
-}

import Codec.Document
import Codec.System exposing (Preferences)
import Document exposing (Document, Metadata)
import Json.Decode as D exposing (Decoder, bool, int, list, nullable, string)
import Json.Encode as Encode


port infoForOutside : GenericOutsideData -> Cmd msg


port infoForElm : (GenericOutsideData -> msg) -> Sub msg


type alias GenericOutsideData =
    { tag : String, data : Encode.Value }


type InfoForElm
    = GotClipboard String
    | GotFileList (List Metadata)
    | GotFile Document
    | GotPreferences Preferences


type InfoForOutside
    = AskForClipBoard Encode.Value
    | WriteToClipBoard String
    | Highlight ( Maybe String, String )
    | OpenFileDialog Encode.Value
    | WriteFile Document
    | GetPreferences Encode.Value
    | WriteMetadata Metadata
    | CreateFile Document
    | AskForFileList
    | AskForFile String
    | SetUserName String
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
                    case D.decodeValue Codec.Document.metadataListDecoder outsideInfo.data of
                        Ok fileList ->
                            tagger <| "GotFileList: error"

                        Err e ->
                            onError <| Debug.toString e

                "GotFile" ->
                    case D.decodeValue Codec.Document.documentDecoder outsideInfo.data of
                        Ok file ->
                            tagger <| GotFile file

                        Err _ ->
                            onError <| "Error decoding file from value"

                "GotPreferences" ->
                    case D.decodeValue Codec.System.preferencesDecoder outsideInfo.data of
                        Ok p ->
                            tagger <| GotPreferences p

                        Err _ ->
                            onError <| "Error decoding preferences"

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

        Highlight idPair ->
            infoForOutside { tag = "Highlight", data = encodeSelectedIdData idPair }

        OpenFileDialog _ ->
            infoForOutside { tag = "OpenFileDialog", data = Encode.null }

        SetUserName userName ->
            infoForOutside { tag = "SetUserName", data = Encode.string userName }

        GetPreferences _ ->
            infoForOutside { tag = "GetPreferences", data = Encode.null }

        WriteFile document ->
            infoForOutside { tag = "WriteFile", data = Codec.Document.documentEncoder document }

        WriteMetadata metadata ->
            infoForOutside { tag = "WriteMetadata", data = Codec.Document.metadataEncoder metadata }

        CreateFile document ->
            infoForOutside { tag = "CreateFile", data = Codec.Document.documentEncoder document }

        AskForFileList ->
            infoForOutside { tag = "AskForFileList", data = Encode.null }

        AskForFile fileName ->
            infoForOutside { tag = "AskForFile", data = Encode.string fileName }

        DeleteFileFromLocalStorage fileName ->
            infoForOutside { tag = "DeleteFileFromLocalStorage", data = Encode.string fileName }


encodeSelectedIdData : ( Maybe String, String ) -> Encode.Value
encodeSelectedIdData ( maybeLastId, id ) =
    Encode.object
        [ ( "lastId", Encode.string (maybeLastId |> Maybe.withDefault "nonexistent") )
        , ( "id", Encode.string id )
        ]


encodeFile : ( String, String ) -> Encode.Value
encodeFile ( fileName, fileContents ) =
    Encode.object
        [ ( "fileName", Encode.string fileName )
        , ( "fileContents", Encode.string fileContents )
        ]



-- DECODERS --


clipboardDecoder : D.Decoder String
clipboardDecoder =
    --    D.field "data" D.string
    D.string
