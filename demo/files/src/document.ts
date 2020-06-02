

// DATA STRUCTURES

export interface Document {
  fileName: string;
  id: string;
  content: string;
}

export interface ExtendedDocument {
  token: string;
  fileName: string;
  id: string;
  content: string;
}

export interface DocumentRecord {
  id: string;
  fileName: string;
}


export function documentRecordOf(doc: Document) {
  return { fileName: doc.fileName, id: doc.id };
}


export function documentOfExtendedDocument(doc: ExtendedDocument) {
  return { fileName: doc.fileName, id: doc.id, content: doc.content };
}
