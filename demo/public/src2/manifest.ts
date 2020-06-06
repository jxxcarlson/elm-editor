import {DocumentRecord, Document} from "./document.ts";
import { load, safeDump } from 'https://deno.land/x/js_yaml_port/js-yaml.js'
import {MANIFEST} from './config.ts'
import {writeDocument} from "./file.ts"

const hasSameFileName = (a: DocumentRecord, b: DocumentRecord) => a.fileName == b.fileName;

const hasSameId = (a: DocumentRecord, b: DocumentRecord) => a.id == b.id;

const isNotPresent = (d: DocumentRecord, manifest_: Array<DocumentRecord>) =>
  manifest_.filter((r) => hasSameId(r, d)).length == 0;


export const fetchManifest = async (): Promise<DocumentRecord[]> => {
  const data = await Deno.readFile(MANIFEST);

  const decoder = new TextDecoder();
  const decodedData = decoder.decode(data);

  console.log("MANIFEST", decodedData)

  return load(decodedData);
};

export const writeManifest = async (data: Array<DocumentRecord>): Promise<void> => {
  const encoder = new TextEncoder();
  await Deno.writeFile(MANIFEST, encoder.encode(safeDump(data)));
};

export var manifest = await fetchManifest();

const changeDoc = (s: DocumentRecord, t : DocumentRecord) =>
  s.id == t.id ?  Object.assign({}, s) : t


export const updateDocument = async ({
  request,
  response,
}: {
  request: any;
  response: any;
}) => {
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
    const sourceDoc: Document = { id: id, fileName: fileName, content: content };
    const sourceDocRecord: DocumentRecord = { id: id, fileName: fileName };
    if (isNotPresent(sourceDocRecord, manifest)) {
      manifest.push(sourceDocRecord);
      writeManifest(manifest)
      writeDocument(sourceDoc)
      console.log("added: " + sourceDoc.fileName);
      response.body = { msg: "Added: " + sourceDoc.fileName};
      response.status = 200;
    } else {
      manifest = manifest.map((d:DocumentRecord) => changeDoc(sourceDocRecord, d))
      writeManifest(manifest)
      writeDocument(sourceDoc)
      console.log("updated: " + sourceDoc.fileName);
      response.body = { msg: "Updated: " + sourceDoc.fileName };
      response.status = 200;
    }
  } else {
    response.body = { msg: "Token does not match" };
    response.status = 400;
  }
};
