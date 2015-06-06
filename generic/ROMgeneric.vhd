LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- vhdl wrapper for verilog module rom_generic.v

ENTITY ROMgeneric IS
        generic(
                filename        : string
        );
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END ROMgeneric;

ARCHITECTURE SYN OF ROMgeneric IS

  component rom_generic
    generic (
      filename     : string
    );
    port (
      clock        : in  std_logic;
      addr         : in  std_logic_vector(12 downto 0);
      data         : out std_logic_vector(7 downto 0)
    );
  end component;

BEGIN
  basic_rom: rom_generic
  generic map(
    filename => filename
  )
  port map(
    addr => address,
    clock => clock,
    data => q
  );
END SYN;
