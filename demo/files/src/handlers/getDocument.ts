import {Document, DocumentRecord} from "../document.ts";

// Get the current list of documents
export const getDocuments = (documents : Array<Document>, { response }: { response: any }) => {
  console.log("file list requested");
  response.headers.set("Access-Control-Allow-Origin", "*");
  response.body = documents.map(documentRecordOf);
};

function documentRecordOf(doc: Document) {
  return { fileName: doc.fileName, id: doc.id };
}
