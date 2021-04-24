import { serve } from "https://deno.land/std/http/server.ts";
const s = serve({ port: 8003 });
console.log("http://localhost:8003/");
for await (const req of s) {
  req.respond({ body: "Hello World\n" });
}
