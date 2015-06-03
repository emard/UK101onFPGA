-- Just a pin renamer/wrapper for
-- vendor specific pll

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity pll_25M_50M is
	port(
		in_25MHz  : in std_logic;
		out_50MHz : out std_logic
	);
end pll_25M_50M;

architecture struct of pll_25M_50M is

begin
	pll: entity work.lattice_pll_25M_50M
	port map(
	  CLK    => in_25MHz,
	  CLKOP  => out_50MHz
	);
end;
