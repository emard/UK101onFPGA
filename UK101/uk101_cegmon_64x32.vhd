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

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity uk101 is
        generic (
          onboard_buttons  : std_logic := '0';
          use_external_64K : std_logic := '0'   -- if 0 then use internal RAM
        );
	port(
		n_reset		: in std_logic;
		clk		: in std_logic;
		rxd		: in std_logic;
		txd		: out std_logic;
		rts		: out std_logic;
		videoSync	: out std_logic;
		video		: out std_logic;
		sram_wel, sram_lbl, sram_ubl: out std_logic; -- onboard external SRAM
		sram_a          : out std_logic_vector(18 downto 0);
		sram_d          : inout std_logic_vector(15 downto 0); 
		key_c           : in  std_logic;
		key_enter       : in  std_logic;
		ps2Clk		: in std_logic;
		ps2Data		: in std_logic
	);
end uk101;

architecture struct of uk101 is

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
	
	signal dispAddrB                : std_logic_vector(10 downto 0);
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
	signal kbRowSel 		: std_logic_vector(7 downto 0);
	
	signal uart_n_wr        : std_logic;
	signal uart_n_rd        : std_logic;
	
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
		dispRamDataOutA when n_dispRamCS = '0' else
		kbReadData when n_kbCS='0'
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
		A(15 downto 0) => cpuAddress,
		DI => cpuDataIn,
		DO => cpuDataOut);
			

	u2 : entity work.BasicRom -- 8KB
	port map(
		address => cpuAddress(12 downto 0),
		clock => clk,
		q => basRomData
	);
	
        internal_8K: if use_external_64K = '0' generate
	u3: entity work.ProgRam
	port map
	(
		address => cpuAddress(12 downto 0),
		clock => clk,
		data => cpuDataOut,
		wren => not(n_memWR or n_ramCS),
		q => ramDataOut
	);
	end generate;

        external_64K: if use_external_64K = '1' generate
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
	
	u4: entity work.CegmonRom
	port map
	(
		address => cpuAddress(10 downto 0),
		q => monitorRomData
	);

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
	
	process (clk)
	begin
		if rising_edge(clk) then
			if cpuClkCount < 49 then
				cpuClkCount <= cpuClkCount + 1;
			else
				cpuClkCount <= (others=>'0');
			end if;
			if cpuClkCount < 24 then
				cpuClock <= '0';
			else
				cpuClock <= '1';
			end if;	
			
--			if serialClkCount < 10416 then -- 300 baud
			if serialClkCount < 325 then -- 9600 baud
				serialClkCount <= serialClkCount + 1;
			else
				serialClkCount <= (others => '0');
			end if;
--			if serialClkCount < 5208 then -- 150 baud
			if serialClkCount < 162 then -- 9600 baud
				serialClock <= '0';
			else
				serialClock <= '1';
			end if;	
		end if;
	end process;
	
	-- show test screen during the reset is pressed
	dispData <= dispRamDataOutB when n_reset = '1' else dispAddrB(7 downto 0);
	
	u6 : entity work.UK101TextDisplay2K
	port map (
		charAddr => charAddr,
		charData => charData,
		dispAddr => dispAddrB,
		dispData => dispData,
		clk => clk,
		sync => videoSync,
		video => video
	);

	u7: entity work.CharRom
	port map
	(
		address => charAddr,
		q => charData
	);

	u8: entity work.DisplayRam2K 
	port map
	(
		address_a => cpuAddress(10 downto 0),
		address_b => dispAddrB,
		clock	=> clk,
		data_a => cpuDataOut,
		data_b => (others => '0'),
		wren_a => not(n_memWR or n_dispRamCS),
		wren_b => '0',
		q_a => dispRamDataOutA,
		q_b => dispRamDataOutB
	);
	
	normal_keyboard: if onboard_buttons = '0' generate
	u9 : entity work.UK101keyboard
	port map(
		CLK => clk,
		nRESET => n_reset,
		PS2_CLK	=> ps2Clk,
		PS2_DATA	=> ps2Data,
		A	=> kbRowSel,
		KEYB	=> kbReadData
	);
	end generate;

	buttons2keys: if onboard_buttons = '1' generate
	u9 : entity work.UK101keyboard_buttons
	port map(
		CLK       => clk,
		nRESET    => n_reset,
		PS2_CLK	  => ps2Clk,
		PS2_DATA  => ps2Data,
		key_c     => key_c,
		key_enter => key_enter,
		A	  => kbRowSel,
		KEYB	  => kbReadData
	);
	end generate;
	
	process (n_kbCS,n_memWR)
	begin
		if	n_kbCS='0' and n_memWR = '0' then
			kbRowSel <= cpuDataOut;
		end if;
	end process;
	
end;
