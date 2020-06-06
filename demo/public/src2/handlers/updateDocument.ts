import {DocumentRecord, Document} from "../document.ts";
import {manifest, writeManifest} from "../manifest.ts";
import {writeDocument} from "../file.ts"

const hasSameFileName = (a: DocumentRecord, b: DocumentRecord) => a.fileName == b.fileName;

const hasSameId = (a: DocumentRecord, b: DocumentRecord) => a.id == b.id;

const isNotPresent = (d: DocumentRecord, manifest_: Array<DocumentRecord>) =>
  manifest_.filter((r) => hasSameId(r, d)).length == 0;

const updateDocRecord = (sourceDocRecord: DocumentRecord, targetDocRecord: DocumentRecord) =>
  {
   if (sourceDocRecord.id == targetDocRecord.id)  {
        sourceDocRecord
     } else {
        targetDocRecord
     }
   }


// interface NumberRec {
//   n: number;
// }
// const changeNumber = (x:NumberRec) => x.n % 2 == 0 ? Object.assign({}, {n: 2*x.n}) : x
//
// console.log(changeNumber({n:1}))
// // --> { n: 1 }
// console.log(changeNumber({n:2}))
// // --> { n: 4 }
//
//
// const numbers = [{n: 1}, {n: 2}, {n: 3}, {n: 4}]
// console.log(numbers)
// // --> [{n: 1}, {n: 2}, {n: 3}, {n: 4}]
// const newNumbers = numbers.map(changeNumber)
// console.log(newNumbers)
// // --> [{n: 1}, {n: 4}, {n: 3}, {n: 8}]


const changeDoc = (s: DocumentRecord, t : DocumentRecord) =>
  s.id == t.id ?  Object.assign({}, s) : t

// console.log("M", manifest)
// const original = {id: "72131ec8-6df5-4797-9069-a2c10f9bb3a6", fileName: "xxx.md"}
// const another = {id: "777", fileName: "hahah.md"}
// const changed = {id: "72131ec8-6df5-4797-9069-a2c10f9bb3a6", fileName: "yyy.md"}
// console.log("REC", changeDoc(changed, original))
// console.log("REC2", changeDoc(changed, another))
//
// const newManifest = manifest.map((d:DocumentRecord) => changeDoc(changed, d))
// console.log("M2", newManifest)
// // manifest = newManifest


// Add a new document
const updateDocument = async ({
  request,
  response,
}: {
  request: any;
  response: any;
}) => {
  const {
    value : {token, fileName, id, content},
  } = await request.body();
  response.headers.set("Access-Control-Allow-Origin", "*");
  response.headers.append("Access-Control-Allow-Methods", "PUT, OPTIONS");
  response.headers.append(
    "Access-Control-Allow-Headers",
    "X-Requested-With, Content-Type, Accept, Origin",
  );

  if (token == "abracadabra") {
    const sourceDoc: Document = { id: id, fileName: fileName, content: content };
    const sourceDocRecord: DocumentRecord = { id: id, fileName: fileName };
    if (isNotPresent(sourceDocRecord, manifest)) {
      manifest.push(sourceDocRecord);
      writeManifest(manifest)
      writeDocument(sourceDoc)
      console.log("added: " + sourceDoc.fileName);
      response.body = { msg: "Added: " + sourceDoc.fileName};
      response.status = 200;
    } else {
      manifest.forEach((d:DocumentRecord) => updateDocRecord(sourceDocRecord, d))
      writeManifest(manifest)
      writeDocument(sourceDoc)
      console.log("updated: " + sourceDoc.fileName);
      response.body = { msg: "Updated: " + sourceDoc.fileName };
      response.status = 200;
    }
  } else {
    response.body = { msg: "Token does not match" };
    response.status = 400;
  }
};
