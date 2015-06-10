-- This file is copyright by Grant Searle 2014
-- You are free to use this file in your own projects but must never charge for it nor use it without
-- acknowledgement.
-- Please ask permission from Grant Searle before republishing elsewhere.
-- If you use this file or any part of it, please add an acknowledgement to myself and
-- a link back to my main web site http://searle.hostei.com/grant/    
-- and to the UK101 page at http://searle.hostei.com/grant/uk101FPGA/index.html
--
-- Please check on the above web pages to see if there are any updates before using this file.
-- If for some reason the page is no longer available, please search for "Grant Searle"
-- on the internet to see if I have moved to another web hosting service.
--
-- Grant Searle
-- eMail address available on my main web page link above.
--
-- Emard modified original UK101 glue into Orao glue
-- video module not instantiated here
-- video bus used instead.
-- to avoid routing clock
-- thru this module and vendor specific modules

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity uk101va is
        generic (
          model : string := "";
          ram_kb: integer := 24; -- KB RAM this computer will have
          external_sram : integer := 1; -- 0: on-chip internal BRAM  1: external SRAM
          clk_mhz : integer := 25; -- clock freq in MHz
          serial_baud : integer := 9600 -- output serial baudrate
        );
	port(
		n_reset		: in std_logic;
		clk		: in std_logic;
		rxd		: in std_logic;
		txd		: out std_logic;
		rts		: out std_logic;
                videoAddr       : in std_logic_vector(12 downto 0);
                videoData       : out std_logic_vector(7 downto 0);
		sram_wel, sram_lbl, sram_ubl: out std_logic; -- onboard external SRAM
		sram_a          : out std_logic_vector(18 downto 0);
		sram_d          : inout std_logic_vector(15 downto 0); 
		key_b           : in std_logic;
		key_c           : in std_logic;
		key_enter       : in std_logic;
		ps2clk		: in std_logic;
		ps2data		: in std_logic
	);
end uk101va;

architecture struct of uk101va is

	signal n_WR				: std_logic;
	signal cpuAddress		: std_logic_vector(15 downto 0);
	signal cpuDataOut		: std_logic_vector(7 downto 0);
	signal cpuDataIn		: std_logic_vector(7 downto 0);

	signal basRomData		: std_logic_vector(7 downto 0);
	signal ramDataOut		: std_logic_vector(7 downto 0);
	signal monitorRomData : std_logic_vector(7 downto 0);
	signal aciaData		: std_logic_vector(7 downto 0);

	signal n_memWR			: std_logic;
	
	signal n_dispRamCS              : std_logic;
	signal n_ramCS                  : std_logic;
	signal n_basRomCS               : std_logic;
	signal n_monitorRomCS           : std_logic;
	signal n_aciaCS                 : std_logic;
	signal n_kbCS			: std_logic;
	
	signal dispAddrB                : std_logic_vector(12 downto 0);
	signal dispRamDataOutA          : std_logic_vector(7 downto 0);
	signal dispRamDataOutB          : std_logic_vector(7 downto 0);
	signal dispData                 : std_logic_vector(7 downto 0);
	signal charAddr 		: std_logic_vector(10 downto 0);
	signal charData 		: std_logic_vector(7 downto 0);

	signal serialClkCount: std_logic_vector(14 downto 0); 
	signal cpuClkCount	: std_logic_vector(5 downto 0); 
	signal cpuClock		: std_logic;
	signal serialClock	: std_logic;

	signal kbReadData 	: std_logic_vector(7 downto 0);
	
	signal uart_n_wr        : std_logic;
	signal uart_n_rd        : std_logic;
	
	type matrix8x8 is array (7 downto 0) of std_logic_vector(7 downto 0);
	constant test_pattern : matrix8x8 := (x"82", x"44", x"28", x"10", x"28", x"44", x"82", x"01");
	
