import {Metadata, Document} from "../document.ts";
import {manifest, writeManifest} from "../manifest.ts";
import {writeDocument} from "../file.ts"

const hasSameFileName = (a: Metadata, b: Metadata) => a.fileName == b.fileName;

const hasSameId = (a: Metadata, b: Metadata) => a.id == b.id;

const isNotPresent = (d: Metadata, manifest_: Array<Metadata>) =>
  manifest_.filter((r) => hasSameId(r, d)).length == 0;

const updateDocRecord = (sourceDocRecord: Metadata, targetDocRecord: Metadata) =>
  {
   if (sourceDocRecord.id == targetDocRecord.id)  {
        sourceDocRecord
     } else {
        targetDocRecord
     }
   }



const changeDoc = (s: Metadata, t : Metadata) =>
  s.id == t.id ?  Object.assign({}, s) : t


const newManifest = manifest.map((d:Metadata) => changeDoc(changed, d))



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

    const sourceDoc: Document = { id: id, fileName: fileName, content: content };
    const sourceDocRecord: Metadata = { id: id, fileName: fileName };
    if (isNotPresent(sourceDocRecord, manifest)) {
      manifest.push(sourceDocRecord);
      writeManifest(manifest)
      writeDocument(sourceDoc)
      console.log("added: " + sourceDoc.fileName);
      response.body = { msg: "Added: " + sourceDoc.fileName};
      response.status = 200;
    } else {
      manifest.forEach((d:Metadata) => updateDocRecord(sourceDocRecord, d))
      writeManifest(manifest)
      writeDocument(sourceDoc)
      console.log("updated: " + sourceDoc.fileName);
      response.body = { msg: "Updated: " + sourceDoc.fileName };
      response.status = 200;
    }

};
