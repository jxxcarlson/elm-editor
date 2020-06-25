import { DATA_PATH } from "../config.ts"
import { safeDump } from 'https://deno.land/x/js_yaml_port/js-yaml.js'

const getDirectoryListing = async () => {
                const data = []
                for await (const x of Deno.readDir(DATA_PATH)) {
                    data.push(x.name);
                }
                return data
            };


  // console.log("DATA", safeDump(await getDirectoryListing()))

export const list = async ( { response }: { response: any }) => {

  console.log("directory listing requested");

  // console.log("LIST", Deno.readDir(DATA_PATH))

  response.headers.set("Access-Control-Allow-Origin", "*");
  response.body = await getDirectoryListing();
};
