// OUTSIDE

app.ports.infoForOutside.subscribe(msg => {

    console.log("app.ports.infoForOutside")

    switch(msg.tag) {

        case "AskForClipBoard":
            console.log("AskForClipBoard")

            navigator.clipboard.readText()
              .then(text => {
                console.log('Clipboard (outside):', text);
                app.ports.infoForElm.send({tag: "GotClipboard", data:  text})
              })
              .catch(err => {
                console.error('Failed to read clipboard: ', err);
              });

             break;

        case "WriteToClipboard":
            console.log("WriteToClipboard", JSON.stringify(msg.data))

            navigator.permissions.query({name: "clipboard-write"}).then(result => {
              if (result.state == "granted" || result.state == "prompt") {
                updateClipboard(JSON.stringify(msg.data))
              }
            });


             break;

         case "Highlight":

           console.log("Highlight", msg.data)
           var id = "#".concat(msg.data.id)
           var lastId = msg.data.lastId
           console.log("Highlight (id, lastId)", id, lastId)

           var element = document.querySelector(id)
           if (element != null) {
                 element.classList.add("highlight")
           } else {
                 console.log("Add: could not find id", id)
           }

           var lastElement = document.querySelector(lastId)
           if (lastElement != null) {
                 lastElement.classList.remove("highlight")
           } else {
                 console.log("Remove: could not find last id",lastId)
           }

           break;

    }

    function updateClipboard(newClip) {
      navigator.clipboard.writeText(newClip).then(function() {
        console.log("Wrote to clipboard");
      }, function() {
        console.log ("Clipboard write failed");
      });
    }

})


