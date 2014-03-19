#!/bin/bash
set -e
export PATH=$PATH:/usr/local/bin
cd "$(dirname "$0")"
#rm cache/*
nimrod c -d:ssl gen
./gen > index.html.tmp
mv index.html.tmp index.html
base64 -w0 < index.html > index.js.tmp
echo "
document.write(window.atob('$(cat index.js.tmp)'))
" > index.js
rm index.js.tmp
