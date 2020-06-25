

import { DATA_PATH } from "../config.ts"

const readDocumentText = async (fileName: string): Promise<string> => {

  const path = DATA_PATH + '/' + fileName
  const data = await Deno.readFile(path);

  const decoder = new TextDecoder();
  const decodedData = decoder.decode(data);

  return decodedData;
};


// Get a document by file name
export const  getDocumentText = async ({
  params,
  response,
}: {
  params: {
    fileName: string;
  };
  response: any;
}) => {
  console.log("GET", params.fileName)
  response.headers.set("Access-Control-Allow-Origin", "*");
  response.body = await readDocumentText(params.fileName)

  response.status = 200;
  return;
};


export const iAmAlive = ( { response }: { response: any }) => {
  console.log("file list requested");
  response.headers.set("Access-Control-Allow-Origin", "*");
  response.body = "I am alive. Thanks for asking!";
};
