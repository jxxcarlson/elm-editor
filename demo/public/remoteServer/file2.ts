import { load, safeDump } from 'https://deno.land/x/js_yaml_port/js-yaml.js'

interface Metadata {
  id: string;
  fileName: string;
  collection: string
  title : string;
  subtitle: string;
  order: number;
  level: number;
  authorName: string;
  authorHandle: string;
  authorId: string;
  public: boolean;
  tags: Array<string>;
  categories: Array<string>;
}

const manifest : string =
`--- # Files
- id: 1234
  fileName: intro.md
  collection: physics_book
  title: Intro
  subtitle:
  order: 1
  level: 1
  authorName: James Carlson
  authorHandle: jxxcarlson
  authorId: ux891
  public: true
  tags: [foo, bar  ]
  categories: [science]
- id: 3456
  fileName: ch1.md
  collection:
  title: Bugs
  subtitle: Your back yard
  order: 31
  level: 2
  authorName: James Carlson
  authorHandle: jxxcarlson
  authorId: ux891
  public: false
  tags: [bugs, insects  ]
  categories: [science]
`

const metadata: Array<Metadata> = load(manifest)

console.log("metadata", metadata)

console.log("dump metadata", safeDump(metadata))
