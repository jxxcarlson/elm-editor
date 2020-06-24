
const env = Deno.env.toObject();

export const DATA_PATH = env.MUDOCS || "../data"

export const MANIFEST = DATA_PATH + '/manifest.yaml'

console.log("MANIFEST", MANIFEST)

export const AUTHOR_LIST = DATA_PATH + '/authors.yaml'
