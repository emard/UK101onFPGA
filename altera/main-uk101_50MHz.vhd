-- This file is copyright by Grant Searle 2014
-- You are free to use this file in your own projects but must never charge for it nor use it without
-- acknowledgement.
-- Please ask permission from Grant Searle before republishing elsewhere.
-- If you use this file or any part of it, please add an acknowledgement to myself and
-- a link back to my main web site http://searle.hostei.com/grant/    
-- and to the UK101 page at http://searle.hostei.com/grant/uk101FPGA/index.html
--
-- Please check on the above web pages to see if there are any updates before using this file.
-- If for some reason the page is no longer available, please search for "Grant Searle"
-- on the internet to see if I have moved to another web hosting service.
--
-- Grant Searle
-- eMail address available on my main web page link above.

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity main is
	port(
		clk_50MHz	: in std_logic;
		n_reset		: in std_logic;
		rxd		: in std_logic;
		txd		: out std_logic;
		rts		: out std_logic;
		videoSync	: out std_logic;
		video		: out std_logic;
		led		: out std_logic_vector(7 downto 0);
		ps2Clk		: in std_logic;
		ps2Data		: in std_logic
	);
end main;

architecture struct of main is
	
begin

	computer: entity work.uk101
	port map(
		clk       => clk_50MHz,
		n_reset   => n_reset,
		rxd	  => rxd,
		txd	  => txd,
		rts       => rts,
		videoSync => videoSync,
		video     => video,
		ps2Clk    => ps2Clk,
		ps2Data	  => ps2Data
	);

	-- led(0) <= video;
	-- led(1) <= videoSync;
end;
