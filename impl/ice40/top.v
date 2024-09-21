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

// Instantiate PLL to generate 25 MHz

wire clk;

SB_PLL40_PAD #(
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

assign PWM_OUT = (count < sine_shift[15:8]) ? 1'b1 : 1'b0;


endmodule
