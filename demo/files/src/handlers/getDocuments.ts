import {Document, DocumentRecord} from "../document.ts";
import {documents} from "../documents.ts"

// Get the current list of documents
export const getDocuments = ( { response }: { response: any }) => {
  console.log("file list requested (2)");
  response.headers.set("Access-Control-Allow-Origin", "*");
  response.body = documents.map(documentRecordOf);
};

function documentRecordOf(doc: Document) {
  return { fileName: doc.fileName, id: doc.id };
}
