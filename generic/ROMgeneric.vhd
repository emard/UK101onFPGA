LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- vhdl wrapper for verilog module rom_generic.v

ENTITY ROMgeneric IS
        generic(
                filename        : string
        );
	PORT
	(
	clock: in std_logic;
	-- read-only port
	ro_port_addr: in std_logic_vector(15 downto 0);
	ro_port_data_out: out std_logic_vector(7 downto 0)
	);
END ROMgeneric;

ARCHITECTURE SYN OF ROMgeneric IS

  component rom_generic
    generic (
      filename     : string
    );
    port (
      clock        : in  std_logic;
      addr         : in  std_logic_vector(15 downto 0);
      data         : out std_logic_vector(7 downto 0)
    );
  end component;

BEGIN
  basic_rom: rom_generic
  generic map(
    filename => filename
  )
  port map(
    clock => clock,
    addr => ro_port_addr,
    data => ro_port_data_out
  );
END SYN;
