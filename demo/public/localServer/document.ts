

// DATA STRUCTURES

export interface Document {
  id: string;
  fileName: string;
  author: string;
  timeCreated: number;
  timeUpdated: number;
  tags: string[];
  categories:string[];
  title: string;
  subtitle: string;
  abstract: string;
  belongsTo: string;
  content: string;
}


export interface Metadata {
  id: string;
  fileName: string;
  author: string;
  timeCreated: number;
  timeUpdated: number;
  tags: string[];
  categories:string[];
  title: string;
  subtitle: string;
  abstract: string;
  belongsTo: string;

}
// 11 fields

