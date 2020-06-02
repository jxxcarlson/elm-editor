// https://dev.to/kryz/write-a-small-api-using-deno-1cl0

import { Application, Router } from "https://deno.land/x/oak/mod.ts";
import {Document, DocumentRecord, ExtendedDocument, documentOfExtendedDocument} from "./document.ts";
import { documents } from "./documents.ts";
import {getDocuments} from "./handlers/getDocuments.ts"
import {getDocument} from "./handlers/getDocument.ts"

// // Get the current list of documents
// export const getDocuments = ({ response }: { response: any }) => {
//   console.log("file list requested");
//   response.headers.set("Access-Control-Allow-Origin", "*");
//   response.body = documents.map(documentRecordOf);
// };


// WEB SERVER

const env = Deno.env.toObject();
const PORT = env.PORT || 4000;
const HOST = env.HOST || "localhost";

const router = new Router();


const hasSameFileName = (a: Document, b: Document) => a.fileName == b.fileName;

const isNotPresent = (d: Document, docs: Array<Document>) =>
  docs.filter((doc) => hasSameFileName(doc, d)).length == 0;

// function setCORS(res: Response): void {
//  if (!res.headers) {
//    res.headers = new Headers();
//  }
//  res.headers!.append("access-control-allow-origin", "*");
//  res.headers!.append(
//    "access-control-allow-headers",
//    "Origin, X-Requested-With, Content-Type, Accept, Range"
//  );
// }
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
    "X-Requested-With, Content-Type, Accept, Origin, Authorization",
  );

  if (token == "abracadabra") {
    const doc_ = { id: id, fileName: fileName, content: content };
    if (isNotPresent(doc_, documents)) {
      documents.push(doc_);
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

router
  .get("/api/documents", getDocuments)
  .get("/api/document/:fileName", getDocument)
  .post("/api/documents", addDocument);
// .put('/dogs/:name', updateDog)
// .delete('/dogs/:name', removeDog)

const app = new Application();

app.use(router.routes());
app.use(router.allowedMethods());

console.log(`Listening on port ${PORT}...`);

await app.listen(`${HOST}:${PORT}`);
