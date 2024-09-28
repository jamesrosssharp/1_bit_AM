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

wire [15:0] sin1;
wire [15:0] cos1;

assign sin = sin1[15:8];
assign cos = cos1[15:8];

sinTable sin0(CLK, {phase[PHASE_INC_BITS - 1 : PHASE_INC_BITS - 4], 6'd0}, sin1);
cosTable cos0(CLK, {phase[PHASE_INC_BITS - 1 : PHASE_INC_BITS - 4], 6'd0}, cos1);


/*
always @(posedge CLK)
begin
	case (phase[PHASE_INC_BITS - 1 : PHASE_INC_BITS - 2])
		2'b00:	begin
			sin <= 8'd127;
			cos <= 8'd127;
		end
		2'b01:	begin
			sin <= 8'd127;
			cos <= -8'd128;
		end
		2'b10:	begin
			sin <= -8'd128;
			cos <= -8'd128;
		end
		2'b11:	begin
			sin <= -8'd128;
			cos <= 8'd127;
		end
	endcase
end
*/

always @(posedge CLK)
begin
	if (RSTb == 1'b0) begin
		phase <= {PHASE_INC_BITS{1'b0}};
	end else begin
		phase <= phase + phase_inc;
	end	
end

endmodule
