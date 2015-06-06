#!/bin/sh
SIZE=$(wc -c < ${1})
cat << EOF > ${2}
// file: ${1}
// size: $SIZE
EOF
hexdump -v -e '32/1 "%02X ""\n"' ${1} >> ${2}
