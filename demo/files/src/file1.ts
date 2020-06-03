import { load, safeDump } from 'https://deno.land/x/js_yaml_port/js-yaml.js'
import {Document, DocumentRecord} from './document.ts'
import {quantum_md, test_tex} from './data.ts'
import {FILE_STORE_PATH} from './config.ts'

export const fetchDocument = async (docRec: DocumentRecord): Promise<Document> => {
  const path = FILE_STORE_PATH + '/' + docRec.fileName
  console.log("path", path)
  const data = await Deno.readFile(path);

  const decoder = new TextDecoder();
  const decodedData = decoder.decode(data);

  const doc: Document = { fileName: docRec.fileName, id: docRec.id, content: decodedData}

  return doc;
};

const testData = [

  {
    fileName: "quantum.md",
    id: "143d1170-f8ce-47b3-904d-e84191d3d717",
    content: quantum_md,
  },
  {
    fileName: "test.tex",
    id: "7a7e54a9-70d9-4263-ba02-cb685e1fdaf8",
    content: test_tex,
  },
];

const manifest : string =
`--- # Files
- id: 143d1170-f8ce-47b3-904d-e84191d3d717
  fileName: quantum.md
- id: 7a7e54a9-70d9-4263-ba02-cb685e1fdaf8
  fileName: test.tex
`

const rec: DocumentRecord = {
  id: "7a7e54a9-70d9-4263-ba02-cb685e1fdaf8",
  fileName: "test.tex"
}

const metadata : Array<DocumentRecord> = load(manifest)

console.log("metadata", metadata)

console.log("dump metadata", safeDump(metadata))

console.log("document", await fetchDocument(rec));
