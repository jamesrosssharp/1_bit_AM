/*
 *	(C) 2022 J. R. Sharp
 *
 *	Top level for ulx3s board
 *
 *	See LICENSE.txt for software license
 */

//`define TEST_GENERATOR

module top (
	input	CLK12,
	output  COMP_NEG,
	input 	COMP_OUT,
	output  PWM_OUT	
);

// Instantiate PLL to generate 25.125 MHz

wire clk;

SB_PLL40_PAD #(
/*.FEEDBACK_PATH("SIMPLE"),
		.DIVR(4'b0000),		// DIVR =  0
		.DIVF(7'b0111111),	// DIVF = 63
		.DIVQ(3'b100),		// DIVQ =  4
		.FILTER_RANGE(3'b001)	// FILTER_RANGE = 1
*/
     
   .FEEDBACK_PATH("SIMPLE"),
   .PLLOUT_SELECT("GENCLK"),
   .DIVR(4'b0000),
   .DIVF(7'b1000010),
   .DIVQ(3'b101),
   .FILTER_RANGE(3'b001),
 ) SB_PLL40_CORE_inst (
   .RESETB(1'b1),
   .BYPASS(1'b0),
   .PACKAGEPIN(CLK12),
   .PLLOUTCORE(clk),
);

// NCO

wire RSTb = 1'b1;

reg [39:0] phase_inc = 40'h98975e5c5; // 936 kHz ABC Hobart
//reg [39:0] phase_inc = 40'h98ead65b7; // 936 kHz ABC Hobart

//reg [39:0] phase_inc = 40'h5f5e9af9b; // 585 kHz ABC Hobart
//reg [39:0] phase_inc = 40'h79c792b11; // 747 kHz ABC Hobart

wire [15:0] sin;
wire [15:0] cos;

nco nco0
(
	clk,
	RSTb,

	phase_inc,

	sin,
	cos
);

// Sample and RF Down convert

wire RF_out;
assign COMP_NEG =  RF_out;

wire RF_in = COMP_OUT;

wire [15:0] I_out;
wire [15:0] Q_out;

mixer mix0 
(
	clk,
	RSTb,

	RF_in,
	RF_out,

	sin,
	cos,

	I_out,
	Q_out	
);

// Instantiate CIC

wire [15:0] xI_out;
wire [15:0] xQ_out;
wire out_tickI;
wire out_tickQ;

wire gain = 8'b000000;

cic cic0
(
	clk,
	RSTb,
	I_out,
	gain,
	xI_out,
	out_tickI
);

cic cic1
(
	clk,
	RSTb,
	Q_out,
	gain,
	xQ_out,
	out_tickQ
);

wire out_tick;
wire [15:0] demod_out;

am_demod am0 
(
	clk,
	RSTb,

	xI_out,
	xQ_out,
	out_tickI,	/* tick should go high when new sample is ready */

	demod_out,
	out_tick	/* tick will go high when the new AM demodulated sample is ready */

);


// Generate sine wave to PWM

reg [15:0] counter = 16'h0000;

wire [9:0] sine_addr = counter[15:6];
wire signed [15:0] sine_data;

always @(posedge clk)
	counter <= counter + 1;

cosTable c0 (clk, sine_addr, sine_data);

// PWM

reg [15:0] sine_shift;
always @(posedge clk) sine_shift <= sine_data + 16'd32768;



reg [7:0] count; 
always @(posedge clk) count <= count + 1;

assign PWM_OUT = (count < demod_out[11:4]) ? 1'b1 : 1'b0;


endmodule
