import { Application, Router } from 'https://deno.land/x/oak/mod.ts'

import {quantum_md, test_tex} from './documents.ts'

interface Document {
  fileName: string
  content: string
}

interface DocumentRecord {
  id: string
  fileName: string
}

let documentList: Array<DocumentRecord> = [
  {
    fileName: 'quantum.md',
    id: '143d1170-f8ce-47b3-904d-e84191d3d717'
  },
  {
    fileName: 'test.tex',
    id: '7a7e54a9-70d9-4263-ba02-cb685e1fdaf8'
  }
 ]


 let documents: Array<Document> = [
   {
     fileName: 'quantum.md',
     content: quantum_md
   },
   {
     fileName: 'test.tex',
     content: test_tex
   }
  ]



const env = Deno.env.toObject()
const PORT = env.PORT || 4000
//const HOST = env.HOST || '127.0.0.1'
const HOST = env.HOST || 'localhost'

const router = new Router()

export const getDocuments = ({ response }: { response: any }) => {
    response.body = documentList
  }

  export const getDocument = ({
    params,
    response,
  }: {
    params: {
      fileName: string
    }
    response: any
  }) => {
    const document = documents.filter((document) => document.fileName === params.fileName)
    if (document.length) {
      response.status = 200
      response.body = document[0]
      return
    }

    response.status = 400
    response.body = { msg: `Cannot find document ${params.fileName}` }
  }

router
  .get('/documents', getDocuments)
  .get('/document/:fileName', getDocument)
  // .post('/dogs', addDog)
  // .put('/dogs/:name', updateDog)
  // .delete('/dogs/:name', removeDog)



const app = new Application()

app.use(router.routes())
app.use(router.allowedMethods())

console.log(`Listening on port ${PORT}...`)

await app.listen(`${HOST}:${PORT}`)