begin

	n_memWR <= not(cpuClock) nand (not n_WR);

	-- n_dispRamCS <= '0' when cpuAddress(15 downto 10) = "110100" else '1'; --1k
        n_dispRamCS <= '0' when cpuAddress(15 downto 11) = "11010" else '1'; --2k
        n_basRomCS <= '0' when cpuAddress(15 downto 13) = "101" else '1'; --8k
        n_monitorRomCS <= '0' when cpuAddress(15 downto 11) = "11111" else '1'; --2K
        n_ramCS <= '0' when
                   cpuAddress(15 downto 12) >= x"0"
	       and cpuAddress(15 downto 12) <= x"9"
              else '1';
	n_aciaCS <= '0' when cpuAddress(15 downto 1) = "111100000000000" else '1';
	n_kbCS <= '0' when cpuAddress(15 downto 10) = "110111" else '1';
 
	cpuDataIn <=
                -- CEGMON PATCH FOR 64x32 SCREEN
                --x"3F" when cpuAddress = x"FBBC" else -- CEGMON SWIDTH (was $2F)
                --x"00" when cpuAddress = x"FBBD" else -- CEGMON TOP L (was $0C (1st line) or $8C (3rd line))
                --x"BF" when cpuAddress = x"FBBF" else -- CEGMON BASE L (was $CC)
                --x"D7" when cpuAddress = x"FBC0" else -- CEGMON BASE H (was $D3)
                --x"00" when cpuAddress = x"FBC2" else -- CEGMON STARTUP TOP L (was $0C (1st line) or $8C (3rd line))
                --x"00" when cpuAddress = x"FBC5" else -- CEGMON STARTUP TOP L (was $0C (1st line) or $8C (3rd line))
                --x"00" when cpuAddress = x"FBCB" else -- CEGMON STARTUP TOP L (was $0C (1st line) or $8C (3rd line))
                --x"10" when cpuAddress = x"FE62" else -- CEGMON CLR SCREEN SIZE (was $08? I see there was $04)
                --x"D8" when cpuAddress = x"FB8B" else -- CEGMON SCREEN BOTTOM H (was $D4) - Part of CTRL-F code
                --x"D7" when cpuAddress = x"FE3B" else -- CEGMON SCREEN BOTTOM H - 1 (was $D3) - Part of CTRL-A code
                basRomData when n_basRomCS = '0' else
		monitorRomData when n_monitorRomCS = '0' else
		aciaData when n_aciaCS = '0' else
		ramDataOut when n_ramCS = '0' else
		kbReadData when n_kbCS='0' else
		dispRamDataOutA when n_dispRamCS = '0'
		else x"FF";
		
	u1 : entity work.T65
	port map(
		Enable => '1',
		Mode => "00",
		Res_n => n_reset,
		Clk => cpuClock,
		Rdy => '1',
		Abort_n => '1',
		IRQ_n => '1',
		NMI_n => '1',
		SO_n => '1',
		R_W_n => n_WR,
		A(23 downto 16) => open,
		A(15 downto 0) => cpuAddress,
		DI => cpuDataIn,
		DO => cpuDataOut);

        iroms: if true generate
	u2 : entity work.ROMgeneric -- 8KB
	generic map(
                filename => "uk101basic" & model & ".vhex",
                rom_bytes => 8192
	)
	port map(
                clock => clk,
                ro_port_addr(15 downto 13) => (others => '0'),
                ro_port_addr(12 downto 0) => cpuAddress(12 downto 0),
                ro_port_data_out => basRomData
	);

	u2b : entity work.ROMgeneric -- 2KB
	generic map(
                filename => "uk101cegmon" & model & ".vhex",
                rom_bytes => 2048
	)
	port map(
                clock => clk,
                ro_port_addr(15 downto 11) => (others => '0'),
                ro_port_addr(10 downto 0) => cpuAddress(10 downto 0),
                ro_port_data_out => monitorRomData
	);
	end generate;
	
        inst_internal_bram: if external_sram = 0 generate
	u3: entity work.bram_1port
	generic map(
	  C_mem_size => ram_kb
	)
	port map
	(
		clock => clk,
		rw_port_addr(15) => '0',
		rw_port_addr(14 downto 0) => cpuAddress(14 downto 0),
		rw_port_write => not(n_memWR or n_ramCS),
		rw_port_data_in => cpuDataOut,
		rw_port_data_out => ramDataOut
	);
	end generate;

        inst_external_sram: if external_sram = 1 generate
	u3: entity work.ProgSRam 
	port map
	(
		address => cpuAddress(15 downto 0),
		data => cpuDataOut,
		n_write => n_memWR,
		n_enable => n_ramCS,
		q => ramDataOut,
                -- external SRAM interface
                sram_lbl  => sram_lbl,
                sram_ubl  => sram_ubl,
                sram_wel  => sram_wel,
                sram_a    => sram_a,
                sram_d    => sram_d
	);
	end generate;

        uart_n_wr <= n_aciaCS or cpuClock or n_WR;
        uart_n_rd <= n_aciaCS or cpuClock or (not n_WR);
	u5: entity work.bufferedUART
	port map(
		n_wr => uart_n_wr,
		n_rd => uart_n_rd,
		regSel => cpuAddress(0),
		dataIn => cpuDataOut,
		dataOut => aciaData,
		rxClock => serialClock,
		txClock => serialClock,
		rxd => rxd,
		txd => txd,
		n_cts => '0',
		n_dcd => '0',
		n_rts => rts
	);
	
	-- clock divider for CPU and serial port
	process (clk)
	begin
		if rising_edge(clk) then
			if cpuClkCount < clk_mhz-1 then
				cpuClkCount <= cpuClkCount + 1;
			else
				cpuClkCount <= (others=>'0');
			end if;
			if cpuClkCount < clk_mhz/2-1 then
				cpuClock <= '0';
			else
				cpuClock <= '1';
			end if;	
			
			if serialClkCount < 1000000*clk_mhz/(serial_baud*16)-1 then
				serialClkCount <= serialClkCount + 1;
			else
				serialClkCount <= (others => '0');
			end if;
			if serialClkCount < 1000000*clk_mhz/(serial_baud*32)-1 then
				serialClock <= '0';
			else
				serialClock <= '1';
			end if;	
		end if;
	end process;
	
	-- test grid on screen during the reset is pressed
	videoData <= dispRamDataOutB when n_reset = '1'
	        else test_pattern(conv_integer(videoAddr(7 downto 5)));
	
	videobram: if true generate
	u8_generic: entity work.bram_2port
	generic map(
	  C_mem_size => 2
	)
	port map
	(
		clock => clk,
		rw_port_addr(15 downto 11) => (others => '0'),
		rw_port_addr(10 downto 0) => cpuAddress(10 downto 0),
		rw_port_write => not(n_memWR or n_dispRamCS),
		rw_port_data_in => cpuDataOut,
		rw_port_data_out => dispRamDataOutA,
		ro_port_addr(15 downto 11) => (others => '0'),
		ro_port_addr(10 downto 0) => videoAddr(10 downto 0),
		ro_port_data_out => dispRamDataOutB
	);
	end generate;

        romtest: if false generate
	u8_testrom: entity work.ROMgeneric
	generic map(
           filename => "bas" & model & ".vhex"
	)
	port map
	(
		clock => clk,
		ro_port_addr(15 downto 13) => (others => '0'),
		ro_port_addr(12 downto 0) => videoAddr,
		ro_port_data_out => dispRamDataOutB
	);
	end generate;
	
	
        keyboard: if false generate
	u9 : entity work.orao_keyboard_buttons
	port map(
		CLK       => clk,
		nRESET    => n_reset,
		PS2_CLK	  => ps2clk,
		PS2_DATA  => ps2data,
		key_b     => key_b,
		key_c     => key_c,
		key_enter => key_enter,
		A	  => cpuAddress(10 downto 0),
		Q	  => kbReadData
	);
	end generate;
end;
