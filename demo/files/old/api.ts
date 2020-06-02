import { serve } from "https://deno.land/file_server.ts";

import { open, save } from "<https://deno.land/x/sqlite/mod.ts>";

const PORT = 8162;
const s = serve({ port: PORT });

console.log(` Listening on <http://localhost>:${PORT}/`);

for await (const req of s) {
  req.respond({ body: "Hello World\\n" });
}
