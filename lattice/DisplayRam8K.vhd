LIBRARY ieee;
USE ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY DisplayRam8K IS
	PORT
	(
		address_a	: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
		address_b	: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren_a		: IN STD_LOGIC  := '0';
		wren_b		: IN STD_LOGIC  := '0';
		q_a		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END DisplayRam8K;


ARCHITECTURE SYN OF DisplayRam8K IS
  signal address_a_ext, address_b_ext: std_logic_vector(12 downto 0);
begin
  
  -- use only 8K of RAM
  address_a_ext <= address_a;
  address_b_ext <= address_b;

  display_ram: entity work.lattice_DisplayRam8K
  port map(
    AddressA   => address_a_ext,
    AddressB   => address_b_ext,
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
