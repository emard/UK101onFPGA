----------------------------
-- ULX3S Top level for UK101
-- http://github.com/emard
----------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

library ecp5u;
use ecp5u.components.all;

entity uk101_ulx3s is
generic
(
  C_sound: boolean := false -- enable sound output
);
port
(
  clk_25MHz: in std_logic;  -- main clock input from 25MHz clock source

  -- UART0 (FTDI USB slave serial)
  ftdi_rxd: out   std_logic;
  ftdi_txd: in    std_logic;
  -- FTDI additional signaling
  ftdi_ndsr: inout  std_logic;
  ftdi_nrts: inout  std_logic;
  ftdi_txden: inout std_logic;

  -- UART1 (WiFi serial)
  wifi_rxd: out   std_logic;
  wifi_txd: in    std_logic;
  -- WiFi additional signaling
  wifi_en: inout  std_logic := 'Z'; -- '0' will disable wifi by default
  wifi_gpio0, wifi_gpio2, wifi_gpio16, wifi_gpio17: inout std_logic := 'Z';

  -- ADC MAX11123
  adc_csn, adc_sclk, adc_mosi: out std_logic;
  adc_miso: in std_logic;

  -- SDRAM
  sdram_clk: out std_logic;
  sdram_cke: out std_logic;
  sdram_csn: out std_logic;
  sdram_rasn: out std_logic;
  sdram_casn: out std_logic;
  sdram_wen: out std_logic;
  sdram_a: out std_logic_vector (12 downto 0);
  sdram_ba: out std_logic_vector(1 downto 0);
  sdram_dqm: out std_logic_vector(1 downto 0);
  sdram_d: inout std_logic_vector (15 downto 0);

  -- Onboard blinky
  led: out std_logic_vector(7 downto 0);
  btn: in std_logic_vector(6 downto 0);
  sw: in std_logic_vector(3 downto 0);
  oled_csn, oled_clk, oled_mosi, oled_dc, oled_resn: out std_logic;

  -- GPIO
  gp, gn: inout std_logic_vector(27 downto 0);

  -- SHUTDOWN: logic '1' here will shutdown power on PCB >= v1.7.5
  shutdown: out std_logic := '0';

  -- Audio jack 3.5mm
  audio_l, audio_r, audio_v: inout std_logic_vector(3 downto 0) := (others => 'Z');

  -- Onboard antenna 433 MHz
  ant_433mhz: out std_logic;

  -- Digital Video (differential outputs)
  gpdi_dp, gpdi_dn: out std_logic_vector(2 downto 0);
  gpdi_clkp, gpdi_clkn: out std_logic;

  -- i2c shared for digital video and RTC
  gpdi_scl, gpdi_sda: inout std_logic;

  -- US2 port
  usb_fpga_dp, usb_fpga_dn: inout std_logic;

  -- Flash ROM (SPI0)
  -- commented out because it can't be used as GPIO
  -- when bitstream is loaded from config flash
  --flash_miso   : in      std_logic;
  --flash_mosi   : out     std_logic;
  --flash_clk    : out     std_logic;
  --flash_csn    : out     std_logic;

  -- SD card (SPI1)
  sd_dat3_csn, sd_cmd_di, sd_dat0_do, sd_dat1_irq, sd_dat2: inout std_logic;
  sd_clk: out std_logic;
  sd_cdn, sd_wp: in std_logic
	
);
end;

architecture struct of uk101_ulx3s is
        -- enable either test or computer, not both
        constant test:        std_logic := '0'; -- 1: generate only video test screen, no computer

        signal reset_n: std_logic;

	alias ps2_clk : std_logic is usb_fpga_dp;
	alias ps2_dat : std_logic is usb_fpga_dn;

        component hdmi_uk101textdisplay2k is
        port
        (
          clk_pixel, clk_tmds: in std_logic;
          dispAddr: out std_logic_vector(10 downto 0);
          dispData: in std_logic_vector(7 downto 0);
          charAddr: out std_logic_vector(10 downto 0);
          charData: in std_logic_vector(7 downto 0);
          vga_video, vga_hsync, vga_vsync, vga_blank: out std_logic;
          TMDS_out_RGB: out std_logic_vector(2 downto 0)
        );
        end component;

        signal dispAddr         : std_logic_vector(10 downto 0);
        signal dispData         : std_logic_vector(7 downto 0);
	signal charAddr         : std_logic_vector(10 downto 0);
	signal charData         : std_logic_vector(7 downto 0);

	signal clk_pixel, clk_pixel_shift, clkn_pixel_shift: std_logic;

	signal ram_in, ram_out : std_logic_vector(7 downto 0); -- dq is bidirectional
	signal ram_cen : std_logic;
	signal ram_we, ram_wen : std_logic;
	
	signal S_vga_r, S_vga_g, S_vga_b: std_logic_vector(0 downto 0);
	signal S_vga_vsync, S_vga_hsync: std_logic;
	signal S_vga_vblank, S_vga_blank: std_logic;
	signal ddr_d: std_logic_vector(2 downto 0);
	signal ddr_clk: std_logic;
	signal dvid_red, dvid_green, dvid_blue, dvid_clock: std_logic_vector(1 downto 0);

	signal audio_data : std_logic_vector(17 downto 0);
	signal S_audio: std_logic_vector(23 downto 0) := (others => '0');
	signal S_spdif_out: std_logic;
