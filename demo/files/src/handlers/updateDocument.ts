import {Document} from "../document.ts";
import {documents } from "../documents.ts";

const hasSameId = (a: Document, b: Document) => a.id == b.id;

export const updateDoc = (sourceDoc: Document, targetDoc: Document) =>
  {
   if (hasSameId(sourceDoc, targetDoc) == true)  {
       sourceDoc
     } else {
        targetDoc
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
  console.log("processing PUT request");
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
    const sourceDoc = { id: id, fileName: fileName, content: content };
      documents.map((d) => updateDoc(sourceDoc, d))
      console.log("updated: " + sourceDoc.fileName);
      response.body = { msg: "OK" };
      response.status = 200;
  } else {
    response.body = { msg: "Token does not match" };
    response.status = 400;
  }
};
