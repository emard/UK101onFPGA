#!/bin/sh -e

# script to convert BASIC ROM .hex file (intel hex format)
# to diamond HEX .mem file that can
# be used as preload content of lattice BRAM ROM

cp ../../../UK101/BASIC.HEX /tmp/basic.hex
hex2bin -c /tmp/basic.hex
cat << EOF > /tmp/basic.mem
#Format=Hex
#Depth=8192
#Width=8
#AddrRadix=3
#DataRadix=3
#Data
EOF
hexdump -v -e '/1 "%02X\n"' /tmp/basic.bin >> /tmp/basic.mem
