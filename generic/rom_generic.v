// generic rom - synthesis tool should build it as
// preloaded block RAM

module rom_generic(
  input wire clock,
  input wire [12:0] addr,  // 13-bit input address 8K
  output reg [7:0] data   // 8-bit data output
  );
  
  parameter rom_bytes = 8192;
  parameter filename = "bas13.vhex";

  reg [7:0] rom [rom_bytes-1:0];
  
  initial
    begin
      $readmemh(filename, rom);
      // $readmemh(filename, rom, 0, rom_bytes-1);
    end
  
  always@(negedge clock)
    begin
      data <= rom[addr];
    end
    
endmodule
