
//import {Document, DocumentRecord, ExtendedDocument, documentOfExtendedDocument} from "./document.ts";
import {manifest} from "../manifest.ts";
import {fetchDocumentByFileName} from "../file.ts";

// Get a document by file name
export const  getDocument = async ({
  params,
  response,
}: {
  params: {
    fileName: string;
  };
  response: any;
}) => {
  response.headers.set("Access-Control-Allow-Origin", "*");
  response.body = await fetchDocumentByFileName(params.fileName)

  response.status = 200;
  return;
};
