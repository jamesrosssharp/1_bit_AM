/*
 *	(C) 2022 J. R. Sharp
 *
 *	Based on https://hackaday.io/project/170916-fpga-3-r-1-c-mw-and-sw-sdr-receiver by
 *	Alberto Garlassi
 *
 *	See LICENSE.txt for software license
 */

module mixer #(parameter BITS = 16)
(
	input CLK,
	input RSTb,

	input RF_in,
	output reg RF_out,

	input signed [BITS - 1:0] sin_in,
	input signed [BITS - 1:0] cos_in,

	output reg signed [BITS - 1:0] I_out,
	output reg signed [BITS - 1:0] Q_out	
);

reg RF_in_q;
reg RF_in_qq;

reg [BITS - 1:0] sin_q;
reg [BITS - 1:0] cos_q;

always @(posedge CLK)
begin
	RF_in_q <= RF_in;
	RF_in_qq <= RF_in_q;
	RF_out <= RF_in_qq;
	sin_q <= sin_in;
	cos_q <= cos_in;	
end

always @(posedge CLK)
begin
	if (RF_in_qq == 1'b0) begin
		I_out <= -cos_q;
		Q_out <= -sin_q;
	end else begin
		I_out <= cos_q;
		Q_out <= sin_q;
	end
end

endmodule
