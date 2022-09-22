/*
 *	(C) 2022 J. R. Sharp
 *
 *	See LICENSE.txt for software license
 */

module audio
#(parameter BITS = 16, CLK_FREQ = 2500000)
(
	input CLK,	
	input RSTb,

	// Port interface
	input 	[BITS - 1 : 0] DATA_IN,

	// I2S 
	output 	mclk,
	output 	lr_clk,
	output 	sclk,
	output 	sdat	
);

localparam MCLK_FREQ  = CLK_FREQ / 2;
localparam LRCLK_FREQ = MCLK_FREQ / 512;
localparam SCLK_FREQ  = LRCLK_FREQ * 64;


assign mclk = CLK;

reg lr_clk_r = 1'b0;
reg lr_clk_r_next;

assign lr_clk = lr_clk_r;

reg sclk_r = 1'b0;
reg sclk_r_next;

assign sclk = sclk_r;

reg [8:0] lr_clk_count_r = 0; // CLK / 512
reg [2:0] sclk_count_r = 0;   // CLK / 16

reg [63:0] serial_data_r = {64{1'b0}};
reg [63:0] serial_data_r_next;

assign sdat = serial_data_r[63]; // serial data out


always @(posedge CLK)
begin
	lr_clk_count_r 	<= lr_clk_count_r + 1;	
	sclk_count_r 	<= sclk_count_r + 1;
	lr_clk_r 		<= lr_clk_r_next;
	sclk_r 			<= sclk_r_next;
	serial_data_r 	<= serial_data_r_next;
end

always @(*)
begin
	lr_clk_r_next = lr_clk_r;
	sclk_r_next = sclk_r;
	if (lr_clk_count_r == 9'd0)
		lr_clk_r_next = !lr_clk_r;
	if (sclk_count_r == 3'd0)
		sclk_r_next = !sclk_r;
end

always @(*)
begin
	serial_data_r_next = serial_data_r;

	if (lr_clk_r_next != lr_clk_r) begin
		serial_data_r_next = {64{1'b0}};

		if (lr_clk_r == 1'b0) begin // Left channel going to right channel
			serial_data_r_next[62:47] = DATA_IN;
		end else begin
			serial_data_r_next[62:47] = /*16'h0000;*/ DATA_IN;
		end

	end
	else if (sclk_r_next == 1'b0 && sclk_r == 1'b1) begin
		serial_data_r_next = {serial_data_r[62:0],1'b0};
	end

end

endmodule
