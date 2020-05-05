#!/usr/bin/env python3

# convert raw code from a file to orao snapshot

import struct
code=open('boulder1024_lnk5768.bin',"rb").read()
addr=1024
s = {"a":0,"x":0,"y":0,"flags":0,"sp":255,"pc":5768}
f = open("snapshot.orao","wb")
header = "ORAO_0AXYPS_PC_ADDR_LEN_DATA\0"
f.write(header.encode("utf-8"))
f.write(struct.pack("<BBBBBHHH",s["a"],s["x"],s["y"],s["flags"],s["sp"],s["pc"],addr,len(code)))
f.write(code)
f.close()
