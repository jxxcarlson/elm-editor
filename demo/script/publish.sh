!#/bin/sh

TARGET=/Users/carlson/dev/github_pages/app/janiczek-editor
DIST=public
SOURCE=src

elm make --optimize ${SOURCE}/Main.elm --output=${DIST}/Main.js

echo "Uglifying ..."
uglifyjs ${DIST}/Main.js -mc 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9"' -o ${DIST}/Main.min.js

echo "Copying ..."
cp ${DIST}/index-min.html ${TARGET}/index.html
cp ${DIST}/Main.min.js ${TARGET}/

echo "cd /Users/carlson/dev/github_pages/"