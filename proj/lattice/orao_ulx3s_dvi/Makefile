# ******* project, board and chip name *******
PROJECT = orao
BOARD = ulx3s
# 12 25 45 85
FPGA_SIZE = 12
FPGA_PACKAGE = 6bg381c
# config flash: 1:SPI (standard), 4:QSPI (quad)
FLASH_SPI = 4
# chip: is25lp032d is25lp128f s25fl164k
FLASH_CHIP = is25lp128f

# ******* if programming with OpenOCD *******
# using local latest openocd until in linux distribution
OPENOCD=openocd_ft232r
# default onboard usb-jtag
OPENOCD_INTERFACE=$(SCRIPTS)/ft231x.ocd
# ulx3s-jtag-passthru
#OPENOCD_INTERFACE=$(SCRIPTS)/ft231x2.ocd
# ulx2s
#OPENOCD_INTERFACE=$(SCRIPTS)/ft232r.ocd
# external jtag
#OPENOCD_INTERFACE=$(SCRIPTS)/ft2232.ocd

# ******* design files *******
CONSTRAINTS = constraints/ulx3s_v20_segpdi.lpf
TOP_MODULE = orao_ulx3s
TOP_MODULE_FILE = top/$(TOP_MODULE).vhd

CLK0_NAME = clk_25_250_125_25
CLK0_FILE_NAME = clocks/$(CLK0_NAME).v
CLK0_OPTIONS = \
  --module=$(CLK0_NAME) \
  --clkin=25 \
  --clkout0=250 \
  --clkout1=125 \
  --clkout2=25

VERILOG_FILES = \
  ../../../Components/HDMI/HDMI_OraoGraphDisplay8K.v \

VHDL_FILES = \
  $(TOP_MODULE_FILE) \
  clocks/clk_25_100_125_25.vhd \
  ../../../orao/orao_video_addr.vhd \
  ../../../orao/rom_bas103.vhd \
  ../../../orao/rom_crt103.vhd \
  ../../../generic/bram_1port.vhd \
  ../../../generic/bram_2port.vhd \
  ../../../generic/ProgSRam.vhd \
  ../../../Components/M6502/T65_ALU.vhd \
  ../../../Components/M6502/T65.vhd \
  ../../../Components/M6502/T65_MCode.vhd \
  ../../../Components/M6502/T65_Pack.vhd \
  ../../../Components/TV/OraoGraphDisplay8K.vhd \
  ../../../Components/PS2KB/ps2_intf.vhd \
  ../../../Components/PS2KB/orao_keyboard_buttons.vhd \
  ../../../Components/UART/bufferedUART.vhd \
  ../../../rtl_emard/generic/bram_true2p_1clk.vhd \
  ../../../rtl_emard/vga/vga.vhd \
  ../../../rtl_emard/vga/hdmi/vga2dvid.vhd \
  ../../../rtl_emard/vga/hdmi/tmds_encoder.vhd \
  ../../../rtl_emard/spdif/spdif_tx.vhd \
  ../../../rtl_emard/spi_ram/spi_ram_slave.vhd \

#  ../../../orao/orao_video_addr.vhd \
#  ../../../rtl_emard/osd/osd.vhd \
#  ../../../rtl_emard/osd/char_rom.vhd \
#  ../../../rtl_emard/vga/hdmi_out.vhd \
#  ../../../rtl_emard/vga/hdmi/ddr_dvid_out_se.vhd \
#  ../../../rtl_emard/vga/lattice/ecp5u/ddr_out.vhd \

SCRIPTS = ../scripts
include $(SCRIPTS)/trellis_path.mk
include $(SCRIPTS)/diamond_path.mk
include $(SCRIPTS)/diamond_main.mk
