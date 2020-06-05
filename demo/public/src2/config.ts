
const env = Deno.env.toObject();

export const FILE_STORE_PATH = env.MUDOCS || "../data"

export const MANIFEST = FILE_STORE_PATH + '/manifest.yaml'
