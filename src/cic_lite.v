/*
 *	(C) 2022 J. R. Sharp
 *
 *	Based on https://hackaday.io/project/170916-fpga-3-r-1-c-mw-and-sw-sdr-receiver by
 *	Alberto Garlassi
 *
 *	See LICENSE.txt for software license
 */

/*
 *	From Alberto's code, register width is given by
 *	                             _       _
 *	w = num bits in x[n] + (Q * | log_2 D |) 
 *
 *	where x[n] is input sequence, Q is no. of stages and D is decimation factor.
 *
 *	So for Q = 5, D = 4096, and 16 bit input, 
 *
 *	w = 16 + 5 * 12 = 76 bits
 *
 *	Actual formula in Hogenauer's original paper is eqn. 11, viz:
 *			 _                          _
 *		B_max = |  N * log_2(R*M) + B_in - 1 |
 *
 * 	Where B_max is max output bits, B_in is input number of bits, N is num stages, R is decimation factor,
 *	M is diff. delay. So again we would have:
 *                       _                 _
 *		B_max = |  5 * 12 + 16 - 1  | = 75 bits
 */

module cic_lite #(	
		parameter WIDTH = 27,	/* see notes above for register width */
		parameter DECIM = 64,
		parameter BITS  = 8,
		parameter GAIN_BITS = 8 
)
(
	input CLK,
	input RSTb,

	input in_tick,

	input signed [BITS - 1:0] x_in,
	input [GAIN_BITS - 1:0]   gain,

	output reg signed [15:0] x_out,

	output reg out_tick /* tick goes high for 1 clock cycle when an output sample is ready */

);

/* 5 integrator stages */
reg signed [WIDTH - 1:0] integ1;
reg signed [WIDTH - 1 - 3:0] integ2;
reg signed [WIDTH - 1 - 6:0] integ3;


/* Counter to determine when to tap off a sample into the comb section */
localparam COUNTER_BITS = 16;
reg [COUNTER_BITS - 1:0] count;

reg sample;

reg signed [WIDTH - 1 - 6:0] integ_sample;

// Integrator section
always @(posedge CLK)
begin

	sample <= 1'b0;

	if (RSTb == 1'b0)
	begin
		integ1 <= {WIDTH{1'b0}};
		integ2 <= {WIDTH - 2{1'b0}};
		integ3 <= {WIDTH - 4{1'b0}};
		//out_tick <= 1'b0;
		//x_out <= {BITS{1'b0}};
		count <= {COUNTER_BITS{1'b0}};
		sample <= 1'b0;
	end else if (in_tick == 1'b1) begin
		integ1 <= integ1 + $signed(x_in);
		integ2 <= integ2 + integ1[WIDTH - 1 : 3];
		integ3 <= integ3 + integ2[WIDTH - 1 - 3 : 3];

		count <= count + 1;

		if (count == DECIM - 1)
		begin
			count <= {COUNTER_BITS{1'b0}};
			sample <= 1'b1;
			integ_sample <= integ3;
		end
	end
end

// Comb section

reg signed [WIDTH - 1 - 6:0] comb1, comb1_in_del;
reg signed [WIDTH - 1 - 6:0] comb2, comb2_in_del;
reg signed [WIDTH - 1 - 6:0] comb3, comb3_in_del;

always @(posedge CLK)
begin
	if (RSTb == 1'b0)
	begin
		comb1 <= {WIDTH{1'b0}};
		comb2 <= {WIDTH{1'b0}};
		comb3 <= {WIDTH{1'b0}};
		comb1_in_del <= {WIDTH{1'b0}};
		comb2_in_del <= {WIDTH{1'b0}};
		comb3_in_del <= {WIDTH{1'b0}};
		out_tick <= 1'b0;
		x_out <= {16{1'b0}};
	end
	else begin
		if (sample == 1'b1) begin
			comb1_in_del <= $signed(integ_sample);
			comb1 <= integ_sample - comb1_in_del;

			comb2_in_del <= comb1;
			comb2 <= comb1 - comb2_in_del;

			comb3_in_del <= comb2;
			comb3 <= comb2 - comb3_in_del;

			// Doesn't seem like variable gain synthesizes with yosys...
			x_out <= comb3 >>> (WIDTH - 16 - 6 - 1);
			out_tick <= 1'b1;
		end else begin
			out_tick <= 1'b0;
		end
	end
end

endmodule
