/*
 *	(C) 2022 J. R. Sharp
 *
 *	Based on https://hackaday.io/project/170916-fpga-3-r-1-c-mw-and-sw-sdr-receiver by
 *	Alberto Garlassi
 *
 *	See LICENSE.txt for software license
 */

module am_demod_lite #(
	parameter BITS_IN = 8,		/* must be 8 */
	parameter BITS = 16	/* must be 16 for square root to work */
)
(
	input CLK,
	input RSTb,

	input signed [BITS_IN - 1 : 0] I_in,
	input signed [BITS_IN - 1 : 0] Q_in,
	input load_tick,	/* tick should go high when new sample is ready */

	output reg signed [BITS - 1:0] demod_out,
	output reg out_tick	/* tick will go high when the new AM demodulated sample is ready */

);

localparam st_idle 		= 4'd0;
localparam st_start_mult_I	= 4'd1;
localparam st_multiply_I 	= 4'd2;
localparam st_start_mult_Q	= 4'd3;
localparam st_multiply_Q 	= 4'd4;
localparam st_start_sqrt 	= 4'd6;
localparam st_wait_sqrt 	= 4'd7;

reg [3:0] state;

reg sqrt_done = 1'b0;


reg signed [BITS  : 0] 	multA;
reg  [BITS_IN - 1 : 0] 	multB;


reg [BITS : 0] sum;

reg [3:0] m_count;

always @(posedge CLK)
begin

	if (RSTb == 1'b0) begin
		state <= st_idle;
	end else begin
		case (state)
			st_idle:
				if (load_tick == 1'b1) begin
					state <= st_start_mult_I;
					sum <= {BITS + 1 {1'b0}};
				end
			st_start_mult_I: begin
				state <= st_multiply_I;	
				multA <= $signed(I_in);
				multB <= I_in;
				m_count <= 4'd0;
			end
			st_multiply_I: begin

				m_count <= m_count + 1;
				if (m_count == 4'd7)
					state <= st_start_mult_Q;	
				
				if (multB[0])
				begin
					case (m_count)
						4'd7:
							sum = sum - multA;
						default:
							sum = sum + multA;
					endcase
				end

				multA <= multA << 1;
				multB <= multB >> 1;
			end	
			st_start_mult_Q: begin
				state <= st_multiply_Q;	
				multA <= $signed(Q_in);
				multB <= Q_in;
				m_count <= 4'd0;
			end
			st_multiply_Q: begin

				m_count <= m_count + 1;
				if (m_count == 4'd7)
					state <= st_start_sqrt;	
				if (multB[0])
				begin
					case (m_count)
						4'd7:
							sum = sum - multA;
						default:
							sum = sum + multA;
					endcase
				end

				multA <= multA << 1;
				multB <= multB >> 1;
			end	
			st_start_sqrt:
				state <= st_wait_sqrt;
			st_wait_sqrt:
				if (sqrt_done == 1'b1)
					state <= st_idle;
			default:
				state <= st_idle;				
		endcase
	end 
end

reg [1:0] sqrt_state;

/*
 *	We Pipeline the "non-restoring" Square root algorithm used by 
 *	Alberto: https://verilogcodes.blogspot.com/2017/11/a-verilog-function-for-finding-square-root.html
 *	In this way, we (hopefully) do not have to create a new clock domain for the amplitude demodulation.
 *
 */

reg [BITS-1:0] a;
reg [BITS_IN-1:0] q;
reg [BITS_IN+1:0] left, right, r;

reg [1:0] count;
reg [3:0] count2;
    
   
localparam BITS_PLUS_2 = BITS_IN + 2;

always @(posedge CLK)
begin
	if (RSTb == 1'b0) begin
		sqrt_state <= 2'd0;
		demod_out <= {BITS_IN{1'b0}};
		out_tick <= 1'b0;
	end else begin

		case (sqrt_state)
			2'd0: begin
				out_tick <= 1'b0;
				sqrt_done <= 1'b0;
				if (state == st_start_sqrt)
					sqrt_state <= sqrt_state + 1;		
			end
			2'd1: begin
				a <= sum[BITS:1];
				left <= {BITS_PLUS_2{1'b0}};
				right <= {BITS_PLUS_2{1'b0}};
				r <= {BITS_PLUS_2{1'b0}};
				q <= {BITS_IN{1'b0}};
				sqrt_state <= sqrt_state + 1;
				count <= 2'd0;
				count2 <= 4'd0;
			end
			2'd2: begin

				case (count)
					2'd0: begin
						right <= {q,r[BITS_PLUS_2 - 1],1'b1};
						left  <= {r[BITS_IN - 1:0],a[2*BITS_IN - 1:2*BITS_IN - 2]};
						a     <= {a[2*BITS - 3:0],2'b00};    //left shift by 2 bits.
						count <= count + 1;
					end
					2'd1: begin

						if (r[BITS_PLUS_2 - 1] == 1'b1) //add if r is negative
				    			r <= left + right;
						else    //subtract if r is positive
				    			r <= left - right;
						count <= count + 1;
					end
					2'd2: begin
						q <= {q[BITS_IN - 2:0],!r[BITS_PLUS_2 - 1]}; 
						count <= 2'd0;
						count2 <= count2 + 1;
						if (count2 == 4'd7)
							sqrt_state <= sqrt_state + 1;
					end
				endcase	

			end
			2'd3: begin
				out_tick <= 1'b1;
				sqrt_state <= 2'd0;	
				demod_out <= {q,8'd0};
				sqrt_done <= 1'b1;
			end
			default:
				sqrt_state <= 2'd0;		
		endcase
	end 
end


endmodule
