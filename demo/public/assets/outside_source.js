/*

i think this would be more modern:

https://developer.mozilla.org/en-US/docs/Web/API/Selection

https://developer.mozilla.org/en-US/docs/Web/API/Window/getSelection

but again, experimental tech
MDN Web Docs
Selection
A Selection object represents the range of text selected
by the user or the current position of the caret.
To obtain a Selection object for examination or
manipulation, call window.getSelection().

MDN Web Docs
Window.getSelection()
The Window.getSelection() method returns a
Selection object representing the range of
text selected by the user or the current
position of the caret.

It is worth noting that currently getSelection()
doesn't work on the content of <textarea>
and <input> elements in Firefox, Edge (Legacy)
and Internet Explorer. HTMLInputElement.setSelectionRange()
or the selectionStart and selectionEnd properties
could be used to work around this.

*/

const {readTextFile, writeFile, Dir } = require('./api/fs/index.cjs.min.js')

const {open} = require('./api/dialog.cjs.min.js')

const { load, safeDump } = require('js-yaml')

const docPath = '/Users/jxxcarlson/Documents/mudocs'

   /// GET FILE

const getPreferences = () => {
   return readTextFile('.muEditPreferences.yaml', {dir: 11}).then(str => load(str))
}

const fetchDocumentByFileName = (fileName) => {

  const getMetadata = (fileName, manifest) => (manifest.filter(r => r.fileName == fileName)[0])

  const sendFile = (str, metadata) => app.ports.infoForElm.send({tag: "GotFile", data: merge(str, metadata)})

  const merge = (str, metadata) => ({ fileName: metadata.fileName, id: metadata.id, content: str})

  const paths = (p) => ({toManifest: (p.documentDirectory + '/manifest.yaml'), toFile: (p.documentDirectory + '/' + fileName )})

  getPreferences()
  .then(p => paths(p))
  .then(paths => (
     readTextFile(paths.toManifest,  {})
    .then(value => load(value))
    .then(manifest => getMetadata(fileName, manifest))
    .then(metadata => readTextFile(paths.toFile,  {}).then(str => sendFile(str, metadata)))
   ))

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

          case "GetPreferences":

               console.log("Getting preferences")

               readTextFile('.muEditPreferences.yaml', {dir: 11})
                    .then(str => load(str))
                    .then(o => app.ports.infoForElm.send({tag: "GotPreferences", data:  o}))

              break;


          case "OpenFileDialog":

              const preferredDirectory = open({directory: true})

              const preferences = readTextFile('.muEditPreferences.yaml', {dir: 11})
                                  .then(str => load(str))

              const updatePreferences = (s, p) => {
                    return Object.assign(p, {documentDirectory: s})
              }

              preferredDirectory
              .then(pd => preferences.then(pref => updatePreferences(pd, pref)))
              .then(pref => safeDump(pref))
              .then(data => writeFile(  {  file: '.muEditPreferences.yaml', contents: data   }, {dir: 11}  ))

              break;

          case "SetUserName":

              var userName = msg.data

              console.log("USER NAME", userName)

              if (userName != null) {

                  const preferences = readTextFile('.muEditPreferences.yaml', {dir: 11})
                                      .then(str => load(str))

                  const updatePreferences = (s, p) => {
                        return Object.assign(p, {userName: s})
                  }

                  preferences.then(pref => updatePreferences(userName, pref))
                  .then(pref => safeDump(pref))
                  .then(data => writeFile(  {  file: '.muEditPreferences.yaml', contents: data   }, {dir: 11}  ))
              }

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

        getPreferences()
        .then(p => writeFile({file: (p.documentDirectory + '/' + document.fileName), contents: document.content}))
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
