(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
"use strict";Object.defineProperty(exports,"__esModule",{value:!0});exports.Dir={Audio:1,Cache:2,Config:3,Data:4,LocalData:5,Desktop:6,Document:7,Download:8,Executable:9,Font:10,Home:11,Picture:12,Public:13,Runtime:14,Template:15,Video:16,Resource:17,App:18};

},{}],2:[function(require,module,exports){
"use strict";Object.defineProperty(exports,"__esModule",{value:!0});var e=require("../tauri.cjs.min.js"),r=require("./dir.cjs.min.js");exports.Dir=r.Dir,exports.copyFile=function(r,t,i={}){return e.default.copyFile(r,t,i)},exports.createDir=function(r,t={}){return e.default.createDir(r,t)},exports.readBinaryFile=function(r,t={}){return e.default.readBinaryFile(r,t)},exports.readDir=function(r,t={}){return e.default.readDir(r,t)},exports.readTextFile=function(r,t={}){return e.default.readTextFile(r,t)},exports.removeDir=function(r,t={}){return e.default.removeDir(r,t)},exports.removeFile=function(r,t={}){return e.default.removeFile(r,t)},exports.renameFile=function(r,t,i={}){return e.default.renameFile(r,t,i)},exports.writeFile=function(r,t={}){return e.default.writeFile(r,t)};

},{"../tauri.cjs.min.js":3,"./dir.cjs.min.js":1}],3:[function(require,module,exports){
"use strict";Object.defineProperty(exports,"__esModule",{value:!0});var e=window.tauri;exports.default=e;

},{}],4:[function(require,module,exports){

const {readTextFile, writeTextFile } = require('./api/fs/index.cjs.min.js')

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

      const path ='/Users/jxxcarlson/Documents/mudocs/manifest.yaml'

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

},{"./api/fs/index.cjs.min.js":2}]},{},[4]);
