// https://dev.to/kryz/write-a-small-api-using-deno-1cl0
// DINOSAUR: https://dev.to/nickolasbenakis/create-a-simple-rest-api-with-deno-and-oak-framework-2fna

import { Application, Router } from "https://deno.land/x/oak/mod.ts";
import {Document, DocumentRecord, ExtendedDocument, documentOfExtendedDocument} from "./document.ts";
import {documents ,getDocumentsFromDisk} from "./documents.ts";
import {getDocuments} from "./handlers/getDocuments.ts"
import {getDocument} from "./handlers/getDocument.ts"
import {addDocument} from "./handlers/addDocument.ts"
import {updateDocument} from "./handlers/updateDocument.ts"
import {options} from "./handlers/options.ts"
import {fetchData} from "./db.ts"
//
import { login, guest, auth } from "./handlers/login.ts";
import { authMiddleware } from "./auth/middleware.ts"


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
  // .options("/api/login", options)
  .put('/api/:fileName', updateDocument)
  .post('/api/login', login)
  .get('/api/guest', guest)
  .get('/api/auth', authMiddleware,  auth) // Registering authMiddleware for /auth endpoint only
;
// .delete('/dogs/:name', removeDog)

const app = new Application();

app.use(router.routes());
app.use(router.allowedMethods());

console.log(`Listening on port ${PORT}...`);



await app.listen(`${HOST}:${PORT}`);
//await documents = getDocumentsFromDisk();
