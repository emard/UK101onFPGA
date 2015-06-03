LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ProgRam IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END ProgRam;


ARCHITECTURE SYN OF ProgRam IS
begin
  prog_ram: entity work.lattice_ProgRam
  port map(
    Address    => address(12 downto 0),
    Clock      => clock,
    ClockEn    => '1',
    Reset      => '0',
    Data       => data,
    WE         => wren,
    Q          => q
  );
END SYN;
