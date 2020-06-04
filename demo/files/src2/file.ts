import { load, safeDump } from 'https://deno.land/x/js_yaml_port/js-yaml.js'
import {Document, DocumentRecord} from './document.ts'
import {FILE_STORE_PATH} from './config.ts'
import {manifest} from "./manifest.ts";



export const fetchDocument = async (id: String): Promise<Document> => {
  const docRec = manifest.filter(r => r.id == id)[0]
  return fetchDocument_(docRec)
}

const fetchDocument_ = async (docRec: DocumentRecord): Promise<Document> => {
  const path = FILE_STORE_PATH + '/' + docRec.fileName
  console.log("path", path)
  const data = await Deno.readFile(path);

  const decoder = new TextDecoder();
  const decodedData = decoder.decode(data);

  const doc: Document = { fileName: docRec.fileName, id: docRec.id, content: decodedData}

  return doc;
};

export const writeDocument = async (doc: Document): Promise<void> => {
  const encoder = new TextEncoder();
  await Deno.writeFile(FILE_STORE_PATH + "/" + doc.fileName, encoder.encode(doc.content));
};


// console.log("FETCHED:", await fetchDocument("143d1170-f8ce-47b3-904d-e84191d3d717"));
