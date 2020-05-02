# micropython ESP32
# SPI RAM test R/W

# AUTHOR=EMARD
# LICENSE=BSD

# this code is SPI master to FPGA SPI slave

# FIXME: *.z80 format unpacking
# https://www.worldofspectrum.org/faq/reference/z80format.htm

from machine import SPI, Pin
from micropython import const
from struct import unpack
from uctypes import addressof

class spiram:
  def __init__(self):
    self.led = Pin(5,Pin.OUT)
    self.led.off()
    self.rom="crt103.rom"
    self.spi_channel = const(2)
    self.init_pinout_sd()
    self.spi_freq = const(4000000)
    self.hwspi=SPI(self.spi_channel, baudrate=self.spi_freq, polarity=0, phase=0, bits=8, firstbit=SPI.MSB, sck=Pin(self.gpio_sck), mosi=Pin(self.gpio_mosi), miso=Pin(self.gpio_miso))

  @micropython.viper
  def init_pinout_sd(self):
    self.gpio_sck  = const(16)
    self.gpio_mosi = const(4)
    self.gpio_miso = const(12)

  # read from file -> write to SPI RAM
  def load_stream(self, filedata, addr=0, maxlen=0x10000, blocksize=1024):
    block = bytearray(blocksize)
    # Request load
    self.led.on()
    self.hwspi.write(bytearray([0,(addr >> 24) & 0xFF, (addr >> 16) & 0xFF, (addr >> 8) & 0xFF, addr & 0xFF]))
    bytes_loaded = 0
    while bytes_loaded < maxlen:
      if filedata.readinto(block):
        self.hwspi.write(block)
        bytes_loaded += blocksize
      else:
        break
    self.led.off()

  # read from SPI RAM -> write to file
  def save_stream(self, filedata, addr=0, length=1024, blocksize=1024):
    bytes_saved = 0
    block = bytearray(blocksize)
    # Request save
    self.led.on()
    self.hwspi.write(bytearray([1,(addr >> 24) & 0xFF, (addr >> 16) & 0xFF, (addr >> 8) & 0xFF, addr & 0xFF, 0]))
    while bytes_saved < length:
      self.hwspi.readinto(block)
      filedata.write(block)
      bytes_saved += len(block)
    self.led.off()

  def ctrl(self,i):
    self.led.on()
    self.hwspi.write(bytearray([0, 0xFF, 0xFF, 0xFF, 0xFF, i]))
    self.led.off()

  def cpu_halt(self):
    self.ctrl(2)

  def cpu_continue(self):
    self.ctrl(0)
    
  def store_rom(self,length=32):
    self.stored_code=bytearray(length)
    self.led.on()
    self.hwspi.write(bytearray([1, 0,0,(self.code_addr>>8)&0xFF,self.code_addr&0xFF, 0]))
    self.hwspi.readinto(self.stored_code)
    self.led.off()
    self.stored_vector=bytearray(2)
    self.led.on()
    self.hwspi.write(bytearray([1, 0,0,(self.vector_addr>>8)&0xFF,self.vector_addr&0xFF, 0]))
    self.hwspi.readinto(self.stored_vector)
    self.led.off()

  def restore_rom(self):
    self.led.on()
    self.hwspi.write(bytearray([0, 0,0,(self.code_addr>>8)&0xFF,self.code_addr&0xFF]))
    self.hwspi.write(self.stored_code)
    self.led.off()
    self.led.on()
    self.hwspi.write(bytearray([0, 0,0,(self.vector_addr>>8)&0xFF,self.vector_addr&0xFF]))
    self.hwspi.write(self.stored_vector)
    self.led.off()

  def patch_rom(self,header):
    # header = 0:X 1:Y 2:P 3:A 4-5:PC 6:SP
    # overwrite tape saving code in original ROM
    # with register restore code
    self.led.on()
    self.hwspi.write(bytearray([0, 0,0,(self.vector_addr>>8)&0xFF,self.vector_addr&0xFF, self.code_addr&0xFF, (self.code_addr>>8)&0xFF])) # overwrite reset vector at 0xFFFC
    self.led.off()
    self.led.on()
    self.hwspi.write(bytearray([0, 0,0,(self.code_addr>>8)&0xFF,self.code_addr&0xFF])) # overwrite code
    self.hwspi.write(bytearray([0x78,0xA2,header[6],0x9A,0xA2,header[0],0xA0,header[1],0xA9,header[2],0x48,0x28,0xA9,header[3],0x4C,header[4],header[5]]))
    self.led.off()
    self.led.on()

  def loadorao(self,filename):
    z=open(filename,"rb")
    header=bytearray(7)
    z.readinto(header)
    self.cpu_halt()
    self.load_stream(z,0)
    self.code_addr=0xE000
    self.vector_addr=0xFFFC
    self.store_rom(32)
    self.patch_rom(header)
    self.ctrl(3) # reset and halt
    self.ctrl(1) # only reset
    self.cpu_continue()
    # restore original ROM after image starts
    self.cpu_halt()
    self.restore_rom()
    self.cpu_continue() # release reset

def loadorao(filename):
  s=spiram()
  s.loadorao(filename)

def load(filename, addr=0):
  s=spiram()
  s.cpu_halt()
  s.load_stream(open(filename, "rb"), addr=addr)
  s.cpu_continue()

def save(filename, addr=0, length=0x8000):
  s=spiram()
  f=open(filename, "wb")
  s.cpu_halt()
  s.save_stream(f, addr, length)
  s.cpu_continue()
  f.close()

def ctrl(i):
  s=spiram()
  s.led.on()
  s.hwspi.write(bytearray([0, 0xFF, 0xFF, 0xFF, 0xFF, i]))
  s.led.off()
  
def peek(addr,length=1):
  s=spiram()
  s.cpu_halt()
  s.led.on()
  s.hwspi.write(bytearray([1,(addr >> 24) & 0xFF, (addr >> 16) & 0xFF, (addr >> 8) & 0xFF, addr & 0xFF, 0]))
  b=bytearray(length)
  s.hwspi.readinto(b)
  s.led.off()
  s.cpu_continue()
  return b

def poke(addr,data):
  s=spiram()
  s.cpu_halt()
  s.led.on()
  s.hwspi.write(bytearray([0,(addr >> 24) & 0xFF, (addr >> 16) & 0xFF, (addr >> 8) & 0xFF, addr & 0xFF]))
  s.hwspi.write(data)
  s.led.off()
  s.cpu_continue()

def help():
  print("spiram.load(\"file.bin\",addr=0)")
  print("spiram.save(\"file.bin\",addr=0,length=0x8000)")
