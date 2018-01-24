###################################################################
# Project Configuration: 
# 
# Specify the name of the design (project) and the Quartus II
# Settings File (.qsf)
###################################################################

PROJECT = project
TOP_LEVEL_ENTITY = main
ASSIGNMENT_FILES = $(PROJECT).qpf $(PROJECT).qsf

###################################################################
# Part, Family, Boardfile
FAMILY = "Cyclone IV E"
PART = EP4CE6E22C8
BOARDFILE = tb276.board
CONFIG_DEVICE = EPCS4
SERIAL_FLASH_LOADER_DEVICE = EP4CE6
OPENOCD_INTERFACE=interface/altera-usb-blaster.cfg
# OPENOCD_INTERFACE=ftdi-fpu1.ocd
#OPENOCD_INTERFACE=remote.ocd

###################################################################
#
# Quartus shell environment vars
#
###################################################################

quartus_env ?= . ../include/quartus_env.sh

# include makefile which does it all
include ../include/altera.mk

###################################################################
# Setup your sources here
SRCS = \
  ../../../altera/main-uk101_50MHz.vhd \
  ../../../UK101/uk101.vhd \
  ../../../UK101/CegmonRom.VHD  ../../../UK101/MonUK02Rom.VHD \
  ../../../UK101/BasicRom.vhd   ../../../UK101/CharRom.VHD    \
  ../../../UK101/ProgRam.vhd    ../../../UK101/DisplayRam.vhd \
  ../../../Components/M6502/T65_ALU.vhd    ../../../Components/M6502/T65.vhd \
  ../../../Components/M6502/T65_MCode.vhd  ../../../Components/M6502/T65_Pack.vhd \
  ../../../Components/TV/UK101TextDisplay.vhd \
  ../../../Components/PS2KB/ps2_intf.vhd      \
  ../../../Components/PS2KB/UK101keyboard.vhd \
  ../../../Components/UART/bufferedUART.vhd   \
