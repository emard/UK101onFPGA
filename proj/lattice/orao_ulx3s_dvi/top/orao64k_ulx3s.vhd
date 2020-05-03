----------------------------
-- ULX3S Top level for ORAO
-- http://github.com/emard
----------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

library ecp5u;
use ecp5u.components.all;

entity orao64k_ulx3s is
generic
(
  C_sound: boolean := false -- enable sound output
);
port
(
  clk_25mhz: in std_logic;  -- main clock input from 25MHz clock source

  -- UART0 (FTDI USB slave serial)
  ftdi_rxd: out   std_logic;
  ftdi_txd: in    std_logic;
  -- FTDI additional signaling
  --ftdi_ndsr: inout  std_logic;
  --ftdi_nrts: inout  std_logic;
  --ftdi_txden: inout std_logic;

  -- UART1 (WiFi serial)
  wifi_rxd: out   std_logic;
  wifi_txd: in    std_logic;
  -- WiFi additional signaling
  wifi_en: inout  std_logic := 'Z'; -- '0' will disable wifi by default
  wifi_gpio0, wifi_gpio5, wifi_gpio16, wifi_gpio17: inout std_logic := 'Z';

  -- ADC MAX11123
  --adc_csn, adc_sclk, adc_mosi: out std_logic;
  --adc_miso: in std_logic;

  -- SDRAM
  --sdram_clk: out std_logic;
  --sdram_cke: out std_logic;
  --sdram_csn: out std_logic;
  --sdram_rasn: out std_logic;
  --sdram_casn: out std_logic;
  --sdram_wen: out std_logic;
  --sdram_a: out std_logic_vector (12 downto 0);
  --sdram_ba: out std_logic_vector(1 downto 0);
  --sdram_dqm: out std_logic_vector(1 downto 0);
  --sdram_d: inout std_logic_vector (15 downto 0);

  -- Onboard blinky
  led: out std_logic_vector(7 downto 0);
  btn: in std_logic_vector(6 downto 0);
  --sw: in std_logic_vector(3 downto 0);
  --oled_csn, oled_clk, oled_mosi, oled_dc, oled_resn: out std_logic;

  -- GPIO
  gp, gn: inout std_logic_vector(27 downto 0);

  -- SHUTDOWN: logic '1' here will shutdown power on PCB >= v1.7.5
  shutdown: out std_logic := '0';

  -- Audio jack 3.5mm
  audio_l, audio_r, audio_v: inout std_logic_vector(3 downto 0) := (others => 'Z');

  -- Onboard antenna 433 MHz
  --ant_433mhz: out std_logic;

  -- Digital Video (differential outputs)
  gpdi_dp: out std_logic_vector(3 downto 0);

  -- i2c shared for digital video and RTC
  --gpdi_scl, gpdi_sda: inout std_logic;

  -- US2 port
  usb_fpga_dp, usb_fpga_dn: inout std_logic;
  usb_fpga_pu_dp, usb_fpga_pu_dn: out std_logic;

  -- Flash ROM (SPI0)
  -- commented out because it can't be used as GPIO
  -- when bitstream is loaded from config flash
  --flash_miso   : in      std_logic;
  --flash_mosi   : out     std_logic;
  --flash_clk    : out     std_logic;
  --flash_csn    : out     std_logic;

  -- SD card (SPI1)
  sd_d: inout std_logic_vector(3 downto 0) := (others => 'Z');
  sd_clk, sd_cmd: inout std_logic := 'Z';
  sd_cdn, sd_wp: inout std_logic := 'Z'
);
end;

architecture struct of orao64k_ulx3s is
        signal reset_n: std_logic;

        -- US2
	alias ps2_clk : std_logic is usb_fpga_dp;
	alias ps2_dat : std_logic is usb_fpga_dn;
	-- ESP32 ps2tn.py or ps2recv.py
	--alias ps2_clk : std_logic is gp(11);
	--alias ps2_dat : std_logic is gn(11);
	
	-- ESP32 SPI loader

	signal clk_pixel, clk_pixel_shift, clkn_pixel_shift: std_logic;

	signal ram_in, ram_out : std_logic_vector(7 downto 0); -- dq is bidirectional
	signal ram_cen : std_logic;
	signal ram_we, ram_wen : std_logic;

	signal S_vga_r, S_vga_g, S_vga_b: std_logic_vector(7 downto 0);
	signal S_vga_vsync, S_vga_hsync: std_logic;
	signal S_vga_vblank, S_vga_blank: std_logic;
	signal ddr_d: std_logic_vector(3 downto 0);
	signal dvid_red, dvid_green, dvid_blue, dvid_clock: std_logic_vector(1 downto 0);

        signal S_csn, S_btn_irq: std_logic;
        signal S_beep: std_logic;
