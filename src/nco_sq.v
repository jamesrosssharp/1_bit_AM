/*
 *	(C) 2022 J. R. Sharp
 *
 *	See LICENSE.txt for software license
 *
 */


module nco_sq 
#(
	parameter PHASE_INC_BITS = 26,	/* 26 bits gives approx 1 Hz resolution @ 50MHz */
	parameter BITS = 8 		/* 4 bits */
)
(
	input CLK,
	input RSTb,

	input [PHASE_INC_BITS - 1:0] phase_inc,

	output signed [BITS - 1:0] sin,
	output signed [BITS - 1:0] cos
);

reg [PHASE_INC_BITS - 1 : 0] phase = {PHASE_INC_BITS{1'b0}};

sinTable sin0(CLK, phase[PHASE_INC_BITS - 1 : PHASE_INC_BITS - 4], sin);
cosTable cos0(CLK, phase[PHASE_INC_BITS - 1 : PHASE_INC_BITS - 4], cos);

always @(posedge CLK)
begin
	if (RSTb == 1'b0) begin
		phase <= {PHASE_INC_BITS{1'b0}};
	end else begin
		phase <= phase + phase_inc;
	end	
end

endmodule
