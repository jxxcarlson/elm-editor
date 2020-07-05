/*

NOTE: ls node_modules/tauri/api

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

// IMPORTS
const {readTextFile, removeFile, writeFile, Dir } = require('./api/fs/index.cjs.min.js')

const {open} = require('./api/dialog.cjs.min.js')

const { load, safeDump } = require('js-yaml')

const getPreferences = () => {
   return readTextFile('.muEditPreferences.yaml', {dir: 11}).then(str => load(str) || {})
}

const verifyManifest = (prefDir) =>  (
       readTextFile(prefDir + '/manifest.yaml')
        .catch(reason => writeFile(  {  file: prefDir + '/manifest.yaml', contents: "---\n"   } ))
        .then(prefDir)
       )


const toMetadata = (doc) => (
       { fileName: doc.fileName,
        id: doc.id,
        author: doc.author,
        timeCreated: doc.timeCreated,
        timeUpdated: doc.timeUpdated,
        timeSynced: doc.timeSynced,
        tags: doc.tags,
        categories: doc.categories,
        title: doc.title,
        subtitle: doc.subtitle,
        abstract: doc.abstract,
        belongsTo: doc.belongsTo,
        docType: doc.docType
        }
   )

// FETCH DOCUMENT FROM DISK BY FILENAME, SEND TO ELM
const fetchDocumentByFileName = (fileName) => {

  const getMetadata = (fileName, manifest) => (manifest.filter(r => r.fileName == fileName)[0])

  const sendFile = (str, metadata) => app.ports.infoForElm.send({tag: "GotDocument", data: merge(str, metadata)})

  const merge = (str, metadata) => Object.assign(metadata, {content: str})

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

           console.log("AskForFileList")

           const sendManifest = (value) => app.ports.infoForElm.send({tag: "GotFileList", data:  load(value)})

           // Given the path to the manifest, return it as a string
           const getManifest = (pathToManifest) => readTextFile(pathToManifest,  {})


           // Get the preferences
           getPreferences()
             .then(p => (p.documentDirectory + '/manifest.yaml')) // compute path to the manifest
             .then(pathToManifest => getManifest(pathToManifest)) // get the contents of the manifest
             .then(value => load(value))                          // compute the object representation of the manifest
             .then(value => app.ports.infoForElm.send({tag: "GotFileList", data:  value})) // send it to Elm




           break;

        case "AskForDocument":

            console.log("AskForDocument")

            var fileName = msg.data

            console.log("Document.fileName", fileName)

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

               const verifyManifest2= (prefDir) =>  (
                  readTextFile(prefDir + '/manifest.yaml')
                   .catch(reason => writeFile(  {  file: prefDir + '/manifest.yaml', contents: "---\n"   } ))

                  )

               readTextFile('.muEditPreferences.yaml', {dir: 11})
                    .then(str => load(str))
                    .catch(reason =>
                      writeFile( {file: '.muEditPreferences.yaml', contents: 'dummy: 0\n'},
                        {dir: 11}).then('dummy: 0\n'))
                    .then(o => app.ports.infoForElm.send({tag: "GotPreferences", data:  o}))
                    .catch(reason => writeFile(  {  file: '.muEditPreferences.yaml', contents: "---\ndummy: 0\n"   }, {dir: 11}  ))

              getPreferences()
               .then(prefs => prefs.documentDirectory != null
                    ? verifyManifest2(prefs.documentDirectory)
                    : console.log("Document directory not defined"))

              break;


          case "SetManifest":

              console.log("SetManifest")

              const preferredDirectory = open({directory: true})

              const preferences = readTextFile('.muEditPreferences.yaml', {dir: 11})
                                  .then(str => load(str))

              const updatePreferences = (s, p) => {
                    return Object.assign(p, {documentDirectory: s})
              }

              const verifyManifest = (prefDir) =>  (
                 readTextFile(prefDir + '/manifest.yaml')
                  .catch(reason => writeFile(  {  file: prefDir + '/manifest.yaml', contents: "---\n"   } ))
                  .then(prefDir)
                 )

              preferredDirectory
              .then(prefDir => preferences.then(prefs => updatePreferences(prefDir, prefs)))
              .then(prefs => safeDump(prefs))
              .then(data => writeFile(  {  file: '.muEditPreferences.yaml', contents: data   }, {dir: 11}  ))

              break;

            case "SetDownloadFolder":

                  console.log("SetDownloadFolder")

                  const downloadDirectory = open({directory: true})

                  const preferences_ = readTextFile('.muEditPreferences.yaml', {dir: 11})
                                        .then(str => load(str))

                  const updatePreferences_ = (s, p) => {
                          return Object.assign(p, {downloadDirectory: s})
                      }


                  downloadDirectory
                  .then(prefDir => preferences_.then(prefs => updatePreferences_(prefDir, prefs)))
                  .then(prefs => safeDump(prefs))
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

              var document = msg.data

              getPreferences()
              .then(p => writeFile({file: (p.documentDirectory + '/' + document.fileName), contents: document.content}))

               writeMetadata(document)

            break;

          case "WriteFileToDownloadDirectory":

              var document = msg.data

              getPreferences()
              .then(p => writeFile({file: (p.downloadDirectory + '/' + document.fileName), contents: document.content}))

              break;

          case "DeleteFile":

              var fileName = msg.data
              console.log("DELETE FILE", fileName)

              const deleteDocumentFromManifest = (fileName, pathToManifest) => (
                    readTextFile(pathToManifest,  {})
                   .then(value => load(value))
                   .then(m => m.filter(r => r.fileName != fileName))
                   .then(m => safeDump(m))
                   .then(contents => writeFile({file: pathToManifest, contents: contents}))
                )

              getPreferences()
              .then(p => deleteDocumentFromManifest(fileName, p.documentDirectory + '/manifest.yaml'))

              getPreferences()
              .then(p => removeFile(p.documentDirectory + '/' + fileName.replace('.deleted', '')))

              break;

          case "WriteMetadata":

              var document = msg.data

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

        const sendManifest = (value) => app.ports.infoForElm.send({tag: "GotFileList", data:  load(value)})

        return
          getPreferences()
          .then(p => (p.documentDirectory + '/manifest.yaml'))
          .then(pathToManifest => readTextFile(pathToManifest,  {}).then(value => sendManifest(value)))

       }

    function writeMetadata(document) {

        const metadata = toMetadata(document)
        console.log("Metadata", metadata)


        // s and t are metadata: source and target
        const changeMetadata = (s, t ) =>
           s.id == t.id ?  Object.assign({}, s) : t

        // Update the item in the manifest m with id == s.id with the value s
        const updateManifest = (s, m) => m.map((t) => changeMetadata(s, t))

        const writeMetadata_ = (metadata, pathToManifest) => (
              readTextFile(pathToManifest,  {})
             .then(value => load(value))
             .then(m => updateManifest(metadata, m))
             .then(m => safeDump(m))
             .then(contents => writeFile({file: pathToManifest, contents: contents}))
          )

        getPreferences()
        .then(p => writeMetadata_(metadata, p.documentDirectory + '/manifest.yaml'))

      }

    function createFile(document) {

        const metadata = toMetadata(document)

        getPreferences()
        .then(p => writeFile({file: (p.documentDirectory + '/' + document.fileName), contents: document.content}))

        const append = (item, array) => {

           array.push(item)

           return array
           }

        const createFile_ = (pathToManifest) => (
           readTextFile(pathToManifest,  {})
             .then(value => load(value))
             .then(m => append(metadata, (m || [])))
             .then(m => safeDump(m))
             .then(contents => writeFile({file: pathToManifest, contents: contents}))
           )

        getPreferences()
        .then(p => createFile_(p.documentDirectory + '/manifest.yaml'))
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
