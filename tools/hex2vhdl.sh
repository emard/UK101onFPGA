#!/bin/sh
objcopy -I ihex $1 -O binary /tmp/hex2vhdl.bin
cat rom_head.vhd
dd bs=512 if=/tmp/hex2vhdl.bin conv=sync \
| hexdump -v -e '8/1 "x_%02X_, ""\n"' \
| sed -e 's/_/"/g'
rm /tmp/hex2vhdl.bin
cat rom_tail.vhd
