import { AUTHOR_LIST} from './config.ts'
import { load, safeDump } from 'https://deno.land/x/js_yaml_port/js-yaml.js'


// DATA STRUCTURES

export interface Author {
  name: string;
  userName: string
  id: string;
  email: string;
  passwordHash: string;
  dateCreated: number;
  dateModified: number;
}

const testAuthor : Author = {
  name: "John Doe",
  userName: "jdoe",
  id: "1234",
  email: "jdoe@foo.io",
  passwordHash: "7*^^YYY",
  dateCreated: 1234,
  dateModified: 1234
}

const testAuthor2 : Author = {
  name: "Henry Doe",
  userName: "hdoe",
  id: "4321",
  email: "hdoe@foo.io",
  passwordHash: "TW^YYY",
  dateCreated: 4321,
  dateModified: 4321
}


const isNotPresent = (a: Author, authorList_: Array<Author>) =>
  authorList_.filter((x) => hasSameId(a, x)).length == 0;

const hasSameId = (a: Author, b: Author) => a.id == b.id;

const changeAuthor = (s: Author, t : Author) =>
  s.id == t.id ?  Object.assign({}, s) : t


export const fetchAuthorList = async (): Promise<Author[]> => {
  const data = await Deno.readFile(AUTHOR_LIST);

  const decoder = new TextDecoder();
  const decodedData = decoder.decode(data);

  console.log("AUTHOR_LIST", decodedData)

  return load(decodedData);
};

export const writeAuthorList = async (data: Array<Author>): Promise<void> => {
  const encoder = new TextEncoder();
  await Deno.writeFile(AUTHOR_LIST, encoder.encode(safeDump(data)));
};

// writeAuthorList([testAuthor]);

export var authorList = await fetchAuthorList();

export const createAuthor = async ({
  request,
  response,
}: {
  request: any;
  response: any;
}) => {
  const {
    value : {name, userName, id, email, passwordHash, dateCreated, dateModified},
  } = await request.body();
  response.headers.set("Access-Control-Allow-Origin", "*");
  response.headers.append("Access-Control-Allow-Methods", "POST, OPTIONS");
  response.headers.append(
    "Access-Control-Allow-Headers",
    "X-Requested-With, Content-Type, Accept, Origin",
  );
    const author: Author = { name: name
       , userName: userName
       , id: id, email: email, passwordHash: passwordHash
       , dateCreated: dateCreated, dateModified: dateModified };

    console.log("Author", author)
    if (isNotPresent(author, authorList)) {
      console.log("BRANCH 1")
      authorList.push(author);
      writeAuthorList(authorList)
      console.log("added: " + author.userName);
      response.body = { msg: "Added: " + author.userName};
      response.status = 200;
    } else {
      console.log("BRANCH 2")
      authorList = authorList.map((a:Author) => changeAuthor(author, a))
      writeAuthorList(authorList)
      console.log("updated: " + author.userName);
      response.body = { msg: "Updated: " + author.userName};
      response.status = 200;
    }

};
