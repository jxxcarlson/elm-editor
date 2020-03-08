# A Pure Elm Text Editor

This package offers a pure Elm text editor.
It relies heavily on prior work of 
Martin Janiczek and Sidney Nemzer.  It is a pleasure
to acknowledge their work.

There will be real documentation at some point.  For now, 
if you want to use this editor package the best way is to
see how it is used in the demo app.

The editor contains both "in-editor" features and hooks for 
using it in a host app.

## Bugs and whatnot

I appreciate feedback.  Please post issues, feature requests, comments
as an issue on [Github](https://github.com/jxxcarlson/elm-editor2)

## The Demo

Run the demo and experiment with the editor:

[Live here!](https://jxxcarlson.github.io/app/text-editor/index.html)

The "landing page" explains many features of the editor.  The 
editor lives in the left-hand window of the demo app. You can write 
 text there in either

- a dialect of Markdown (Markdown/Math) that can
handle equations written in LaTeX.

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

- Vim mode: just a barebones start on this.  The plan is to do a bit 
more between now and April 25, then see how much of Vim we can add
at the hackathon in Paris

- Under consideration: an Electron version.  I know nothing about doing
this, so if anyone wants lend a helping hand, that would be great. We
might also try this at the hackathon.

