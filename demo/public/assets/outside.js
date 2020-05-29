// OUTSIDE

app.ports.infoForOutside.subscribe(msg => {

    console.log("!JS! app.ports.infoForOutside")

    switch(msg.tag) {

        case "AskForClipBoard":
            console.log("!JS!  AskForClipBoard")

            navigator.clipboard.readText()
              .then(text => {
                console.log('!JS! Clipboard (outside):', text);
                app.ports.infoForElm.send({tag: "GotClipboard", data:  text})
              })
              .catch(err => {
                console.error('!JS! Failed to read clipboard: ', err);
              });

             break;

        case "AskForFileList":
           var fileList = filesInLocalStorage()

           console.log("Will send file list", fileList)

           app.ports.infoForElm.send({tag: "GotFileList", data:  fileList})

           break;

        case "AskForFile":
            var fileName = JSON.stringify(msg.data)
            console.log("AskForFile", fileName)
            var fileContents = getFileFromLocalStorage(fileName)
            app.ports.infoForElm.send({tag: "GotFileContents", data: fileContents})

           break;

        case "DeleteFileFromLocalStorage":

            console.log("DeleteFileFromLocalStorage: " + msg.data)
            localStorage.removeItem("file:" + msg.data);
            var fileList = filesInLocalStorage()
            app.ports.infoForElm.send({tag: "GotFileList", data:  fileList})

           break;

        case "WriteToClipboard":
            console.log("!JS!  WriteToClipboard", JSON.stringify(msg.data))

            navigator.permissions.query({name: "clipboard-write"}).then(result => {
              if (result.state == "granted" || result.state == "prompt") {
                updateClipboard(JSON.stringify(msg.data))
              }
            });


             break;

          case "WriteFile":
              console.log("!JS! WriteFile") ;

               var fileName = msg.data.fileName
               var fileContents = msg.data.fileContents

               localStorage.setItem(fileName, fileContents);

               break;

         case "Highlight":

           console.log("!JS! Highlight", msg.data)
           var id = "#".concat(msg.data.id)
           var lastId = msg.data.lastId
           console.log("!JS! Highlight (id, lastId)", id, lastId)

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

    function filesInLocalStorage() {
      var fileList = []
      for (var key in localStorage){
        if (key.indexOf("file:") == 0)  {
             fileList.push(key.replace("file:", "").replace(/\"/g, ""))
          }
      }
      return fileList
    }

    function getFileFromLocalStorage(fileName) {
        var fileName_ = ('file:' + fileName).replace(/\"/g, "")
        console.log("fileName_", fileName_)
        return localStorage.getItem(fileName_);
    }

    function updateClipboard(newClip) {
      navigator.clipboard.writeText(newClip).then(function() {
        console.log("!JS! Wrote to system clipboard");
      }, function() {
        console.log ("!JS! Clipboard write failed");
      });
    }

})


