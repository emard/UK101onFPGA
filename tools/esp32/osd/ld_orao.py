# micropython ESP32
# ORAO RAM/ROM snapshot image loader

# AUTHOR=EMARD
# LICENSE=BSD

from struct import unpack

class ld_orao:
  def __init__(self,spi,cs):
    self.spi=spi
    self.cs=cs
    self.cs.off()

  # LOAD/SAVE and CPU control

  # read from file -> write to SPI RAM
  def load_stream(self, filedata, addr=0, maxlen=0x10000, blocksize=1024):
    block = bytearray(blocksize)
    # Request load
    self.cs.on()
    self.spi.write(bytearray([0,(addr >> 24) & 0xFF, (addr >> 16) & 0xFF, (addr >> 8) & 0xFF, addr & 0xFF]))
    bytes_loaded = 0
    while bytes_loaded < maxlen:
      if filedata.readinto(block):
        self.spi.write(block)
        bytes_loaded += blocksize
      else:
        break
    self.cs.off()

  # read from SPI RAM -> write to file
  def save_stream(self, filedata, addr=0, length=1024, blocksize=1024):
    bytes_saved = 0
    block = bytearray(blocksize)
    # Request save
    self.cs.on()
    self.spi.write(bytearray([1,(addr >> 24) & 0xFF, (addr >> 16) & 0xFF, (addr >> 8) & 0xFF, addr & 0xFF, 0]))
    while bytes_saved < length:
      self.spi.readinto(block)
      filedata.write(block)
      bytes_saved += len(block)
    self.cs.off()

  def ctrl(self,i):
    self.cs.on()
    self.spi.write(bytearray([0, 0xFF, 0xFF, 0xFF, 0xFF, i]))
    self.cs.off()

  def cpu_halt(self):
    self.ctrl(2)

  def cpu_continue(self):
    self.ctrl(0)

  def store_rom(self,length=32):
    self.stored_code=bytearray(length)
    self.cs.on()
    self.spi.write(bytearray([1, 0,0,(self.code_addr>>8)&0xFF,self.code_addr&0xFF, 0]))
    self.spi.readinto(self.stored_code)
    self.cs.off()
    self.stored_vector=bytearray(2)
    self.cs.on()
    self.spi.write(bytearray([1, 0,0,(self.vector_addr>>8)&0xFF,self.vector_addr&0xFF, 0]))
    self.spi.readinto(self.stored_vector)
    self.cs.off()

  def restore_rom(self):
    self.cs.on()
    self.spi.write(bytearray([0, 0,0,(self.code_addr>>8)&0xFF,self.code_addr&0xFF]))
    self.spi.write(self.stored_code)
    self.cs.off()
    self.cs.on()
    self.spi.write(bytearray([0, 0,0,(self.vector_addr>>8)&0xFF,self.vector_addr&0xFF]))
    self.spi.write(self.stored_vector)
    self.cs.off()

  def patch_rom(self,regs):
    # regs   = 0:A 1:X 2:Y 3:P 4:S 5-6:PC
    # overwrite with register restore code
    self.cs.on()
    self.spi.write(bytearray([0, 0,0,(self.vector_addr>>8)&0xFF,self.vector_addr&0xFF, self.code_addr&0xFF, (self.code_addr>>8)&0xFF])) # overwrite reset vector at 0xFFFC
    self.cs.off()
    self.cs.on()
    self.spi.write(bytearray([0, 0,0,(self.code_addr>>8)&0xFF,self.code_addr&0xFF])) # overwrite code
    self.spi.write(bytearray([0x78,0xA2,regs[4],0x9A,0xA2,regs[1],0xA0,regs[2],0xA9,regs[3],0x48,0x28,0xA9,regs[0],0x4C,regs[5],regs[6]]))
    self.cs.off()
    self.cs.on()

  def loadorao(self,filename):
    z=open(filename,"rb")
    expect=bytearray("ORAO_0AXYPS_PC_ADDR_LEN_DATA\0")
    header=bytearray(len(expect))
    z.readinto(header)
    if header==expect:
      del expect,header
      regs=bytearray(11)
      z.readinto(regs)
      addr=unpack("<H",regs[7:9])[0]
      length=unpack("<H",regs[9:11])[0]
      if length==0:
        length=0x10000
      self.cpu_halt()
      self.load_stream(z,addr,length)
      self.code_addr=0xE000
      self.vector_addr=0xFFFC
      self.store_rom(32)
      self.patch_rom(regs)
      self.ctrl(3) # reset and halt
      self.ctrl(1) # only reset
      self.cpu_continue()
      # restore original ROM after image starts
      self.cpu_halt()
      self.restore_rom()
      self.cpu_continue() # release reset
    else:
      print("unrecognized header")
      print("header:", header)
      print("expected:", expect)
