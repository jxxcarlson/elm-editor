import {DocumentRecord, Document} from "../document.ts";
import {manifest, writeManifest} from "../manifest.ts";
import {writeDocument} from "../file.ts"

const hasSameFileName = (a: DocumentRecord, b: DocumentRecord) => a.fileName == b.fileName;

const hasSameId = (a: DocumentRecord, b: DocumentRecord) => a.id == b.id;

const isNotPresent = (d: DocumentRecord, manifest_: Array<DocumentRecord>) =>
  manifest_.filter((r) => hasSameId(r, d)).length == 0;


// Add a new document
export const addDocument = async ({
  request,
  response,
}: {
  request: any;
  response: any;
}) => {
  console.log("processing POST request");
  const {
    value : {token, fileName, id, content},
  } = await request.body();
  response.headers.set("Access-Control-Allow-Origin", "*");
  response.headers.append("Access-Control-Allow-Methods", "POST, OPTIONS");
  response.headers.append(
    "Access-Control-Allow-Headers",
    "X-Requested-With, Content-Type, Accept, Origin",
  );

  if (token == "abracadabra") {

    const doc_ = { id: id, fileName: fileName, content: content };
    const docRecord_ = { id: id, fileName: fileName }

    if (isNotPresent(docRecord_, manifest)) {

      manifest.push(doc_);
      writeManifest(manifest)
      writeDocument(doc_)

      console.log("pushing document: " + doc_.fileName);
      response.body = { msg: "OK" };
      response.status = 200;

    } else {
      console.log("duplicate document");
      response.body = { msg: "file already exists" };
      response.status = 200;
    }
  } else {
    response.body = { msg: "Token does not match" };
    response.status = 400;
  }
};
