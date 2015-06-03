# UK101 and ORAO on FPGA

A fork of Grant Seale's great work
for emulation of Compukit UK101 on FPGA
downloaded from UK101 page at http://searle.hostei.com/grant/uk101FPGA/index.html

UK101 is used as the base for emulating ORAO computer on FPGA.
http://en.wikipedia.org/wiki/Orao_%28computer%29

ORAO was created as an upgrade of GALEB with 
256x256 bitmap graphics framebuffer and more RAM.
GALEB has been also known as YU101.
YU101 was UK101 compatible.

# UK101 TB276 Altera Cyclone-4

To compile original UK101 for TB279 board (Altera Cyclone-4)
Prerequisite: Altera Quartus-II (I have 13.0sp1) and then

    cd proj/altera/uk101_tb276_bram
    make
    make program # upload to FPGA RAM
    make flash   # upload to config flash

It compiles but I haven't actually tested it :)

# UK101 64K RAM 64x32 screen ULX2S Lattice XP2

To compile UK101 with 64K RAM (BASIC reports 40K free) 
and 2K extended screen size of 64x32 chars for ULX2S 
board (Lattice XP2).
Prerequisite: Latice Diamond (I have 3.4)

    cd proj/lattice/uk101_64x32_ulx2s_sram
    make
    make program # upload to FPGA RAM
    make flash   # upload to config flash

To enter BASIC:
After reset it will prompt CEGMON (D/C/W/M)
Press C (right button)
Press ENTER (middle button) twice
It will run RAM self-test and should report 40191 bytes free.

# ORAO 32K RAM 256x256 screen ULX2S Lattice XP2

To compile ORAO with 32K RAM (BASIC reports 23K free) 
and 8K graphics screen size of 256x256 pixels for ULX2S 
board (Lattice XP2)
Prerequisite: Latice Diamond (I have 3.4)

    cd proj/lattice/orao_ulx2s_sram
    make
    make program # upload to FPGA RAM
    make flash   # upload to config flash

To enter BASIC
After reset it will prompt *_ (underscore cursor blinking).
Press B (left button)
Press C (right button)
Press ENTER (center button)
It will run RAM self-test and should report 23534 bytes free.

# Online documentation

CEGMON manual:
http://www.osiweb.org/manuals/cegmon.pdf

UK101 manual
http://www.compukit.org/images/8/8e/Compukit-manual.pdf
