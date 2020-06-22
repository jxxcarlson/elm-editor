import { AUTHOR_LIST} from './config.ts'
import { load, safeDump } from 'https://deno.land/x/js_yaml_port/js-yaml.js'


// DATA STRUCTURES

export interface AuthorWithPasswordHash {
  name: string;
  userName: string
  id: string;
  email: string;
  passwordHash: string;
  dateCreated: number;
  dateModified: number;
};

export interface Author {
  name: string;
  userName: string
  id: string;
  email: string;
  dateCreated: number;
  dateModified: number;
};

let reduceAuthor = function (a: AuthorWithPasswordHash): Author {
    return {
         name: a.name,
         userName: a.userName,
         id: a.id,
         email: a.email,
         dateCreated: a.dateCreated,
         dateModified: a.dateModified
       }
    }

const testAuthor : AuthorWithPasswordHash = {
  name: "John Doe",
  userName: "jdoe",
  id: "1234",
  email: "jdoe@foo.io",
  passwordHash: "7*^^YYY",
  dateCreated: 1234,
  dateModified: 1234
}

const testAuthor2 : AuthorWithPasswordHash = {
  name: "Henry Doe",
  userName: "hdoe",
  id: "4321",
  email: "hdoe@foo.io",
  passwordHash: "TW^YYY",
  dateCreated: 4321,
  dateModified: 4321
}


const isNotPresent = (a: AuthorWithPasswordHash, authorList_: Array<AuthorWithPasswordHash>) =>
  authorList_.filter((x) => hasSameId(a, x)).length == 0;

const hasSameId = (a: AuthorWithPasswordHash, b: AuthorWithPasswordHash) => a.id == b.id;

const changeAuthor = (s: AuthorWithPasswordHash, t : AuthorWithPasswordHash) =>
  s.id == t.id ?  Object.assign({}, s) : t


export const fetchAuthorList = async (): Promise<AuthorWithPasswordHash[]> => {
  const data = await Deno.readFile(AUTHOR_LIST);

  const decoder = new TextDecoder();
  const decodedData = decoder.decode(data);

  // console.log("AUTHOR_LIST", decodedData)

  return load(decodedData);
};

export const writeAuthorList = async (data: Array<AuthorWithPasswordHash>): Promise<void> => {
  const encoder = new TextEncoder();
  await Deno.writeFile(AUTHOR_LIST, encoder.encode(safeDump(data)));
};

// writeAuthorList([testAuthor]);

export var authorList = await fetchAuthorList();

export const signInAuthor = async ({
  request,
  response,
}: {
  request: any;
  response: any;
}) => {
  const {
    value : {userName, passwordHash},
  } = await request.body();
  response.headers.set("Access-Control-Allow-Origin", "*");
  response.headers.append("Access-Control-Allow-Methods", "POST, OPTIONS");
  response.headers.append(
    "Access-Control-Allow-Headers",
    "X-Requested-With, Content-Type, Accept, Origin",
  );

  const authorsFound = authorList.filter((a) => a.userName == userName)

  const authorized = (passwordHash_: String, aa : Array<AuthorWithPasswordHash>) =>
    aa.length == 1 ?  authorized_(passwordHash_, aa[0]) : false

  const authorized_ = (passwordHash_: String, a : AuthorWithPasswordHash) =>
    passwordHash_ == a.passwordHash


  // console.log("Authorized: " + authorized(passwordHash, authorsFound))

  if (authorized(passwordHash, authorsFound)) {
      response.body = reduceAuthor(authorsFound[0]);
    } else {
      response.body = { authorized: false}
    }

  response.status = 200;


};

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
    const author: AuthorWithPasswordHash = { name: name
       , userName: userName
       , id: id, email: email, passwordHash: passwordHash
       , dateCreated: dateCreated, dateModified: dateModified };

    // console.log("AuthorWithPasswordHash", author)
    if (isNotPresent(author, authorList)) {
      authorList.push(author);
      writeAuthorList(authorList)
      console.log("added: " + author.userName);
      response.body = { msg: "Added: " + author.userName};
      response.status = 200;
    } else {
      authorList = authorList.map((a:AuthorWithPasswordHash) => changeAuthor(author, a))
      writeAuthorList(authorList)
      console.log("updated: " + author.userName);
      response.body = { msg: "Updated: " + author.userName};
      response.status = 200;
    }

};
