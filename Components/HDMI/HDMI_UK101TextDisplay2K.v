// (c) fpga4fun.com & KNJN LLC 2013

// Emard:
// doubling x and y pixel size
// both HDMI and VGA output

// ORAO pixel is same size as 640x480 screen pixel
// for future expansion and support for 
// possible orao graphics with 512x256 pixels

////////////////////////////////////////////////////////////////////////
module HDMI_UK101TextDisplay2K(
        input wire clk_pixel, /* 25 MHz */
        input wire clk_tmds, /* 250 MHz (set to 0 for VGA-only) */
        output wire [10:0] dispAddr,
        input wire [7:0] dispData,
        output wire [10:0] charAddr,
        input wire [7:0] charData,
        output wire vga_video, vga_hsync, vga_vsync, vga_blank,
	output wire [2:0] TMDS_out_RGB
);

parameter test_picture = 0;
parameter dbl_x = 0; // 0-normal X, 1-double X
parameter dbl_y = 0; // 0-normal Y, 1-double Y

////////////////////////////////////////////////////////////////////////

wire clk_TMDS = clk_tmds; // 250 MHz
wire pixclk = clk_pixel;  //  25 MHz

// 125MHz * 2 / 10 = 25 MHz
// DCM_SP #(.CLKFX_MULTIPLY(2), .CLKFX_DIVIDE(10)) DCM_pixclk_inst(.CLKIN(clk_125m), .CLKFX(DCM_pixclk_CLKFX), .RST(1'b0));
// DCM_CLKGEN #( .CLKFX_MULTIPLY(2), .CLKFX_DIVIDE(10) ) clockDivider_pixclk ( .CLKIN(clk_125m), .CLKFX(DCM_pixclk_CLKFX) );
// BUFG BUFG_pixclk(.I(DCM_pixclk_CLKFX), .O(pixclk));

reg [9:0] CounterX, CounterY;
reg hSync, vSync, DrawArea;
always @(posedge pixclk) DrawArea <= (CounterX<640) && (CounterY<480);

always @(posedge pixclk) CounterX <= (CounterX==799) ? 0 : CounterX+1;
always @(posedge pixclk) if(CounterX==799) CounterY <= (CounterY==524) ? 0 : CounterY+1;

always @(posedge pixclk) hSync <= (CounterX>=656) && (CounterX<752);
always @(posedge pixclk) vSync <= (CounterY>=490) && (CounterY<492);

// char addr consists from fetched data and lower 3 bits of Y scan line 0..7
assign charAddr = {dispData[7:0], CounterY[2+dbl_y:dbl_y]};
// dispAddr contains starting address of the character
wire [5:0] addr_x_part = CounterX[8+dbl_x:3+dbl_x];
wire [4:0] addr_y_part = CounterY[7+dbl_y:3+dbl_y];
assign dispAddr = {addr_y_part, addr_x_part};

parameter latency = 8; // latency 8 bits width (1 character)

// reverse char bits
wire [7:0] charData_r;
genvar i;
for (i=0; i<8; i=i+1) assign charData_r[i] = charData[7-i];

reg [7:0] shiftData;
always @(negedge pixclk)
  begin
    if(dbl_x == 0 || CounterX[0] == 0) // widen char
      shiftData <=  CounterX[2+dbl_x:0] == 0 // every char
                && CounterX >= (latency<<dbl_x) // start showing from column 1, X at data fetch latency
                && CounterX < ((512+latency)<<dbl_x) // max 64 text chars width shown on screen
                && CounterY[9:8+dbl_y] == 0 // start of text row
                 ? charData_r : shiftData[7:1];
  end

wire [7:0] colorValue = shiftData[0] == 0 ? 0 : 255;

// attempt to generate monochrome VGA signal
assign vga_video = shiftData[0];
assign vga_hsync = hSync;
assign vga_vsync = vSync;
assign vga_blank = ~DrawArea;

