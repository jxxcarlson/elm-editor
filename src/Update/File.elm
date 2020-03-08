module Update.File exposing (read, requestMarkdownFile, save)

import EditorMsg exposing (EMsg(..))
import File exposing (File)
import File.Download as Download
import File.Select as Select
import Task



-- FILE I/O


read : File -> Cmd EMsg
read file =
    Task.perform MarkdownLoaded (File.toString file)


requestMarkdownFile : Cmd EMsg
requestMarkdownFile =
    Select.file [ "text/markdown" ] EditorRequestedFile


save : String -> Cmd msg
save markdown =
    Download.string "foo.md" "text/markdown" markdown
