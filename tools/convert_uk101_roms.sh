#!/bin/sh
./bin2vhdl.sh ../UK101/uk101basic.rom > ../UK101/uk101basic.vhd

echo "edit manually each vhd file, set rom_bas or rom_crt name and remove trailing ','"
echo "at last line in the rom constant array data"
