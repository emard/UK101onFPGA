#!/bin/sh
unzip 'Boulder Dash (19xx)(Mihailovic, Nenad - Dapjas, Mihajlo)(YU)(en).zip'
mv -f 'Boulder Dash (19xx)(Mihailovic, Nenad - Dapjas, Mihajlo)(YU)(en).tap' boulder.tap
wine ../tap2bin.exe boulder.tap
dd if=file1.bin of=boulder_lnk5768.bin bs=1 skip=258
