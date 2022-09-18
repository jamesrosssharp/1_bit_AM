/*
 *	(C) 2022 J. R. Sharp
 *
 *	Top level for ulx3s board
 *
 *	See LICENSE.txt for software license
 */

module top (
	input        clk_25mhz,
	input  [6:0] btn,
	output [7:0] led,

	input  gp9,  // RF in
	output gp8, // RF out

	/* i2s audio */
	output       gp1,
  	output       gp2,
  	output       gp3,
  	output       gp4
);


wire clk_locked;
wire [3:0] clocks;
wire pll_clk_100   = clocks[0];
wire pll_clk_25    = clocks[1];
ecp5pll #(
	.in_hz(25000000),
	.out0_hz(100000000),
	.out1_hz( 25000000)
	)
	ecp5pll_inst
	(
		.clk_i(clk_25mhz),
		.clk_o(clocks),
		.locked(clk_locked)
	);

assign led[0] = clk_locked;
assign led[7:3] = {7{1'b0}};

/* some blinking leds */

reg [23:0] counter1;
reg [23:0] counter2;

always @(posedge pll_clk_100) counter1 <= counter1 + 1;
always @(posedge pll_clk_25) counter2 <= counter2 + 1;

assign led[1] = counter1[23];
assign led[2] = counter2[23];

/* AM demodulation */

wire CLK = pll_clk_100;
wire RSTb = 1'b1;

wire [39:0] phase_inc = 40'h2656abde3; // 936 kHz
wire [15:0] sin;
wire [15:0] cos;

nco nco0
(
	CLK,
	RSTb,

	phase_inc,

	sin,
	cos
);

wire RF_out;
assign gp8 = RF_out;

wire RF_in = gp9;

wire [15:0] I_out;
wire [15:0] Q_out;

mixer mix0 
(
	CLK,
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

cic cic0
(
	CLK,
	RSTb,
	I_out,
	3'b000,
	xI_out,
	out_tickI
);

cic cic1
(
	CLK,
	RSTb,
	Q_out,
	3'b000,
	xQ_out,
	out_tickQ
);

wire out_tick;
wire [15:0] demod_out;

am_demod am0 
(
	CLK,
	RSTb,

	xI_out,
	xQ_out,
	out_tickI,	/* tick should go high when new sample is ready */

	demod_out,
	out_tick	/* tick will go high when the new AM demodulated sample is ready */

);

//assign led[3] = demod_out[0];

/* i2s audio */

wire mclk;
wire lr_clk;
wire sclk;
wire sdat;

audio aud0
(
	pll_clk_25,	
	RSTb,

	demod_out,

	mclk,
	lr_clk,
	sclk,
	sdat	
);

assign gp1 = mclk;
assign gp2 = lr_clk;
assign gp3 = sclk;
assign gp4 = sdat;


endmodule 
