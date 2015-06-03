LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY DisplayRam2K IS
	PORT
	(
		address_a	: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		address_b	: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren_a		: IN STD_LOGIC  := '0';
		wren_b		: IN STD_LOGIC  := '0';
		q_a		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END DisplayRam2K;


ARCHITECTURE SYN OF DisplayRam2K IS
begin
  display_ram: entity work.lattice_DisplayRam2K
  port map(
    AddressA   => address_a,
    AddressB   => address_b,
    ClockA     => clock,
    ClockB     => clock,
    ClockEnA   => '1',
    ClockEnB   => '1',
    ResetA     => '0',
    ResetB     => '0',
    DataInA    => data_a,
    DataInB    => data_b,
    WrA        => wren_a,
    WrB        => wren_b,
    QA         => q_a,
    QB         => q_b
  );
END SYN;
