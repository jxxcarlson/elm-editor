# A Pure Elm Text Editor

This package offers a pure Elm text editor.
It relies heavily on prior work of 
Martin Janiczek and Sidney Nemzer.  It is a pleasure
to acknowledge their work.  I would also like to acknowldge the 
work of Anton-4 who cleaned up the codebase, running elm-analyse on it,
fixed a variety of bugs, and wrote the `small-demo` app to 
facilitate further development.  Many thanks!

After a time away from this code (other things called!) I am now back at work
with a first order of business to make it possible to edit large files
without the app slowing to a crawl. As a test document, I am using 
Darwin's *Origin of the Species,* which weighs in at over 15,000 lines.
Even with a file this large, the app is quite snappy.

The approach taken is for the editor to "see" only a small window into the 
full array of lines of text.  That window is currently initialized 
in EditorModel.init at 300 lines, about ten times the number of lines visible
in the editor of `smalldemo`.  

It is important to distinguish between the viewport and the window.  The
former consists of what is visible, while the latter populates the scene 
defines what can be visible without moving the window in the document from
which it is derived.

When the user clicks on a line that is near the upper or lower boundary
of the window, the window and viewport are both adjusted so that (a) there 
is plenty of text above/below the viewport boundaries,
 and so that (b) the cursor does not appear to move.

Once the windowing system is working satisfactorily, I'll move back to working
on other issues, including many annoying bugs and infelicities.  Regarding the
windowing system, I've done some preliminary work on making the window into the 
full text update itself as the user scroll, so that the user never runs
out of text.  This currently works if the user scrolls say, on a mac by 
by moving the cursor with track pad.  For the scroll bars, I think I need
some sort of subscription to the y-coordinate of
the viewport.


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
