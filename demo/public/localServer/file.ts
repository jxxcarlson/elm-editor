import { load, safeDump } from 'https://deno.land/x/js_yaml_port/js-yaml.js'
import {Document, Metadata} from './document.ts'
import {DATA_PATH} from './config.ts'


export const readDocument = async (metaData: Metadata): Promise<Document> => {

  const path = DATA_PATH + '/' + metaData.fileName
  const data = await Deno.readFile(path);

  const decoder = new TextDecoder();
  const decodedData = decoder.decode(data);

  const doc: Document = { id: metaData.id, fileName: metaData.fileName, author: metaData.author,
     timeCreated: metaData.timeCreated, timeUpdated: metaData.timeUpdated, tags: metaData.tags,
     categories: metaData.categories, title: metaData.title, subtitle: metaData.subtitle,
     abstract: metaData.abstract, belongsTo: metaData.belongsTo, docType: metaData.docType,
     content: decodedData }


  return doc;
};

export const writeDocument = async (doc: Document): Promise<void> => {
  const encoder = new TextEncoder();
  await Deno.writeFile(DATA_PATH + "/" + doc.fileName, encoder.encode(doc.content));
};


// console.log("FETCHED:", await readDocument("143d1170-f8ce-47b3-904d-e84191d3d717"));
