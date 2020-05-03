-- using BRAM 64K to simplify SPI snapshot loading

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity orao64k is
generic
(
  ram_kb        : integer := 24; -- KB RAM this computer will have
  clk_mhz       : integer := 25; -- clock freq in MHz
  serial_baud   : integer := 9600 -- output serial baudrate
);
port
(
  n_reset       : in    std_logic;
  btn           : in    std_logic_vector(6 downto 0);
  clk           : in    std_logic;
  rxd           : in    std_logic;
  txd           : out   std_logic;
  rts           : out   std_logic;
  vga_r,
  vga_g,
  vga_b         : out   std_logic_vector(7 downto 0);
  vga_hsync,
  vga_vsync,
  vga_blank     : out   std_logic;
  beep          : out   std_logic;
  spi_csn       : in    std_logic; -- := '1';
  spi_sclk      : in    std_logic; -- := '0';
  spi_mosi      : in    std_logic; -- := '0';
  spi_miso      : inout std_logic;
  btn_irq       : out   std_logic;
  key_b         : in    std_logic;
  key_c         : in    std_logic;
  key_enter     : in    std_logic;
  ps2clk        : in    std_logic;
  ps2data       : in    std_logic
);
end;

architecture struct of orao64k is

	constant C_ramAddrXor : std_logic_vector(1 downto 0) := "11"; -- makes ROM start from 0

	signal n_WR				: std_logic;
	signal cpuAddress		: std_logic_vector(15 downto 0);
	signal cpuDataOut		: std_logic_vector(7 downto 0);
	signal cpuDataIn		: std_logic_vector(7 downto 0);

	signal aciaData		: std_logic_vector(7 downto 0);

	signal n_memWR			: std_logic;
	
	signal n_dispRamCS              : std_logic;
	signal n_ramCS                  : std_logic;
	signal n_basRomCS               : std_logic;
	signal n_monitorRomCS           : std_logic;
	signal n_aciaCS                 : std_logic;
	signal n_beepCS                 : std_logic;
	signal n_kbCS			: std_logic;
	
	signal dispDataB                : std_logic_vector(7 downto 0);
	signal dispAddrB                : std_logic_vector(12 downto 0);
	signal dispRamAddr              : std_logic_vector(15 downto 0);
	signal dispRamAddrX             : std_logic_vector(15 downto 0);
	signal dispRamDataOutA          : std_logic_vector(7 downto 0);
	signal dispRamDataOutB          : std_logic_vector(7 downto 0);
	signal dispData                 : std_logic_vector(7 downto 0);

	signal serialClkCount: std_logic_vector(14 downto 0); 
	signal cpuClkCount	: std_logic_vector(5 downto 0); 
	signal cpuClock		: std_logic;
	signal serialClock	: std_logic;

	signal kbReadData 	: std_logic_vector(7 downto 0);
	
	signal uart_n_wr        : std_logic;
	signal uart_n_rd        : std_logic;

	signal spi_ram_addr     : std_logic_vector(31 downto 0);
	signal spi_ram_rd,
	       spi_ram_wr       : std_logic;
	signal spi_ram_data_in,
	       spi_ram_data_out : std_logic_vector(7 downto 0);

	signal R_cpu_ctrl       : std_logic_vector(7 downto 0);
	signal R_n_reset        : std_logic;
	signal R_n_halt         : std_logic;

	signal ramWE            : std_logic;
	signal ramAddress       : std_logic_vector(15 downto 0);
	signal ramAddressX	: std_logic_vector(15 downto 0);
	signal ramDataOut	: std_logic_vector(7 downto 0);
	signal ramDataIn	: std_logic_vector(7 downto 0);

	signal S_vga_rgb: std_logic_vector(7 downto 0);
	signal S_vga_video, S_vga_hsync, S_vga_vsync, S_vga_blank: std_logic;
	
	signal R_beep: std_logic;
