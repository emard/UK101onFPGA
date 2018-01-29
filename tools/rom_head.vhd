library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity rom_name is
	port (
		clk: in std_logic;
		addr: in std_logic_vector(12 downto 0);
		data: out std_logic_vector(7 downto 0)
	);
end entity;

architecture Behavioral of rom_name is
	type romDef is array(0 to 8191) of std_logic_vector(7 downto 0);
	constant romData: romDef := (
