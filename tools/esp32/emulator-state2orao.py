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
  f.write(struct.pack("<BBBBHB",s["x"],s["y"],s["flags"],s["a"],s["pc"],s["sp"]))
  f.write(bytearray(s["memory"]))
  f.close()
