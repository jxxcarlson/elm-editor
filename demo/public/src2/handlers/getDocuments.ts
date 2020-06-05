import {Document, DocumentRecord} from "../document.ts";
import {manifest} from "../manifest.ts"

// Get the current list of documents
export const getDocuments = ( { response }: { response: any }) => {
  console.log("file list requested");
  response.headers.set("Access-Control-Allow-Origin", "*");
  response.body = manifest;
};
