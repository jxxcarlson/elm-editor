
TARGET=/Users/carlson/dev/github_pages/app/text-editor
DIST=public
SOURCE=src

elm make --optimize ${SOURCE}/Main.elm --output=${DIST}/Main.js

echo "Uglifying ..."
uglifyjs  ${DIST}/Main.js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters=true,keep_fargs=false,unsafe_comps=true,unsafe=true,passes=2' --output=${DIST}/Main.min.js && uglifyjs ${DIST}/Main.min.js --mangle --output=${DIST}/Main.min.js

echo "Copying ..."
cp ${DIST}/index-min.html ${TARGET}/index.html
cp ${DIST}/Main.min.js ${TARGET}/

cp ${DIST}/assets/custom-element-config.js ${TARGET}/assets/custom-element-config.js
cp ${DIST}/assets/math-text.js ${TARGET}/assets/math-text.js
cp ${DIST}/assets/math-text-delayed.js ${TARGET}/assets/math-text-delayed.js
cp ${DIST}/assets/outside.js ${TARGET}/assets/outside.js
cp ${DIST}/assets/style.css ${TARGET}/assets/style.css


echo "cd /Users/carlson/dev/github_pages/"