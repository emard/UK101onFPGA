# ESP32

This works for orao64 (Makefile64k)

# Comfortable way

If you have a collection of "*.orao" snapshots
copy to SD card "osd.py", "ld_orao.py", 
"ecp5.py" (from esp32ecp5) and orao bitstream.

    import osd

Press all 4 direction buttons, OSD will appear.
Navigate to "*.orao" file or another bitstream.


# Easy way

Run [online ORAO emulator](http://orao.hrvoje.org) and load something e.g.

    LMEM "MMINER"

click "Save emulator state" at the bottom of web page,
about 4MB json file "emulator-state.bin" will be saved locally.
For ESP32 it has to be coverted to short binary form:

    ./emulator-state2orao2.py

A 64K file "snapshot.orao" will be created. Copy it to ESP32 and:

    import spiram
    spiram.loadorao("snapshot.orao")

It should start immediately.


# Medium way

Suppose you obtain some raw orao binary file "boulder1024_lnk5768.bin"
which should be loaded from offset 1024 and jumped to 5768.
Convert it to orao snapshot

    ./code2orao.py

A file "snapshot.orao" will be created,
use it as described above.

Edit "code2orao.py" to change offset, jump address and initial
register values.


# Hard way

On ESP32

    import uftpd

On linux we should prepare a RAW binary file which
is ORAO RAM content.

Download ["Boulder Dash" TAP file](http://retrospec.sgn.net/users/tomcat/yu/Orao_list.php)
and split it into separate fileX.bin files 
using [tap2bin tool](http://www.deltasoft.com.hr/retro/oraoutil.htm).

Analyze the content - ORAO first file loads by default at 0x400.
BASIC file typically starts with 0x20, and has some ASCII numbers
that follow, probably representing number of bytes.
First file then may load second file, using LMEM
"FILENAME",OFFSET where FILENAME and OFFSET are optional
parameters in human-readable ASCII,
default FILENAME="" and OFFSET=1024 if unspecified.
Also it can then execute machine code using LNK START, where START
is human-readable parameter visible as ASCII string in hexdump,

See "5768" in boulder file0.bin:

    hexdump -C file0.bin | less
    00000000  1b 1b 1b 1b 4f 42 2e 44  41 53 48 20 20 20 20 00  |....OB.DASH    .|
    00000010  00 00 5a 00 20 20 20 20  20 20 20 20 20 20 20 20  |..Z.            |
    00000020  20 20 20 20 20 20 20 20  20 20 20 20 20 20 20 20  |                |
    *
    00000100  5b 01 4c 00 c9 4c 87 cf  22 22 22 00 00 00 04 00  |[.L..L..""".....|
    00000110  00 52 00 00 20 1e 5a 00  89 00 4e 00 20 20 20 20  |.R.. .Z...N.    |
    00000120  20 20 20 20 20 20 20 20  20 20 20 20 20 20 20 20  |                |
    00000130  20 20 3a cc 22 62 64 63  6f 64 65 22 3a c9 35 37  |  :."bdcode":.57| <-- LMEM "bdcode":LNK 5768
    00000140  36 38 00 00 38 31 00 00  ea ea ea ea ea ea ea ea  |68..81..........|
    00000150  ea ea ea ea ea ea ea ea  ea fe 0c 40 00 03 ff     |...........@...|
    0000015f

And the second file has executable content starting from file
offset 0x102 (0x20 byte) until the end of file.

    hexdump -C file1.bin | less
    00000000  1b 1b 1b 1b 4f 62 64 63  6f 64 65 20 20 20 20 00  |....Obdcode    .| <-- "bdcode" file
    00000010  00 04 80 3e 20 20 20 20  20 20 20 20 20 20 20 20  |...>            |
    00000020  20 20 20 20 20 20 20 20  20 20 20 20 20 20 20 20  |                |
    *
    00000100  81 3f 20 31 35 38 37 32  00 30 30 30 30 24 24 24  |.? 15872.0000$$$| <-- byte 0x20 at 0x102 to ORAO at 0x400
    00000110  24 24 00 00 8c 1e 78 1e  82 1e 00 00 7b 1f 00 00  |$$....x.....{...|

So from 0x102 to the end of file we should write to ORAO 
RAM starting at 0x400 and then execute "LNK 5768" from
ORAO BASIC.

For boulder, this is the final procedure, others may vary:

    unzip 'Boulder Dash (19xx)(Mihailovic, Nenad - Dapjas, Mihajlo)(YU)(en).zip'
    mv -f 'Boulder Dash (19xx)(Mihailovic, Nenad - Dapjas, Mihajlo)(YU)(en).tap' boulder.tap
    wine tap2bin.exe boulder.tap
    dd if=file1.bin of=boulder1024_lnk5768.bin bs=1 skip=258

or even directly from TAP file, (without tap2bin tool),
we can get the same result:

    dd if=boulder.tap of=boulder1024_lnk5768 bs=1 skip=1996

Upload it to ESP32

    ftp> put boulder1024_lnk5768.bin

On ESP32

    import ps2recv
    import spiram

On linux

    ./linux_keyboard.py (edit IP address)

On ORAO

    BC<enter>
    <enter>
    <enter>
    <enter>

On ESP32

    spiram.load("boulder1024_lnk5768.bin",1024)

On ORAO

    LNK 5768

"Boulder" game should start

    <enter> start gate
    H enter level
    1 up
    Q down
    Š left
    Đ right