begin
  wifi_gpio0 <= btn(0); -- holding reset for 2 sec will activate ESP32 loader
  reset_n <= btn(0); -- btn(0) has inverted logic so direct to reset_n

  clkgen: entity work.clk_25_100_125_25
    port map
    (
      clki => clk_25MHz,         --  25 MHz input from board
      clkop => clk_pixel_shift,  -- 125 MHz
      clkos => clkn_pixel_shift, -- 125 MHz inverted
      clkos2 => clk_pixel        --  25 MHz
    );

  video_test: if test = '1' generate
    -- press btn_down to show only "0x55" on screen
    dispData <= dispAddr(7 downto 0) when btn(0)='0' else x"55";
  end generate;

  videochip: hdmi_uk101textdisplay2k
    port map
    (
		clk_pixel => clk_pixel,
		clk_tmds  => '0',
		dispAddr  => dispAddr,
		dispData  => dispData,
		charAddr  => charAddr,
		charData  => charData,
		vga_video => S_vga_g(0),
		vga_hsync => S_vga_hsync,
		vga_vsync => S_vga_vsync,
		vga_blank => S_vga_blank
    );
    char_rom: entity work.CharRom
	port map (
          address => charAddr,
          q => charData
	);

    uk101_computer: if test = '0' generate
	computer_module: entity work.uk101va
	generic map
	(
	  clk_mhz => 25,
	  serial_baud => 9600,
	  external_sram => 0
	)
	port map(
                clk       => clk_pixel,
                n_reset   => reset_n,
		txd       => ftdi_rxd,
		rxd       => ftdi_txd,
		rts       => ftdi_nrts,
		ps2Clk    => ps2_clk,
		ps2Data   => ps2_dat,
		key_enter => btn(6),
		key_b     => btn(3),
		key_c     => btn(4),
                --sram_lbl  => sram_lbl,
                --sram_ubl  => sram_ubl,
                --sram_wel  => sram_wel,
                --sram_a    => sram_a,
                --sram_d    => sram_d,
                videoAddr => dispAddr, -- input from video
                videoData => dispData  -- output to video
	);
	end generate;
  
  S_vga_r <= S_vga_g;
  S_vga_b <= S_vga_g; 

  vga2dvi_converter: entity work.vga2dvid
  generic map
  (
      C_ddr     => true,
      C_depth   => 1 -- 1bpp (1 bit per pixel)
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

  -- this module instantiates vendor specific modules ddr_out to
  -- convert SDR 2-bit input to DDR clocked 1-bit output (single-ended)
  G_vgatext_ddrout: entity work.ddr_dvid_out_se
  port map
  (
    clk       => clk_pixel_shift,
    clk_n     => clkn_pixel_shift,
    in_red    => dvid_red,
    in_green  => dvid_green,
    in_blue   => dvid_blue,
    in_clock  => dvid_clock,
    out_red   => ddr_d(2),
    out_green => ddr_d(1),
    out_blue  => ddr_d(0),
    out_clock => ddr_clk
  );

  gpdi_data_channels: for i in 0 to 2 generate
    gpdi_diff_data: OLVDS
    port map(A => ddr_d(i), Z => gpdi_dp(i), ZN => gpdi_dn(i));
  end generate;
  gpdi_diff_clock: OLVDS
  port map(A => ddr_clk, Z => gpdi_clkp, ZN => gpdi_clkn);
  
  led(0) <= reset_n;

end struct;
