import {DocumentRecord, Document} from "../document.ts";
import {manifest, writeManifest} from "../manifest.ts";
import {writeDocument} from "../file.ts"

const hasSameFileName = (a: DocumentRecord, b: DocumentRecord) => a.fileName == b.fileName;

const hasSameId = (a: DocumentRecord, b: DocumentRecord) => a.id == b.id;

const isNotPresent = (d: DocumentRecord, manifest_: Array<DocumentRecord>) =>
  manifest_.filter((r) => hasSameId(r, d)).length == 0;

export const updateDocRecord = (sourceDocRecord: DocumentRecord, targetDocRecord: DocumentRecord) =>
  {
   if (sourceDocRecord.id == targetDocRecord.id)  {
        sourceDocRecord
     } else {
        targetDocRecord
     }
   }

// Add a new document
export const updateDocument = async ({
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
    console.log("SOURCE", sourceDoc)
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
