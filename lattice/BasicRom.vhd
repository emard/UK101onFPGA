LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY BasicRom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END BasicRom;

ARCHITECTURE SYN OF basicrom IS
BEGIN
  basic_rom: entity work.lattice_BasicRom
  port map(
    Address => address,
    OutClock => clock,
    OutClockEn => '1',
    Reset => '0',
    Q => q
  );
END SYN;
