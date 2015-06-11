// (c) fpga4fun.com & KNJN LLC 2013

////////////////////////////////////////////////////////////////////////
module main(
        input  wire clk_25MHz,
        input  wire btn_center, btn_up, btn_down, btn_left, btn_right;
        output wire pin_2; // txd
        input  wire pin_3; // rxd
        output wire pin_4; // rts
        input  wire pin_8; // ps2clk
        input  wire pin_9; // ps2data
        output wire sram_wel, sram_lbl, sram_ubl; // onboard SRAM
        output wire [18:0] sram_a;
        inout  wire [15:0] sram_d;
        output wire pin_37, pin_36, pin_35; // vga_pin1 red   MSB..LSB 0.47K, 1K, 2.2K
        output wire pin_34, pin_33, pin_32; // vga_pin2 green MSB..LSB 0.47K, 1K, 2.2K
        output wire pin_31, pin_30, pin_29; // vga_pin3 blue  MSB..LSB 0.47K, 1K, 2.2K
        output wire pin_28;  // vga_pin13 hsync direct (TTL)
        output wire pin_27;  // vga_pin14 vsync direct (TTL)
	output wire [3:0] p_tip,
        output wire [7:0] led
);

////////////////////////////////////////////////////////////////////////

// generiate HDMI clocks
wire clk_pixel;
wire clk_tmds;

assign clk_pixel = clk_25MHz; // here we can do without PLL
assign clk_tmds = 0; // no hdmi clock - we only have vga

/*
pll_25M_50M(
  .in_25MHz(clk_25MHz),
  .out_50MHz(clk_pixel)  // 50 MHz
);
*/

// assign led[7:0] = 8'h55; // display fixed LED pattern

wire [10:0] dispAddr;
wire [7:0] dispData;
wire [10:0] charAddr;
wire [7:0] charData;

parameter reset_period_width = 27;

reg signed [reset_period_width:0] resetcounter = 0;

// autotype counter
always @(posedge clk_pixel)
  begin
    if(resetcounter != -1)
      resetcounter <= resetcounter + 1;
  end
  
wire [4:0] autotype = resetcounter[reset_period_width:reset_period_width-4];

// demo for FPGA boards with no buttons
// automatically type onboard buttons
// reset, b c enter enter enter
// to get basic prompt
wire reset_n;
assign reset_n = autotype == 0 ? 0 : 1;
wire key_b;
assign key_b = autotype == 2 ? 1 : 0;
wire key_c;
assign key_c = autotype == 4 ? 1 : 0;
wire key_enter;
assign key_enter = autotype == 6
                || autotype == 8
                || autotype == 12
                 ? 1 : 0;

// instantiate orao computer
uk101va
#(
  .clk_mhz(25),  // MHz clock frequency
  .ram_kb(24),   // KB program RAM memory (up to 24 in steps of 4)
  .external_sram(1), // use external SRAM for program RAM
  .cegmon("64x32"), // use "serial" or "64x32" for cegmon
  .model("101")  // UK101 model "101"
)
(
  .clk(clk_pixel),
  .n_reset(~btn_down),
  .key_enter(btn_center),
  .key_b(btn_left),
  .key_c(btn_right),
  .ps2clk(pin_8),
  .ps2data(pin_9),
  .sram_lbl(sram_lbl),
  .sram_ubl(sram_ubl),
  .sram_wel(sram_wel),
  .sram_a(sram_a),
  .sram_d(sram_d),
  .videoAddr(dispAddr), // input from video
  .videoData(dispData)  // output to video
);

wire vga_video, vga_hsync, vga_vsync;
HDMI_UK101TextDisplay2K
#(
  .dbl_x(0),
  .dbl_y(0),
  .test_picture(0)  // 0-disable 1-enable test picture
)
(
  .clk_pixel(clk_pixel),
  .clk_tmds(clk_tmds),
  .dispAddr(dispAddr), // output from video
  .dispData(dispData),    // dispData input to video
  .charAddr(charAddr), // output from video
  .charData(charData), // input to video
  .vga_video(vga_video),
  .vga_vsync(vga_vsync),
  .vga_hsync(vga_hsync)
);

rom_generic
#(
  .filename("character.vhex"),
  .rom_bytes(2048)
)
(
  .clock(clk_pixel),
  .addr(charAddr),
  .data(charData)
);

// show video on LED for some coarse optical debugging
assign led[0] = vga_video;
assign led[1] = vga_vsync;
assign led[2] = vga_hsync;

assign pin_37 = vga_video; // r msb
assign pin_36 = vga_video; // r
assign pin_35 = vga_video; // r lsb
assign pin_34 = vga_video; // g msb
assign pin_33 = vga_video; // g
assign pin_32 = vga_video; // g lsb
assign pin_31 = vga_video; // b msb
assign pin_30 = vga_video; // b
assign pin_29 = vga_video; // b lsb
assign pin_28 = ~vga_hsync; // inv hsync
assign pin_27 = ~vga_vsync; // inv vsync

endmodule
