export const options = ( { response }: { response: any }) => {
  console.log("OPTIONS");
  response.headers.set("Access-Control-Allow-Origin", "*");
  response.headers.set("Access-Control-Allow-Methods",  "OPTIONS, POST, PUT, DELETE");
  response.headers.set("Access-Control-Max-Age", "86400");
  response.headers.set("Access-Control-Allow-Headers", ["Accept", "Content-type"])
  response.headers.set("Connection", "keep-alive")
  response.headers.set("Content-length", "0")
  response.status = 200;
};
