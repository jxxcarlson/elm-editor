
const {readTextFile, writeFile, Dir } = require('./api/fs/index.cjs.min.js')

const {open} = require('./api/dialog.cjs.min.js')

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

          case "OpenFileDialog":

              console.log("Here is OpenFileDialog")

              //open({directory: true}).then(val => console.log(val))


              const preferredDirectory = open({directory: true})


              const preferences = readTextFile('.muEditPreferences.yaml', {dir: 11})
                                  .then(str => load(str))

//              preferredDirectory.then(x => console.log("PD", x))
//              preferences.then(x => console.log("PREFS", x))

              const updatePreferences = (s, p) => {
                    return Object.assign(p, {documentDirectory: s})
              }

              preferredDirectory
              .then(pd => preferences.then(pref => updatePreferences(pd, pref)))
              .then(x => console.log("UPDATED: ", x))



              break;

          case "CreateFile":

              console.log("Here is CreateFile")

              var document = msg.data

              console.log("CREATE DOC", document.fileName)

              createFile(document)

              break;

          case "WriteFile":

              console.log("Here is WriteFile")

              var document = msg.data

              console.log("DOC", document.fileName)

              writeFile_(document)

               break;

          case "WriteMetadata":

              var document = msg.data

              console.log("Write metadata: ", document.fileName)

              writeMetadata(document)

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

        writeFile({file: pathToFile, contents: document.content})
    }

    function writeMetadata(document) {

        const pathToManifest = docPath + '/manifest.yaml'

        const metadata = { fileName: document.fileName, id: document.id}

        // s and t are metadata: source and target
        const changeMetadata = (s, t ) =>
           s.id == t.id ?  Object.assign({}, s) : t

        // Update the item in the manifest m with id == s.id with the value s
        const updateManifest = (s, m) => m.map((t) => changeMetadata(s, t))

        readTextFile(pathToManifest,  {})
             .then(value => load(value))
             .then(m => updateManifest(metadata, m))
             .then(m => safeDump(m))
             .then(contents => writeFile({file: pathToManifest, contents: contents}))

        }

    function createFile(document) {

        const metadata = {fileName: document.fileName, id: document.id}

        const pathToManifest = docPath + '/manifest.yaml'

        writeFile_(document)

        const append = (item, array) => {

           array.push(item)

           return array
           }

        readTextFile(pathToManifest,  {})
             .then(value => load(value))
             .then(m => append(metadata, m))
             .then(m => safeDump(m))
             .then(contents => writeFile({file: pathToManifest, contents: contents}))


    }


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
