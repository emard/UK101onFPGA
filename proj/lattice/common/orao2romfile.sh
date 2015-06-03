#!/bin/sh

rom_convert () {
cat << EOF > ${output}
#Format=Hex
#Depth=8192
#Width=8
#AddrRadix=3
#DataRadix=3
#Data
EOF
hexdump -v -e '/1 "%02X\n"' ${input} >> ${output}
}

input=../../../orao/BAS13.ROM
output=/tmp/bas13.mem
rom_convert
echo $output

input=../../../orao/CRT13.ROM
output=/tmp/crt13.mem
rom_convert
echo $output