

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
