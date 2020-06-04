import {DocumentRecord} from "./document.ts";
import { load, safeDump } from 'https://deno.land/x/js_yaml_port/js-yaml.js'
import {MANIFEST , MANIFESTB} from './config.ts'

export const fetchManifest = async (): Promise<DocumentRecord[]> => {
  const data = await Deno.readFile(MANIFEST);

  const decoder = new TextDecoder();
  const decodedData = decoder.decode(data);

  return load(decodedData);
};

export const writeManifest = async (data: Array<DocumentRecord>): Promise<void> => {
  const encoder = new TextEncoder();
  await Deno.writeFile(MANIFESTB, encoder.encode(safeDump(data)));
};

export const manifest = await fetchManifest();

console.log("manifest", manifest)

writeManifest(manifest)


//
