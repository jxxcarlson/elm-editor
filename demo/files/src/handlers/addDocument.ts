import {Document} from "../document.ts";
import {documents } from "../documents.ts";


const hasSameFileName = (a: Document, b: Document) => a.fileName == b.fileName;

const isNotPresent = (d: Document, docs: Array<Document>) =>
  docs.filter((doc) => hasSameFileName(doc, d)).length == 0;


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