begin

	n_memWR <= not(cpuClock) nand (not n_WR);

	-- 0x0000, 0x03FF, '0th block',
	-- 0x0400, 0x5FFF, 'user RAM (23K)',
	-- 0x6000, 0x7FFF, 'video RAM',
	-- 0x8000, 0x9FFF, 'system locations (keyboard etc.)',
	-- 0xA000, 0xAFFF, 'extension (maybe ROM cartridge)',
	-- 0xB000, 0xBFFF, 'DOS',
	-- 0xC000, 0xDFFF, 'BASIC ROM',
	-- 0xE000, 0xFFFF, 'system ROM',

	n_dispRamCS    <= '0' when cpuAddress(15 downto 13) = "011" else '1'; --8k @ 0x6000
	n_basRomCS     <= '0' when cpuAddress(15 downto 13) = "110" else '1'; --8k @ 0xC000
	n_monitorRomCS <= '0' when cpuAddress(15 downto 13) = "111" else '1'; --8K @ 0xE000
	n_ramCS        <= '0' when conv_integer(cpuAddress(15 downto 12)) < ram_kb/4 else '1';
	n_beepCS       <= '0' when cpuAddress(15 downto 0) = x"8800" else '1';
	n_aciaCS       <= '0' when cpuAddress(15 downto 1) = x"880" & "000" else '1';
	n_kbCS         <= '0' when cpuAddress(15 downto 11) = x"8" & "0" else '1';
 
	cpuDataIn <=
		ramDataOut when n_ramCS = '0' or n_dispRamCS = '0' or n_basRomCS = '0' or n_monitorRomCS = '0' else
		aciaData   when n_aciaCS = '0' else
		kbReadData when n_kbCS = '0' else
		x"FF";
		
	u1 : entity work.T65
	port map(
		Enable => cpuClock,
		Mode => "00",
		Res_n => R_n_reset,
		Clk => clk,
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

        E_spi_ram_slave: entity work.spi_ram_btn_vhd
        port map
        (
          clk      => clk,
          
          btn      => btn,
          irq      => btn_irq,

          csn      => spi_csn,
          sclk     => spi_sclk,
          mosi     => spi_mosi,
          miso     => spi_miso,

          addr     => spi_ram_addr,
          rd       => spi_ram_rd,
          wr       => spi_ram_wr,
          data_in  => spi_ram_data_in,
          data_out => spi_ram_data_out
        );

        process(clk)
        begin
          if rising_edge(clk) then
            if spi_ram_wr = '1' and spi_ram_addr(31 downto 24) = x"FF" then
              R_cpu_ctrl <= spi_ram_data_out;
            end if;
          end if;
        end process;

        process(clk)
        begin
          if rising_edge(clk) then
            R_n_reset <= n_reset and not R_cpu_ctrl(0);
            R_n_halt <= not R_cpu_ctrl(1);
          end if;
        end process;

        ramWE <= not(n_memWR or (n_ramCS and n_dispRamCS)) when R_n_halt='1'
            else '1' when spi_ram_wr='1' and spi_ram_addr(31 downto 24) = x"00"
            else '0';
        ramAddress <= cpuAddress when R_n_halt='1'
                 else spi_ram_addr(15 downto 0);
	ramDataIn <= cpuDataOut when R_n_halt='1'
	        else spi_ram_data_out;
	spi_ram_data_in <= ramDataOut;

        -- XOR to move 0xC000 to 0x0000 because ROM is currently initialized from 0
        ramAddressX(15 downto 14) <= ramAddress(15 downto 14) xor C_ramAddrXor;
        ramAddressX(13 downto 0) <= ramAddress(13 downto 0);
        dispRamAddr <= "011" & dispAddrB; -- 0x6000
        dispRamAddrX(15 downto 14) <= dispRamAddr(15 downto 14) xor C_ramAddrXor;
        dispRamAddrX(13 downto 0) <= dispRamAddr(13 downto 0);
	E_oraomem : entity work.bram_true2p_2clk
	generic map
	(
	  dual_port => True,
	  addr_width => 16
	)
	port map
	(
	  clk_a      => clk,
	  addr_a     => ramAddressX,
	  we_a       => ramWE,
	  data_in_a  => ramDataIn,
	  data_out_a => ramDataOut,
	  -- port B for video read
	  clk_b      => clk,
	  addr_b     => dispRamAddrX,
	  we_b       => '0',
	  data_out_b => dispDataB
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
	
	-- clock divider for CPU and serial port
	process (clk)
	begin
		if rising_edge(clk) then
			if cpuClkCount < clk_mhz-1 then
				cpuClkCount <= cpuClkCount + 1;
				cpuClock <= '0';
			else
				cpuClkCount <= (others=>'0');
				cpuClock <= R_n_halt;
			end if;
			--if cpuClkCount < clk_mhz/2-1 then
			--	cpuClock <= '0';
			--else
			--	cpuClock <= '1';
			--end if;
			
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
	
	u9 : entity work.orao_keyboard_buttons
	port map(
		CLK       => clk,
		nRESET    => R_n_reset,
		PS2_CLK	  => ps2clk,
		PS2_DATA  => ps2data,
		key_b     => key_b,
		key_c     => key_c,
		key_enter => key_enter,
		A	  => cpuAddress(10 downto 0),
		Q	  => kbReadData
	);

        process(clk)
        begin
          if rising_edge(clk) then
            if cpuClock='1' and n_beepCS='0' then
              R_beep <= not R_beep;
            end if;
          end if;
        end process;
        beep <= R_beep;

	videochip: entity work.hdmi_oraographdisplay8k_vhd
	port map
	(
		clk_pixel => clk,
		clk_tmds  => '0',
		dispAddr  => dispAddrB,
		dispData  => dispDataB,
		vga_video => S_vga_video,
		vga_hsync => S_vga_hsync,
		vga_vsync => S_vga_vsync,
		vga_blank => S_vga_blank
	);
	
	S_vga_rgb <= x"FF" when S_vga_video = '1' else x"00";

  -- SPI OSD pipeline
  spi_osd_inst: entity work.spi_osd_vhd
  generic map
  (
    c_addr_enable  => x"FE",
    c_addr_display => x"FD",
    c_start_x => 62, c_start_y => 80, -- xy centered
    c_chars_x => 64, c_chars_y => 20, -- xy size, slightly less than full screen
    c_init_on => 0, -- 1:OSD initially shown without any SPI init
    c_char_file => "osd.mem", -- initial OSD content
    c_font_file => "font_bizcat8x16.mem"
  )
  port map
  (
    clk_pixel => clk, clk_pixel_ena => '1',
    i_r => S_vga_rgb,
    i_g => S_vga_rgb,
    i_b => S_vga_rgb,
    i_hsync => S_vga_hsync, i_vsync => S_vga_vsync, i_blank => S_vga_blank,
    i_csn => spi_csn, i_sclk => spi_sclk, i_mosi => spi_mosi, o_miso => open,
    o_r => vga_r, o_g => vga_g, o_b => vga_b,
    o_hsync => vga_hsync, o_vsync => vga_vsync, o_blank => vga_blank
  );

end;
