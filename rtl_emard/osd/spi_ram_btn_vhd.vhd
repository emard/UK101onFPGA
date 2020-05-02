-- VHDL wrapper for spi_ram_btn

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity spi_ram_btn_vhd is
  generic
  (
    c_addr_btn         : std_logic_vector(7 downto 0) := x"FB"; -- high addr byte of BTNs
    c_addr_irq         : std_logic_vector(7 downto 0) := x"F1"; -- high addr byte of IRQ flag
    c_debounce_bits    : natural := 20; -- more -> slower BTNs
    c_addr_bits        : natural := 32; -- don't touch
    c_sclk_capable_pin : natural := 0 -- 0-sclk is generic pin, 1-sclk is clock capable pin
  );
  port
  (
    clk                : in    std_logic;

    csn, sclk, mosi    : in    std_logic; -- SPI lines to be sniffed
    miso               : inout std_logic; -- 3-state line, active when csn=0
    -- BTNs
    btn                : in    std_logic_vector(6 downto 0);
    irq                : out   std_logic;
    -- BRAM interface
    rd, wr             : out   std_logic;
    addr               : out   std_logic_vector(c_addr_bits-1 downto 0);
    data_out           : out   std_logic_vector(7 downto 0);
    data_in            : in    std_logic_vector(7 downto 0)
  );
end;

architecture syn of spi_ram_btn_vhd is
  component spi_ram_btn -- verilog name and its parameters
  generic
  (
    c_addr_btn         : std_logic_vector(7 downto 0) := x"FB"; -- high addr byte of BTNs
    c_addr_irq         : std_logic_vector(7 downto 0) := x"F1"; -- high addr byte of IRQ flag
    c_debounce_bits    : natural := 20; -- more -> slower BTNs
    c_addr_bits        : natural := 32; -- don't touch
    c_sclk_capable_pin : natural := 0 -- 0-sclk is generic pin, 1-sclk is clock capable pin
  );
  port
  (
    clk                : in    std_logic;

    csn, sclk, mosi    : in    std_logic; -- SPI lines to be sniffed
    miso               : inout std_logic; -- 3-state line, active when csn=0
    -- BTNs
    btn                : in    std_logic_vector(6 downto 0);
    irq                : out   std_logic;
    -- BRAM interface
    rd, wr             : out   std_logic;
    addr               : out   std_logic_vector(c_addr_bits-1 downto 0);
    data_out           : out   std_logic_vector(7 downto 0);
    data_in            : in    std_logic_vector(7 downto 0)
  );
  end component;

begin
  spi_ram_btn_inst: spi_ram_btn
  generic map
  (
    c_addr_btn         => c_addr_btn,
    c_addr_irq         => c_addr_irq,
    c_debounce_bits    => c_debounce_bits,
    c_addr_bits        => c_addr_bits,
    c_sclk_capable_pin => c_sclk_capable_pin
  )
  port map
  (
    clk                => clk,
    -- SPI
    csn                => csn,
    sclk               => sclk,
    mosi               => mosi,
    miso               => miso,
    -- BTNs
    btn                => btn,
    irq                => irq,
    -- BRAM interface
    rd                 => rd,
    wr                 => wr,
    addr               => addr,
    data_in            => data_in,
    data_out           => data_out
  );
end syn;
