-- UK101 computer Altera code by Grant Searle
-- ported to Lattice board ULX2S by EMARD
-- see details on
-- http://searle.hostei.com/grant/uk101FPGA/index.html

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity main is
	port(
		clk_25MHz	: in std_logic;
		btn_center, btn_up, btn_down, btn_left, btn_right: in std_logic; -- btn_down is reset
		pin_2           : out std_logic; -- txd
		pin_3           : in std_logic;  -- rxd
		pin_4           : out std_logic; -- rts
		pin_8           : in std_logic;  -- ps2Clk
		pin_9           : in std_logic;  -- ps2Data
		sram_wel, sram_lbl, sram_ubl: out std_logic; -- onboard SRAM
		sram_a          : out std_logic_vector(18 downto 0);
		sram_d          : inout std_logic_vector(15 downto 0); 
                -- vga
                pin_37, pin_36, pin_35: out std_logic; -- vga_pin1 red   MSB..LSB 0.47K, 1K, 2.2K
                pin_34, pin_33, pin_32: out std_logic; -- vga_pin2 green MSB..LSB 0.47K, 1K, 2.2K
                pin_31, pin_30, pin_29: out std_logic; -- vga_pin3 blue  MSB..LSB 0.47K, 1K, 2.2K
                pin_28: out std_logic;  -- vga_pin13 hsync direct (TTL)
                pin_27: out std_logic;  -- vga_pin14 vsync direct (TTL)
		p_tip		: out std_logic_vector(3 downto 0); -- video
		led		: out std_logic_vector(7 downto 0)
	);
end main;

architecture struct of main is
        -- enable either test or computer, not both
        constant test:        std_logic := '0'; -- generate only video test screen
        constant computer:    std_logic := '1'; -- generate complete UK101 computer

        -- this is to generate video test
      	signal dispAddrB        : std_logic_vector(12 downto 0);
	signal dispRamDataOutB  : std_logic_vector(7 downto 0);
	signal charAddr         : std_logic_vector(10 downto 0);
	signal charData         : std_logic_vector(7 downto 0);

	signal video,       videoSync       : std_logic;
	signal videoHSync,  videoVSync      : std_logic;
	signal uk101_video, uk101_videoSync : std_logic;
	signal test_video,  test_videoSync  : std_logic;
	
	signal clk_50MHz        : std_logic;
	signal n_reset          : std_logic;

begin
	clock: entity work.pll_25M_50M
	port map(
	  in_25MHz => clk_25MHz,
	  out_50MHz => clk_50MHz
	);

	-- video output to 3.5mm jack
	p_tip(3) <= video;
	p_tip(2) <= videoSync;
	p_tip(1) <= '0';
	p_tip(0) <= videoSync;

	-- video output to vga
	vga_out: if false generate
	pin_37 <= video; -- r msb
	pin_36 <= video; -- r
	pin_35 <= video; -- r lsb
	pin_34 <= video; -- g msb
	pin_33 <= video; -- g
	pin_32 <= video; -- g lsb
	pin_31 <= video; -- b msb
	pin_30 <= video; -- b
	pin_29 <= video; -- b lsb
	pin_28 <= videoHSync; -- hsync
	pin_27 <= videoVSync; -- vsync
	end generate;

	-- show video on LED for some coarse optical debugging
	led(0) <= video;
	led(1) <= not videoSync;

        video_test: if test = '1' generate
	-- press btn_down to show only "0x55" on screen
	dispRamDataOutB <= dispAddrB(7 downto 0) when btn_down='0' else x"55";

	videochip: entity work.OraoGraphDisplay8K
	port map (
		clk      => clk_50MHz,
		dispAddr => dispAddrB,
		dispData => dispRamDataOutB,
		video    => video,
		sync     => videoSync
	);
	
	end generate;

	n_reset <= not btn_down;
	orao_computer: if computer = '1' generate
	computer_module: entity work.orao
	generic map(
	  onboard_buttons  => '1',
	  use_external_64K => '1'
	)
	port map(
                clk       => clk_50MHz,
                n_reset   => n_reset,
		txd       => pin_2,
		rxd       => pin_3,
		rts       => pin_4,
		ps2Clk    => pin_8,
		ps2Data   => pin_9,
		key_enter => btn_center,
		key_b     => btn_left,
		key_c     => btn_right,
                sram_lbl  => sram_lbl,
                sram_ubl  => sram_ubl,
                sram_wel  => sram_wel,
                sram_a    => sram_a,
                sram_d    => sram_d,
                video     => video,
                videoHSync => videoHSync,
                videoVSync => videoVSync,
		videoSync => videoSync
	);
	end generate;
end;
