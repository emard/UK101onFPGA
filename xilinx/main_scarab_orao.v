// (c) fpga4fun.com & KNJN LLC 2013

////////////////////////////////////////////////////////////////////////
module main_orao(
        input Clk_50MHz,
        input rs232_rx,
        output rs232_tx,
        input [1:0] PORTA, // {ps2data, ps2clk}
        output [7:0] LEDS,
	output [2:0] TMDS_out_P, TMDS_out_N,
	output TMDS_out_CLK_P, TMDS_out_CLK_N
);

////////////////////////////////////////////////////////////////////////

// generiate HDMI clocks
wire clk_pixel;
wire clk_tmds;

pll_50M_250M_25M(
  .CLK_IN1(Clk_50MHz),
  .CLK_OUT1(clk_tmds),  // 250 MHz
  .CLK_OUT2(clk_pixel)  // 25 MHz
);

assign LEDS[7:0] = 8'h55; // display fixed LED pattern

wire [12:0] dispAddr;
wire [7:0] dispData;

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
orao
#(
  .clk_mhz(25),  // MHz clock frequency
  .ram_kb(24),   // KB program memory (up to 24 in steps of 4)
  .model("103")  // orao model 102 (HR) or 103 (EN)
)
(
  .clk(clk_pixel),
  .n_reset(reset_n),
  .key_enter(key_enter),
  .key_b(key_b),
  .key_c(key_c),
  .rxd(rs232_rx),
  .txd(rs232_tx),
  .ps2clk(PORTA[0]),
  .ps2data(PORTA[1]),
  .videoAddr(dispAddr), // input from video
  .videoData(dispData)  // output to video
);

wire [2:0] TMDS_RGB;
HDMI_OraoGraphDisplay8K
#(
  .test_picture(0)  // 0-disable 1-enable test picture
)
(
  .clk_pixel(clk_pixel),
  .clk_tmds(clk_tmds),
  .dispAddr(dispAddr), // output from video
  .dispData(dispData), // input to video
  .TMDS_out_RGB(TMDS_RGB)
);

// xilinx specific HDMI output buffering
wire OBUF_pixclk;
ODDR2 #(
  .DDR_ALIGNMENT("NONE"),
  .INIT(1'b0),    // Sets initial state of the Q 
  .SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC"
)
ODDR2_inst (
  .Q(OBUF_pixclk), // 1-bit DDR output data
  .C0(clk_pixel),  // 1-bit clock input
  .C1(~clk_pixel), // 1-bit clock input inverted
  .CE(1'b1), // 1-bit clock enable input
  .D0(1'b1), // 1-bit data input (associated with C0)
  .D1(1'b0), // 1-bit data input (associated with C1)
  .R(1'b0),  // 1-bit reset input
  .S(1'b0)   // 1-bit set input
);

OBUFDS OBUFDS_red  (.I(TMDS_RGB[2]), .O(TMDS_out_P[2]), .OB(TMDS_out_N[2]));
OBUFDS OBUFDS_green(.I(TMDS_RGB[1]), .O(TMDS_out_P[1]), .OB(TMDS_out_N[1]));
OBUFDS OBUFDS_blue (.I(TMDS_RGB[0]), .O(TMDS_out_P[0]), .OB(TMDS_out_N[0]));
OBUFDS OBUFDS_clock(.I(OBUF_pixclk), .O(TMDS_out_CLK_P), .OB(TMDS_out_CLK_N));

endmodule
