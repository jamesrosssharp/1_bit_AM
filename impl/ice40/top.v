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
	output 	reg PWM_OUT,
	input   COMP0
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
/*.FEEDBACK_PATH("SIMPLE"),
		.DIVR(4'b0000),		// DIVR =  0
		.DIVF(7'b1001111),	// DIVF = 79
		.DIVQ(3'b101),		// DIVQ =  5
		.FILTER_RANGE(3'b001)	// FILTER_RANGE = 1
  */
.FEEDBACK_PATH("SIMPLE"),
		.DIVR(4'b0000),		// DIVR =  0
		.DIVF(7'b1000010),	// DIVF = 66
		.DIVQ(3'b100),		// DIVQ =  4
		.FILTER_RANGE(3'b001)	// FILTER_RANGE = 1

/*.FEEDBACK_PATH("SIMPLE"),
		.DIVR(4'b0000),		// DIVR =  0
		.DIVF(7'b1001000),	// DIVF = 72
		.DIVQ(3'b100),		// DIVQ =  4
		.FILTER_RANGE(3'b001)	// FILTER_RANGE = 1
*/

/*   .FEEDBACK_PATH("SIMPLE"),
   .PLLOUT_SELECT("GENCLK"),
   .DIVR(4'b0000),
   .DIVF(7'b1000010),
   .DIVQ(3'b101),
   .FILTER_RANGE(3'b001),
*/
 ) SB_PLL40_CORE_inst (
   .RESETB(1'b1),
   .BYPASS(1'b0),
   .PACKAGEPIN(CLK12),
   .PLLOUTCORE(clk),
);


// NCO

wire RSTb = 1'b1;

reg [25:0] phase_inc = 40'h1312eb; // 936 kHz ABC Hobart @ 50MHz

wire [7:0] sin;
wire [7:0] cos;

nco_sq nco0
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

wire [7:0] I_out;
wire [7:0] Q_out;

mixer_2b
mix0 
(
	clk,
	RSTb,

	COMP0,
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

wire [15:0] xI_out2;
wire [15:0] xQ_out2;
wire out_tickI_2;
wire out_tickQ_2;



wire gain = 8'b000000;

cic_lite cic0
(
	clk,
	RSTb,
	1'b1,
	I_out,
	gain,
	xI_out,
	out_tickI
);

cic_lite cic1
(
	clk,
	RSTb,
	1'b1,
	Q_out,
	gain,
	xQ_out,
	out_tickQ
);

cic_lite cic2
(
	clk,
	RSTb,
	out_tickI,
	xI_out[15:8],
	gain,
	xI_out2,
	out_tickI_2
);

cic_lite cic3
(
	clk,
	RSTb,
	out_tickQ,
	xQ_out[15:8],
	gain,
	xQ_out2,
	out_tickQ_2
);




wire out_tick;
wire [15:0] demod_out;

am_demod_lite am0 
(
	clk,
	RSTb,

	xI_out2[15:8],
	xQ_out2[15:8],
	out_tickI_2,	/* tick should go high when new sample is ready */

	demod_out,
	out_tick	/* tick will go high when the new AM demodulated sample is ready */

);


// Generate sine wave to PWM

/*reg [15:0] counter = 16'h0000;

wire [9:0] sine_addr = counter[15:6];
wire signed [15:0] sine_data;

always @(posedge clk)
	counter <= counter + 1;

cosTable c0 (clk, sine_addr, sine_data);

// PWM

reg [15:0] sine_shift;
always @(posedge clk) sine_shift <= sine_data + 16'd32768;
*/


reg [7:0] count; 
always @(posedge clk) count <= count + 1;

always @(posedge clk) PWM_OUT <= (count < demod_out[15:8]) ? 1'b1 : 1'b0;


endmodule
