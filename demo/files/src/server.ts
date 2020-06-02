// https://dev.to/kryz/write-a-small-api-using-deno-1cl0
// DINOSAUR: https://dev.to/nickolasbenakis/create-a-simple-rest-api-with-deno-and-oak-framework-2fna

import { Application, Router } from "https://deno.land/x/oak/mod.ts";
import {Document, DocumentRecord, ExtendedDocument, documentOfExtendedDocument} from "./document.ts";
import {documents } from "./documents.ts";
import {getDocuments} from "./handlers/getDocuments.ts"
import {getDocument} from "./handlers/getDocument.ts"
import {addDocument} from "./handlers/addDocument.ts"
import {updateDocument} from "./handlers/updateDocument.ts"
import {options} from "./handlers/options.ts"

// WEB SERVER

const env = Deno.env.toObject();
const PORT = env.PORT || 4000;
const HOST = env.HOST || "localhost";

const router = new Router();

router
  .get("/api/documents", getDocuments)
  .get("/api/document/:fileName", getDocument)
  .post("/api/documents", addDocument)
  .options("/api/documents", options)
  .put('/api/:fileName', updateDocument);
// .delete('/dogs/:name', removeDog)

const app = new Application();

app.use(router.routes());
app.use(router.allowedMethods());

console.log(`Listening on port ${PORT}...`);

await app.listen(`${HOST}:${PORT}`);
