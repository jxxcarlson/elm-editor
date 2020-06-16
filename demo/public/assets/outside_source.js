
const {readTextFile, writeFile } = require('./api/fs/index.cjs.min.js')

const { load, safeDump } = require('js-yaml')

const docPath = '/Users/jxxcarlson/Documents/mudocs'

   /// GET FILE

const fetchDocumentByFileName = (fileName) => {

  const manifestPath = docPath + '/manifest.yaml'
  const filePath = docPath + '/' + fileName

  console.log("filePath: ", filePath)

  const getMetadata = (fileName, manifest) => manifest.filter(r => r.fileName == fileName)[0]

  const sendFile = (str, metadata) => app.ports.infoForElm.send({tag: "GotFile", data: merge(str, metadata)})

  const merge = (str, metadata) => ({ fileName: metadata.fileName, id: metadata.id, content: str})

  return readTextFile(manifestPath,  {})
     .then(value => load(value))
     .then(manifest => getMetadata(fileName, manifest))
     .then(metadata => readTextFile(filePath,  {}).then(str => sendFile(str, metadata)))

}

console.log("Im OK!")

app.ports.infoForOutside.subscribe(msg => {

    console.log("OUTSIDE")

    switch(msg.tag) {

        case "AskForClipBoard":
            console.log("AskForClipBoard")
            navigator.clipboard.readText()
              .then(text => {

                app.ports.infoForElm.send({tag: "GotClipboard", data:  text})
              })
              .catch(err => {
                console.error('!JS! Failed to read clipboard: ', err);
              });

             break;

        case "AskForFileList":

           getManifest()

           break;

        case "AskForFile":

            console.log("AskForFile")

            var fileName = msg.data

            console.log("File name", fileName)

            fetchDocumentByFileName(fileName)

           break;

        case "DeleteFileFromLocalStorage":

            localStorage.removeItem(msg.data);
            var fileList = filesInLocalStorage()
            app.ports.infoForElm.send({tag: "GotFileList", data:  fileList})

           break;

        case "WriteToClipboard":
            console.log("GotClipboard")
            navigator.permissions.query({name: "clipboard-write"}).then(result => {
              if (result.state == "granted" || result.state == "prompt") {
                updateClipboard(JSON.stringify(msg.data))
              }
            });


             break;

          case "WriteFile":

              console.log("Here is WriteFile")

              var document = msg.data

              console.log("DOC", document.fileName)

              writeFile_(document)

               break;

         case "Highlight":

           var id = "#".concat(msg.data.id)
           var lastId = msg.data.lastId

           var element = document.querySelector(id)
           if (element != null) {
                 element.classList.add("highlight")
           } else {
                 console.log("!JS! Add: could not find id", id)
           }

           var lastElement = document.querySelector(lastId)
           if (lastElement != null) {
                 lastElement.classList.remove("highlight")
           } else {
                 console.log("!JS! Remove: could not find last id",lastId)
           }

           break;

    }

    function getManifest() {

      const path = docPath + '/manifest.yaml'

      const sendManifest = (value) => app.ports.infoForElm.send({tag: "GotFileList", data:  load(value)})

      return readTextFile(path,  {}).then(value => sendManifest(value))
    }

    function writeFile_(document) {

        const pathToFile = docPath + '/' + document.fileName

        console.log("Writing file: ", document.fileName)

        writeFile({file: pathToFile, contents: document.content})
    }

/**
 * writes a text file
 *
 * @param {Object} file
 * @param {String} file.path path of the file
 * @param {String} file.contents contents of the file
 * @param {Object} [options] configuration object
 * @param {BaseDirectory} [options.dir] base directory
 * @return {Promise<void>}

function writeFile (file, options = {}) {
  return tauri.writeFile(file, options)
}
**/

    /// END GET FILE

    function getFileFromLocalStorage(fileName) {
        return JSON.parse(localStorage.getItem(fileName))
    }

    function updateClipboard(newClip) {
      console.log("updateClipboard")
      navigator.clipboard.writeText(newClip).then(function() {
      }, function() {
        console.log ("!JS! Clipboard write failed");
      });
    }

})