////////////////
wire [7:0] W = {8{CounterX[7:0]==CounterY[7:0]}};
wire [7:0] A = {8{CounterX[7:5]==3'h2 && CounterY[7:5]==3'h2}};
reg [7:0] red, green, blue;
always @(posedge pixclk) red <= ({CounterX[5:0] & {6{CounterY[4:3]==~CounterX[4:3]}}, 2'b00} | W) & ~A;
always @(posedge pixclk) green <= (CounterX[7:0] & {8{CounterY[6]}} | W) & ~A;
always @(posedge pixclk) blue <= CounterY[7:0] | W | A;

////////////////////////////////////////////////////////////////////////
wire [9:0] TMDS_red, TMDS_green, TMDS_blue;

TMDS_encoder encode_R
(
  .clk(pixclk), 
  .VD(test_picture ? red : colorValue), 
  .CD(2'b00),
  .VDE(DrawArea),
  .TMDS(TMDS_red)
);
TMDS_encoder encode_G
(
  .clk(pixclk),
  .VD(colorValue),
  .CD(2'b00),
  .VDE(DrawArea),
  .TMDS(TMDS_green)
);
TMDS_encoder encode_B
(
  .clk(pixclk),
  .VD(test_picture ? blue : colorValue),
  .CD({vSync,hSync}),
  .VDE(DrawArea), 
  .TMDS(TMDS_blue)
);

////////////////////////////////////////////////////////////////////////
// wire clk_TMDS, DCM_TMDS_CLKFX;  // 125MHz x 2 = 250MHz
// DCM_SP #(.CLKFX_MULTIPLY(2)) DCM_TMDS_inst(.CLKIN(clk_125m), .CLKFX(DCM_TMDS_CLKFX), .RST(1'b0));
// BUFG BUFG_TMDSp(.I(DCM_TMDS_CLKFX), .O(clk_TMDS));

////////////////////////////////////////////////////////////////////////
reg [3:0] TMDS_mod10=0;  // modulus 10 counter
reg [9:0] TMDS_shift_red=0, TMDS_shift_green=0, TMDS_shift_blue=0;
reg TMDS_shift_load=0;
always @(posedge clk_TMDS) TMDS_shift_load <= (TMDS_mod10==4'd9);

always @(posedge clk_TMDS)
begin
	TMDS_shift_red   <= TMDS_shift_load ? TMDS_red   : TMDS_shift_red  [9:1];
	TMDS_shift_green <= TMDS_shift_load ? TMDS_green : TMDS_shift_green[9:1];
	TMDS_shift_blue  <= TMDS_shift_load ? TMDS_blue  : TMDS_shift_blue [9:1];	
	TMDS_mod10 <= (TMDS_mod10==4'd9) ? 4'd0 : TMDS_mod10+4'd1;
end

// ******* OUTPUT ********
assign TMDS_out_RGB = {TMDS_shift_red[0], TMDS_shift_green[0], TMDS_shift_blue[0]};
endmodule

////////////////////////////////////////////////////////////////////////
module TMDS_encoder(
	input clk,
	input [7:0] VD,  // video data (red, green or blue)
	input [1:0] CD,  // control data
	input VDE,  // video data enable, to choose between CD (when VDE=0) and VD (when VDE=1)
	output reg [9:0] TMDS = 0
);

wire [3:0] Nb1s = VD[0] + VD[1] + VD[2] + VD[3] + VD[4] + VD[5] + VD[6] + VD[7];
wire XNOR = (Nb1s>4'd4) || (Nb1s==4'd4 && VD[0]==1'b0);
wire [8:0] q_m = {~XNOR, q_m[6:0] ^ VD[7:1] ^ {7{XNOR}}, VD[0]};

reg [3:0] balance_acc = 0;
wire [3:0] balance = q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7] - 4'd4;
wire balance_sign_eq = (balance[3] == balance_acc[3]);
wire invert_q_m = (balance==0 || balance_acc==0) ? ~q_m[8] : balance_sign_eq;
wire [3:0] balance_acc_inc = balance - ({q_m[8] ^ ~balance_sign_eq} & ~(balance==0 || balance_acc==0));
wire [3:0] balance_acc_new = invert_q_m ? balance_acc-balance_acc_inc : balance_acc+balance_acc_inc;
wire [9:0] TMDS_data = {invert_q_m, q_m[8], q_m[7:0] ^ {8{invert_q_m}}};
wire [9:0] TMDS_code = CD[1] ? (CD[0] ? 10'b1010101011 : 10'b0101010100) : (CD[0] ? 10'b0010101011 : 10'b1101010100);

always @(posedge clk) TMDS <= VDE ? TMDS_data : TMDS_code;
always @(posedge clk) balance_acc <= VDE ? balance_acc_new : 4'h0;
endmodule

////////////////////////////////////////////////////////////////////////
