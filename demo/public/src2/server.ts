// https://dev.to/kryz/write-a-small-api-using-deno-1cl0
// DINOSAUR: https://dev.to/nickolasbenakis/create-a-simple-rest-api-with-deno-and-oak-framework-2fna
// CORS: https://github.com/tajpouria/cors
// DOCKER https://blog.logrocket.com/how-to-deploy-deno-applications-to-production/
// POGO https://github.com/sholladay/pogo

import { Application, Router } from "https://deno.land/x/oak/mod.ts";
import {Document, DocumentRecord, ExtendedDocument, documentOfExtendedDocument} from "./document.ts";
import {getDocuments} from "./handlers/getDocuments.ts"
import {getDocument} from "./handlers/getDocument.ts"
import {createDocument} from "./handlers/createDocument.ts"
import {updateDocument} from "./manifest.ts"
//import {options} from "./handlers/options.ts"
import {createAuthor, signInAuthor} from "./author.ts"
import { oakCors } from "https://deno.land/x/cors/mod.ts";
//
import { login, guest, auth } from "./handlers/login.ts";
import { authMiddleware } from "./auth/middleware.ts"
//
import { FILE_STORE_PATH, MANIFEST } from "./config.ts"


// WEB SERVER

const env = Deno.env.toObject();
const PORT = env.PORT || 4000;
const HOST = env.HOST || "localhost";

const router = new Router();

router
  .get("/api/documents", getDocuments)
  .get("/api/document/:fileName", getDocument)
  .post("/api/documents", createDocument)
  .put('/api/:fileName', updateDocument)
  .post('/api/login', login)
  .post('/api/authors', createAuthor)
  .post('/api/authors/signin', signInAuthor)
  .get('/api/guest', guest)
  .get('/api/auth', authMiddleware,  auth) // Registering authMiddleware for /auth endpoint only
;
// .delete('/dogs/:name', removeDog)

const app = new Application();

app.use(oakCors()); // Enable CORS for All Routes
app.use(router.routes());
app.use(router.allowedMethods());

console.log(`Listening on port ${PORT}...`);
console.log(`Files stored in ${FILE_STORE_PATH}`);

await app.listen(`${HOST}:${PORT}`);
