#!/usr/bin/env python3

# from online orao emulator
# http://orao.hrvoje.org
# click "Save emulator state" at bottom of the page.
# run this script to convert it to a binary snapshot
# suitable for esp32 micropython loader
# spiram.loadorao("filename")

import struct
import json
with open('emulator-state.bin') as json_file:
  s = json.load(json_file)
  f = open("snapshot.orao","wb")
  header = "ORAO_0AXYPS_PC_ADDR_LEN_DATA\0"
  f.write(header.encode("utf-8"))
  f.write(struct.pack("<BBBBBHHH",s["a"],s["x"],s["y"],s["flags"],s["sp"],s["pc"],0,0))
  f.write(bytearray(s["memory"]))
  f.close()
