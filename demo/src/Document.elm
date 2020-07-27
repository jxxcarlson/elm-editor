module Document exposing
    ( DocType(..)
    , Document
    , Metadata
    , NewDocumentData
    , SyncOperation(..)
    , changeDocType
    , docType
    , docTypeOfString
    , extendFileName
    , extensionOfDocType
    , fileExtension
    , stringOfDocType
    , stringOfSyncOperation
    , syncOperation
    , titleFromFileName
    , toMetadata
    , updateSyncTimes
    )

import Time


type DocType
    = MarkdownDoc
    | MiniLaTeXDoc
    | IndexDoc


type SyncOperation
    = PushDocument
    | PullDocument
    | SyncConflict
    | DocsIdentical
    | NoSyncOp


stringOfSyncOperation : SyncOperation -> String
stringOfSyncOperation syncOp =
    case syncOp of
        PushDocument ->
            "push"

        PullDocument ->
            "pull"

        SyncConflict ->
            "conflict"

        DocsIdentical ->
            "identical"

        NoSyncOp ->
            "noOp"


type alias Document =
    { fileName : String
    , id : String
    , author : String
    , timeCreated : Time.Posix
    , timeUpdated : Time.Posix
    , timeSynced : Maybe Time.Posix
    , tags : List String
    , categories : List String
    , title : String
    , subtitle : String
    , abstract : String
    , belongsTo : String
    , docType : DocType
    , content : String
    }


type alias Metadata =
    { fileName : String
    , id : String
    , author : String
    , timeCreated : Time.Posix
    , timeUpdated : Time.Posix
    , timeSynced : Maybe Time.Posix
    , tags : List String
    , categories : List String
    , title : String
    , subtitle : String
    , abstract : String
    , belongsTo : String
    , docType : DocType
    }


type alias SimpleDocument a =
    { a
        | fileName : String
        , id : String
        , content : String
    }


type alias NewDocumentData =
    SimpleDocument { docType : DocType }


shortId : String -> String
shortId uuid =
    let
        parts_ =
            String.split "-" uuid

        parts =
            parts_ |> List.drop 1 |> List.take 2
    in
    String.join "-" parts


extendFileName : DocType -> String -> String -> String -> String
extendFileName docType_ prefix uuid fileName =
    let
        shortId_ =
            shortId uuid

        ext =
            case docType_ of
                MarkdownDoc ->
                    ".md"

                MiniLaTeXDoc ->
                    ".tex"

                IndexDoc ->
                    ".index"

        removeMDSuffix s =
            if String.right 3 s == ".md" then
                String.dropRight 3 s
            else
                s

        removeTeXSuffix s =
            if String.right 4 s == ".tex" then
                String.dropRight 4 s
            else
                s

        removeIndexSuffix s =
            if String.right 6 s == ".index" then
                String.dropRight 6 s
            else
                s

        fileName_ =
            fileName |> removeMDSuffix |> removeTeXSuffix |> removeIndexSuffix
    in
    case prefix of
        "" ->
            fileName_ ++ "-" ++ shortId_ ++ ext

        _ ->
            prefix ++ "." ++ fileName_ ++ "-" ++ shortId_ ++ ext


toMetadata : Document -> Metadata
toMetadata doc =
    { fileName = doc.fileName
    , id = doc.id
    , author = doc.author
    , timeCreated = doc.timeCreated
    , timeUpdated = doc.timeUpdated
    , timeSynced = doc.timeSynced
    , tags = doc.tags
    , title = doc.title
    , subtitle = doc.subtitle
    , abstract = doc.abstract
    , belongsTo = doc.belongsTo
    , categories = doc.categories
    , docType = doc.docType
    }


changeDocType : DocType -> String -> String
changeDocType docType_ fileName =
    case docType_ of
        MiniLaTeXDoc ->
            titleFromFileName fileName ++ ".tex"

        MarkdownDoc ->
            titleFromFileName fileName ++ ".md"

        IndexDoc ->
            titleFromFileName fileName ++ ".index"


titleFromFileName : String -> String
titleFromFileName fileName =
    fileName
        |> String.split "."
        |> List.reverse
        |> List.drop 1
        |> List.reverse
        |> String.join "."


fileExtension : String -> String
fileExtension str =
    str |> String.split "." |> List.reverse |> List.head |> Maybe.withDefault "txt"


extensionOfDocType : DocType -> String
extensionOfDocType docType_ =
    case docType_ of
        MarkdownDoc ->
            "md"

        MiniLaTeXDoc ->
            "tex"

        IndexDoc ->
            "index"


stringOfDocType : DocType -> String
stringOfDocType docType_ =
    case docType_ of
        MarkdownDoc ->
            "markdown"

        MiniLaTeXDoc ->
            "minilatex"

        IndexDoc ->
            "index"


docType : String -> DocType
docType fileName =
    case fileExtension fileName of
        "md" ->
            MarkdownDoc

        "tex" ->
            MiniLaTeXDoc

        "latex" ->
            MiniLaTeXDoc

        "index" ->
            IndexDoc

        _ ->
            MarkdownDoc


docTypeOfString : String -> DocType
docTypeOfString str =
    case str of
        "markdown" ->
            MarkdownDoc

        "minilatex" ->
            MiniLaTeXDoc

        "index" ->
            IndexDoc

        _ ->
            MarkdownDoc


updateSyncTimes : Time.Posix -> Document -> Document
updateSyncTimes t doc =
    { doc | timeUpdated = t, timeSynced = Just t }


syncOperation : Document -> Document -> SyncOperation
syncOperation localDocument remoteDocument =
    --let
    --    _ =
    --        Debug.log "Local (synced, updated)" ( prettyMaybePosix localDocument.timeSynced, prettyPosix localDocument.timeUpdated )
    --
    --    _ =
    --        Debug.log "Remote (synced, updated)" ( prettyMaybePosix remoteDocument.timeSynced, prettyPosix remoteDocument.timeUpdated )
    --in
    case ( localDocument.timeSynced, remoteDocument.timeSynced ) of
        ( Nothing, _ ) ->
            if localDocument.content == remoteDocument.content then
                DocsIdentical

            else
                SyncConflict

        ( _, Nothing ) ->
            if localDocument.content == remoteDocument.content then
                DocsIdentical

            else
                SyncConflict

        ( Just localSynctime, Just remoteSynctime ) ->
            if localSynctime /= remoteSynctime then
                SyncConflict
                --else if Time.posixToMillis localDocument.timeUpdated == Time.posixToMillis remoteDocument.timeUpdated then
                --    SyncConflict

            else if
                Time.posixToMillis localDocument.timeUpdated
                    > Time.posixToMillis localSynctime
                    && Time.posixToMillis remoteDocument.timeUpdated
                    <= Time.posixToMillis remoteSynctime
            then
                PushDocument

            else if
                Time.posixToMillis remoteDocument.timeUpdated
                    > Time.posixToMillis remoteSynctime
                    && Time.posixToMillis localDocument.timeUpdated
                    <= Time.posixToMillis localSynctime
            then
                PullDocument

            else if
                Time.posixToMillis remoteDocument.timeUpdated
                    > Time.posixToMillis remoteSynctime
                    && Time.posixToMillis localDocument.timeUpdated
                    > Time.posixToMillis localSynctime
            then
                SyncConflict

            else
                NoSyncOp
