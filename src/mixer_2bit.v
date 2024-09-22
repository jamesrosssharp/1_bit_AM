/*
 *	(C) 2022 J. R. Sharp
 *
 *	Based on https://hackaday.io/project/170916-fpga-3-r-1-c-mw-and-sw-sdr-receiver by
 *	Alberto Garlassi
 *
 *	See LICENSE.txt for software license
 */

module mixer_2b #(parameter BITS = 6)
(
	input CLK,
	input RSTb,

	input [2:0] RF_in,
	output reg  RF_out,

	input signed [BITS - 1:0] sin_in,
	input signed [BITS - 1:0] cos_in,

	output reg signed [BITS - 1:0] I_out,
	output reg signed [BITS - 1:0] Q_out	
);

reg [2:0] RF_in_q;
reg [2:0] RF_in_qq;

reg signed [BITS - 1:0] sin_q;
reg signed [BITS - 1:0] cos_q;


always @(posedge CLK)
begin
	case (RF_in_qq)
		3'b000, 3'b001:
			RF_out <= 1'b0;
		3'b010, 3'b011, 3'b100:
			RF_out <= 1'b1;
	endcase
end

always @(posedge CLK)
begin
	RF_in_q <= RF_in;
	RF_in_qq <= RF_in_q;
	sin_q <= sin_in;
	cos_q <= cos_in;	
end

always @(posedge CLK)
begin

	case (RF_in_qq)
		3'b000: begin
			I_out <= -cos_q;
			Q_out <= -sin_q;
			end
		3'b001: begin
			I_out <= -{cos_q[5], cos_q[5:1]};
			Q_out <= -{sin_q[5], sin_q[5:1]};
			end
		3'b010: begin
			I_out <= 6'd0;
			Q_out <= 6'd0;
			end
		3'b011: begin
			I_out <= {cos_q[5], cos_q[5:1]};
			Q_out <= {sin_q[5], sin_q[5:1]};
			end
		3'b100: begin
			I_out <= cos_q;
			Q_out <= sin_q;
			end
	endcase

//	I_out <= cos_q[15:3] * RF_in_qq;
//	Q_out <= sin_q[15:3] * RF_in_qq;


end

endmodule
