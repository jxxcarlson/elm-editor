import { Document } from "./document.ts";

export const fetchData = async (): Promise<Document[]> => {
  const data = await Deno.readFile(DB_PATH);

  const decoder = new TextDecoder();
  const decodedData = decoder.decode(data);

  return JSON.parse(decodedData);
};

export const persistData = async (data: Array<Document>): Promise<void> => {
  const encoder = new TextEncoder();
  await Deno.writeFile(DB_PATH, encoder.encode(JSON.stringify(data)));
};
