#!/bin/sh
./hex2vhdl.sh ../../roms/1541_c000_01_and_e000_06aa.hex > ../../roms/1541_c000_01_and_e000_06aa.vhd
./hex2vhdl.sh ../../roms/25196801.hex > ../../roms/25196801.vhd
./hex2vhdl.sh ../../roms/25196802.hex > ../../roms/25196802.vhd
./hex2vhdl.sh ../../roms/325302-1_901229-03.hex > ../../roms/325302-1_901229-03.vhd

echo "edit manually each vhd file and remove trailing ','"
echo "at last line in the rom constant array data"
