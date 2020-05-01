-- VHDL wrapper for display

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity HDMI_OraoGraphDisplay8K_vhd is
  port
  (
          clk_pixel, clk_tmds: in std_logic;
          dispAddr: out std_logic_vector(12 downto 0);
          dispData: in std_logic_vector(7 downto 0);
          vga_video, vga_hsync, vga_vsync, vga_blank: out std_logic;
          TMDS_out_RGB: out std_logic_vector(2 downto 0)
  );
end;

architecture syn of HDMI_OraoGraphDisplay8K_vhd is
  component hdmi_oraographdisplay8k is
  port
  (
          clk_pixel, clk_tmds: in std_logic;
          dispAddr: out std_logic_vector(12 downto 0);
          dispData: in std_logic_vector(7 downto 0);
          vga_video, vga_hsync, vga_vsync, vga_blank: out std_logic;
          TMDS_out_RGB: out std_logic_vector(2 downto 0)
  );
  end component;
begin
  videochip: hdmi_oraographdisplay8k
    port map
    (
		clk_pixel => clk_pixel,
		clk_tmds  => clk_tmds,
		dispAddr  => dispAddr,
		dispData  => dispData,
		vga_video => vga_video,
		vga_hsync => vga_hsync,
		vga_vsync => vga_vsync,
		vga_blank => vga_blank,
		TMDS_out_RGB => TMDS_out_RGB
    );
end syn;
