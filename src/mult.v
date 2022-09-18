/*
 *	(C) 2022 J. R. Sharp
 *
 *	Based on https://hackaday.io/project/170916-fpga-3-r-1-c-mw-and-sw-sdr-receiver by
 *	Alberto Garlassi
 *
 *	See LICENSE.txt for software license
 */

module mult #(parameter BITS = 16)
(
	input signed [BITS - 1 : 0] a,
	input signed [BITS - 1 : 0] b,
	output signed [2*BITS - 1 : 0] out
);

assign out = a*b;

endmodule
