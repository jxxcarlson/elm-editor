
//import {Document, DocumentRecord, ExtendedDocument, documentOfExtendedDocument} from "./document.ts";
import {manifest} from "../manifest.ts";
import {fetchDocument} from "../file.ts";

// Get a document by file name
export const  getDocument = async ({
  params,
  response,
}: {
  params: {
    id: string;
  };
  response: any;
}) => {
  response.headers.set("Access-Control-Allow-Origin", "*");
  response.body = await fetchDocument(params.id)

  response.status = 200;
  return;
};
