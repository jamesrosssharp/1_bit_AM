/*
 *	(C) 2022 J. R. Sharp
 *
 *	See LICENSE.txt for software license
 *
 */


module nco 
#(
	parameter PHASE_INC_BITS = 40,	/* 40 bits gives approx 0.1 Hz resolution @ 100MHz */
	parameter BITS = 16 		/* 16 bits due to BRAM width */
)
(
	input CLK,
	input RSTb,

	input [PHASE_INC_BITS - 1:0] phase_inc,

	output [BITS - 1:0] sin,
	output [BITS - 1:0] cos
);

reg [PHASE_INC_BITS - 1 : 0] phase = {PHASE_INC_BITS{1'b0}};

sinTable sin0(CLK, phase[PHASE_INC_BITS - 1 : PHASE_INC_BITS - 10], sin);
cosTable cos0(CLK, phase[PHASE_INC_BITS - 1 : PHASE_INC_BITS - 10], cos);

always @(posedge CLK)
begin
	if (RSTb == 1'b0) begin
		phase <= {PHASE_INC_BITS{1'b0}};
	end else begin
		phase <= phase + phase_inc;
	end	
end

endmodule
