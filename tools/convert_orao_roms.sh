#!/bin/sh
./bin2vhdl.sh ../orao/BAS102.ROM > ../orao/rom_bas102.vhd
./bin2vhdl.sh ../orao/BAS103.ROM > ../orao/rom_bas103.vhd
./bin2vhdl.sh ../orao/CRT102.ROM > ../orao/rom_crt102.vhd
./bin2vhdl.sh ../orao/CRT103.ROM > ../orao/rom_crt103.vhd

echo "edit manually each vhd file, set rom_bas or rom_crt name and remove trailing ','"
echo "at last line in the rom constant array data"