begin
  wifi_gpio0 <= not S_btn_irq; -- holding reset for 2 sec will activate ESP32 loader
  reset_n <= btn(0); -- btn(0) has inverted logic so direct to reset_n
  ftdi_rxd <= wifi_txd;
  wifi_rxd <= ftdi_txd;

  clkgen: entity work.clk_25_100_125_25
    port map
    (
      clki => clk_25MHz,         --  25 MHz input from board
      clkop => clk_pixel_shift,  -- 125 MHz
      clkos => clkn_pixel_shift, -- 125 MHz inverted
      clkos2 => clk_pixel        --  25 MHz
    );

        -- disable SD card by pullup
        sd_d(3) <= 'Z';
        S_csn <= not wifi_gpio5; -- not wifi LED
        -- pullups required for PS/2
        usb_fpga_pu_dp <= '1';
        usb_fpga_pu_dn <= '1';
	computer_module: entity work.orao64k
	generic map(
	  clk_mhz => 25,
	  ram_kb => 24
	)
	port map(
                clk       => clk_pixel,
                n_reset   => reset_n,
		txd       => open, -- ftdi_rxd,
		rxd       => '1',  -- ftdi_txd,
		rts       => open, -- ftdi_nrts,
		ps2Clk    => ps2_clk,
		ps2Data   => ps2_dat,
		spi_csn   => S_csn,
		spi_sclk  => wifi_gpio16,
		spi_mosi  => sd_d(1),  -- wifi_gpio4
		spi_miso  => sd_d(2),  -- wifi_gpio12
		btn_irq   => S_btn_irq,
		btn       => btn,
		key_enter => btn(6),
		key_b     => btn(3),
		key_c     => btn(4),
		beep      => S_beep,
		vga_r     => S_vga_r,
		vga_g     => S_vga_g,
		vga_b     => S_vga_b,
                vga_hsync => S_vga_hsync,
                vga_vsync => S_vga_vsync,
                vga_blank => S_vga_blank
	);
  
  audio_l(3 downto 1) <= (others => '0');
  audio_l(0) <= S_beep;
  audio_r(3 downto 1) <= (others => '0');
  audio_r(0) <= S_beep;

  vga2dvi_converter: entity work.vga2dvid
  generic map
  (
      C_ddr     => true,
      C_depth   => 8 -- 8bpp (bit per each RGB channel)
  )
  port map
  (
      clk_pixel => clk_pixel, -- 25 MHz
      clk_shift => clk_pixel_shift, -- 5*25 MHz

      in_red   => S_vga_r,
      in_green => S_vga_g,
      in_blue  => S_vga_b,

      in_hsync => S_vga_hsync,
      in_vsync => S_vga_vsync,
      in_blank => S_vga_blank,

      -- single-ended output ready for differential buffers
      out_red   => dvid_red,
      out_green => dvid_green,
      out_blue  => dvid_blue,
      out_clock => dvid_clock
  );

  led(0) <= reset_n;
  led(1) <= S_btn_irq;

  -- vendor specific DDR modules
  -- convert SDR 2-bit input to DDR clocked 1-bit output (single-ended)
  ddr_clock: ODDRX1F port map (D0=>dvid_clock(0), D1=>dvid_clock(1), Q=>gpdi_dp(3), SCLK=>clk_pixel_shift, RST=>'0');
  ddr_red:   ODDRX1F port map (D0=>dvid_red(0),   D1=>dvid_red(1),   Q=>gpdi_dp(2), SCLK=>clk_pixel_shift, RST=>'0');
  ddr_green: ODDRX1F port map (D0=>dvid_green(0), D1=>dvid_green(1), Q=>gpdi_dp(1), SCLK=>clk_pixel_shift, RST=>'0');
  ddr_blue:  ODDRX1F port map (D0=>dvid_blue(0),  D1=>dvid_blue(1),  Q=>gpdi_dp(0), SCLK=>clk_pixel_shift, RST=>'0');

end struct;
