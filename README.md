# A Pure Elm Text Editor

This package offers a pure Elm text editor.
It relies heavily on prior work of 
Martin Janiczek and Sidney Nemzer.  It is a pleasure
to acknowledge their work.

There will be real documentation at some point.  For now, 
if you want to use the package, the best way is to
see how it is used in the demo app.

The demo contains both "in-editor" features and hooks for 
using it in a host app, e.g., syncing the source
and rendered text for various markup languages.


## Bugs and whatnot

I appreciate feedback.  Please post issues, feature requests, comments
as an issue on [Github](https://github.com/jxxcarlson/elm-editor2). 
Or contact me on gmail at jxxcarlson.

## The Demo

[Live version here!](https://jxxcarlson.github.io/app/text-editor/index.html)

The  editor lives in the left-hand window of the demo app. You can write 
 text there in either

- a dialect of Markdown (Markdown/Math) that can
handle equations written in LaTeX and can render
SVG images as in the example.

- or MiniLaTeX, a subset of LaTeX

The source text will be rendered on the fly to Html, as you will
see in the right-hand window.


## Installation 

```
cd ./demo
npm install
npm start
```

## Notes

- The present package, `jxxcarlson/elm-editor`, supersedes
`jxxcarlson/elm-text-editor`.  Better to use this one!

- Im plannng on a Vim mode, but have made just a barebones start on this. 

- Under consideration: an Electron version.  I know nothing about doing
this, so if anyone wants lend a helping hand, that would be great.
