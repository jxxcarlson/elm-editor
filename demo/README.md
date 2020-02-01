# Janiczek's Pure Elm Editor

This is a fork of https://github.com/Janiczek/elm-editor.  
I have done the following:

    - Adapt the code to Elm 0.19 from 0.18
    - Add scrolling
    - Add Html.Lazy.lazy6 to 'viewLine' for performance reasons. It seems to help, though I have not benchmarked anything.
    - Add feature to append N lines of identical text for testing (performance for large documents)
    - A few UI tweaks
    
    
## Running the code

```bash
npm install
npm start
```