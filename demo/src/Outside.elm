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

import Document exposing (BasicDocument)
import Json.Decode as D exposing (Decoder, bool, int, list, nullable, string)
import Json.Decode.Pipeline as JP exposing (required)
import Json.Encode as Encode


port infoForOutside : GenericOutsideData -> Cmd msg


port infoForElm : (GenericOutsideData -> msg) -> Sub msg


type alias GenericOutsideData =
    { tag : String, data : Encode.Value }


type InfoForElm
    = GotClipboard String
    | GotFileList (List String)
    | GotFileContents String


type InfoForOutside
    = AskForClipBoard Encode.Value
    | WriteToClipBoard String
    | Highlight ( Maybe String, String )
    | WriteFile BasicDocument
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
            infoForOutside { tag = "AskForClipBoard", data = Encode.null }

        WriteToClipBoard str ->
            infoForOutside { tag = "WriteToClipboard", data = Encode.string str }

        Highlight idPair ->
            infoForOutside { tag = "Highlight", data = encodeSelectedIdData idPair }

        WriteFile document ->
            infoForOutside { tag = "WriteFile", data = basicDocumentEncoder document }

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


decodeFileList : D.Decoder (List String)
decodeFileList =
    D.list D.string


clipboardDecoder : D.Decoder String
clipboardDecoder =
    --    D.field "data" D.string
    D.string


basicDocumentDecoder : Decoder BasicDocument
basicDocumentDecoder =
    D.succeed BasicDocument
        |> required "fileName" string
        |> required "id" string
        |> required "content" string


basicDocumentEncoder : BasicDocument -> Encode.Value
basicDocumentEncoder doc =
    Encode.object
        [ ( "fileName", Encode.string doc.fileName )
        , ( "id", Encode.string doc.id )
        , ( "content", Encode.string doc.content )
        ]
