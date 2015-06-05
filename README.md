# UK101 and ORAO on FPGA

A fork of Grant Seale's https://twitter.com/zx80nut 
great work for emulation of Compukit UK101 on FPGA
https://www.youtube.com/watch?v=0S_cR3xW2UU
downloaded from UK101 page 
http://searle.hostei.com/grant/uk101FPGA/index.html

UK101 is used as the base for emulating ORAO computer on FPGA.
![ORAO](/pic/orao.jpg)
http://en.wikipedia.org/wiki/Orao_%28computer%29

ORAO was created as an upgrade of GALEB with 
256x256 bitmap graphics framebuffer and more RAM.
GALEB has been also known as YU101.
YU101 was similar to UK101.

# Connecting

The emulator generates PAL 50Hz composite video signal
using simple mixer with 2 resistors:

    SYNC pin  --   1 k   -- composite video
    VIDEO pin -- 470 ohm -- composite video

It can be displayed on TV with composite input (yellow cinch)
or projectors.

ULX2S FPGA board has already video mixer with suitable resistors
that outputs video signal to left channel (tip) of 3.5mm stereo jack. 
With a suitable cable it can be connected directly. 
Yellow connector is usually for video.

![Cable 3.5mm to Video](/pic/cable-3.5mm-video-cinch.jpg)

ULX2S also has has several push buttons which can be used to enter BASIC.

For some better typing experience, PS/2 keyboard can be connected.
Although rated for 5V, most PS/2 keyboard will work with 3.3V
supplied from FPGA board. CLK and DATA need 1k pullup resistors:

    PS/2 CLK  (ULX2S pin 8) -- 1k -- 3.3V
    PS/2 DATA (ULX2S pin 9) -- 1k -- 3.3V 


# UK101 TB276 Altera Cyclone-4

To compile original UK101 for TB279 board (Altera Cyclone-4)
Prerequisite: Altera Quartus-II (I have 13.0sp1) and then

    cd proj/altera/uk101_tb276_bram
    make
    make program # upload to FPGA RAM
    make flash   # upload to config flash

It compiles but I haven't actually tested it :)

# UK101 64K RAM 64x32 screen ULX2S Lattice XP2

For quickstart flash the bitstream:

    cd proj/lattice/uk101_64x32_ulx2s_sram
    unzip UK101-64K-64x32-ULX2S-8E.zip
    ujprog -j flash UK101-64K-64x32-ULX2S-8E.jed

On next power up board will become UK101

To compile UK101 with 64K RAM (BASIC reports 40K free) 
and 2K extended screen size of 64x32 chars for ULX2S 
board (Lattice XP2).
Prerequisite: Latice Diamond (I have 3.4)

    cd proj/lattice/uk101_64x32_ulx2s_sram
    make
    make program # upload to FPGA RAM
    make flash   # upload to config flash

To enter BASIC:
After reset it will prompt

Press C (right button)

Press ENTER (middle button) twice

On screen:

    CEGMON (D/C/W/M) <press c>

    MEMORY SIZE? <press enter>
    TERMINAL WIDTH? <press enter>
    
    40191 BYTES FREE
    
    C O M P U K I T  U K 1 0 1
    
    Personal computer
    8K Basic Copyright1979
    OK

# ORAO 32K RAM 256x256 screen ULX2S Lattice XP2

For quickstart flash the bitstream:

    cd proj/lattice/orao_ulx2s_sram
    unzip ORAO-103-32K-ULX2S-8E.zip
    ujprog -j flash ORAO-103-32K-ULX2S-8E.jed

On next power up board will become ORAO 103

To compile ORAO with 32K RAM (BASIC reports 23K free) 
and 8K graphics screen size of 256x256 pixels for ULX2S 
board (Lattice XP2)
Prerequisite: Lattice Diamond (I have 3.4)

    cd proj/lattice/orao_ulx2s_sram
    make
    make program # upload to FPGA RAM
    make flash   # upload to config flash

To enter BASIC
After reset it will prompt *_ (underscore cursor blinking).

Press B (left button)

Press C (right button)

Press ENTER twice (center button)

It will start BASIC

on screen:

    *BC_ <press enter>

    >EAGLE< EXTENDED BASIC    
    V 1.0 (C) 85

    MEM SIZE? _ <press enter>

    23534 BYTES FREE
    _

# Online documentation

CEGMON manual:
http://www.osiweb.org/manuals/cegmon.pdf

UK101 manual
http://www.compukit.org/images/8/8e/Compukit-manual.pdf

# Similar projects

Orao Emulator (Perl)
http://svn.rot13.org/index.cgi/VRac

Orao Emulator (Pascal)
http://www.deltasoft.com.hr/retro/oraoemu.htm

Orao Emulator (SAM)
https://github.com/simonowen/oraoemu