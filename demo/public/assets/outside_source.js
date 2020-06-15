
const {readTextFile, writeTextFile } = require('./api/index.cjs.min.js')

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

           var manifest = getManifest()
           console.log("Manifest", manifest)

           // app.ports.infoForElm.send({tag: "GotFileList", data:  fileList})

           break;

        case "AskForFile":
            var fileName = msg.data
            var file = getFileFromLocalStorage(fileName)
            app.ports.infoForElm.send({tag: "GotFile", data: file})

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
               var key = msg.data.id
               var document = msg.data
               localStorage.setItem(key, JSON.stringify(document));
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

      const path ='/Users/jxxcarlson/Documents/mudocs'

      return readTextFile(path,  {}).then(value => console.log(value))
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
