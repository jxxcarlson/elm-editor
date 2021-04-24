
//import {Document, DocumentRecord, ExtendedDocument, documentOfExtendedDocument} from "./document.ts";
import {documents } from "../documents.ts";

// Get a document by file name
export const getDocument = ({
  params,
  response,
}: {
  params: {
    fileName: string;
  };
  response: any;
}) => {
  response.headers.set("Access-Control-Allow-Origin", "*");
  const document = documents.filter((document) =>
    document.fileName === params.fileName
  );
  if (document.length) {
    response.status = 200;
    response.body = document[0];
    return;
  }

  response.status = 400;
  response.body = { msg: `Cannot find document ${params.fileName}` };
};
