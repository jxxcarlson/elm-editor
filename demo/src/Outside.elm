port module Outside exposing
    ( InfoForElm(..)
    , InfoForOutside(..)
    , documentDecoder
    , documentEncoder
    , documentListDecoder
    , encodeMiniFileRecord
    , extendedDocumentEncoder
    , getInfo
    , messageDecoder
    , sendInfo
    )

{-| This module manages all interactions with the external JS-world.
At the moment, there is just one: external copy-paste.
-}

import Document exposing (Document, MiniFileRecord)
import Json.Decode as D exposing (Decoder, bool, int, list, nullable, string)
import Json.Decode.Pipeline as JP exposing (required)
import Json.Encode as Encode


port infoForOutside : GenericOutsideData -> Cmd msg


port infoForElm : (GenericOutsideData -> msg) -> Sub msg


type alias GenericOutsideData =
    { tag : String, data : Encode.Value }


type InfoForElm
    = GotClipboard String
    | GotFileList (List MiniFileRecord)
    | GotFile Document


type InfoForOutside
    = AskForClipBoard Encode.Value
    | WriteToClipBoard String
    | Highlight ( Maybe String, String )
    | WriteFile Document
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
                    case D.decodeValue documentListDecoder outsideInfo.data of
                        Ok fileList ->
                            tagger <| GotFileList fileList

                        Err _ ->
                            onError <| "Error getting file list"

                "GotFile" ->
                    case D.decodeValue documentDecoder outsideInfo.data of
                        Ok file ->
                            tagger <| GotFile file

                        Err _ ->
                            onError <| "Error decoding file from value"

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
            infoForOutside { tag = "WriteFile", data = documentEncoder document }

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


documentListDecoder : D.Decoder (List MiniFileRecord)
documentListDecoder =
    D.list decodeMiniFileRecord


clipboardDecoder : D.Decoder String
clipboardDecoder =
    --    D.field "data" D.string
    D.string


documentDecoder : Decoder Document
documentDecoder =
    D.succeed Document
        |> required "fileName" string
        |> required "id" string
        |> required "content" string


decodeMiniFileRecord : Decoder MiniFileRecord
decodeMiniFileRecord =
    D.succeed MiniFileRecord
        |> required "id" string
        |> required "fileName" string


encodeMiniFileRecord : Document -> Encode.Value
encodeMiniFileRecord document =
    Encode.object
        [ ( "fileName", Encode.string document.fileName )
        , ( "id", Encode.string document.id )
        ]


type alias MessageContainer =
    { msg : String }


messageDecoder : Decoder String
messageDecoder =
    (D.succeed MessageContainer
        |> required "msg" string
    )
        |> D.map .msg



{-
   > doc = { fileName = "foo.md", id = "12.45", content = "whatever"}
   { content = "whatever", fileName = "foo.md", id = "12.45" }
       : { content : String, fileName : String, id : String }

   > val = basicDocumentEncoder doc
   <internals> : E.Value

   > doc2 = D.decodeValue basicDocumentDecoder val
   Ok { content = "whatever", fileName = "foo.md", id = "12.45" }
-}


documentEncoder : Document -> Encode.Value
documentEncoder doc =
    Encode.object
        [ ( "fileName", Encode.string doc.fileName )
        , ( "id", Encode.string doc.id )
        , ( "content", Encode.string doc.content )
        ]


extendedDocumentEncoder : String -> Document -> Encode.Value
extendedDocumentEncoder token doc =
    Encode.object
        [ ( "fileName", Encode.string doc.fileName )
        , ( "id", Encode.string doc.id )
        , ( "content", Encode.string doc.content )
        , ( "token", Encode.string token )
        ]
