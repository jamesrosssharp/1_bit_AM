/*
 *	(C) 2022 J. R. Sharp
 *
 *	See LICENSE.txt for software license
 *
 */


module nco_sq 
#(
	parameter PHASE_INC_BITS = 40,	/* 40 bits gives approx 0.1 Hz resolution @ 100MHz */
	parameter BITS = 6 		/* 4 bits */
)
(
	input CLK,
	input RSTb,

	input [PHASE_INC_BITS - 1:0] phase_inc,

	output signed [BITS - 1:0] sin,
	output signed [BITS - 1:0] cos
);

reg [PHASE_INC_BITS - 1 : 0] phase = {PHASE_INC_BITS{1'b0}};

//sinTable sin0(CLK, phase[PHASE_INC_BITS - 1 : PHASE_INC_BITS - 10], sin);
//cosTable cos0(CLK, phase[PHASE_INC_BITS - 1 : PHASE_INC_BITS - 10], cos);

always @(posedge CLK)
begin
	case (phase[PHASE_INC_BITS - 1 : PHASE_INC_BITS - 2])
		2'b00:	begin
			sin <= 6'd31;
			cos <= 6'd31;
		end
		2'b01:	begin
			sin <= 6'd31;
			cos <= -6'd32;
		end
		2'b10:	begin
			sin <= -6'd32;
			cos <= -6'd32;
		end
		2'b11:	begin
			sin <= -6'd32;
			cos <= 6'd31;
		end
	endcase
end

always @(posedge CLK)
begin
	if (RSTb == 1'b0) begin
		phase <= {PHASE_INC_BITS{1'b0}};
	end else begin
		phase <= phase + phase_inc;
	end	
end

endmodule
