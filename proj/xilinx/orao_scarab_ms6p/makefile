project = miniSpartan6-plus
vendor = xilinx
family = spartan6
part = xc6slx25-ftg256-3 # last number -3 is speed grade
flashsize = 8192 # KB (kilobytes) - SPI flash device is M25P40
top_module = main_orao
isedir = /usr/local/xilinx/14.7/ISE_DS
SHELL = /bin/bash
# openocd_interface = interface/altera-usb-blaster.cfg
# openocd_interface = ../include/ft2232-fpu1.ocd
openocd_interface = ../include/ft2232-generic.ocd
xc3sprog_interface = ftdi

# ../../../xilinx/glue_xc6slx9.vhd \

vhdfiles = \
  ../../../xilinx/pll_50M_250M_25M.vhd \
  ../../../orao/orao_video_addr.vhd \
  ../../../generic/ROMgeneric.vhd \
  ../../../generic/bram_1port.vhd \
  ../../../generic/bram_2port.vhd \
  ../../../generic/ProgSRam.vhd \
  ../../../Components/M6502/T65_ALU.vhd \
  ../../../Components/M6502/T65.vhd \
  ../../../Components/M6502/T65_MCode.vhd \
  ../../../Components/M6502/T65_Pack.vhd \
  ../../../Components/PS2KB/ps2_intf.vhd \
  ../../../Components/PS2KB/orao_keyboard_buttons.vhd \
  ../../../Components/UART/bufferedUART.vhd \


vfiles = \
  ../../../xilinx/main_scarab_orao.v \
  ../../../generic/rom_generic.v \
  ../../../Components/HDMI/HDMI_OraoGraphDisplay8K.v \


include ../include/xilinx.mk
