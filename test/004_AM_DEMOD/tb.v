`timescale 1ns / 1ps
module tb;

reg CLK = 1'b0;
reg RSTb = 1'b0;

always #5 CLK <= !CLK; // 100MHz

initial begin 
	#150 RSTb = 1'b1;
end

// Load 1bit_rf.txt into a "memory"

reg memory [2**26 - 1:0];

initial begin
	$display("Loading rom.");
	$readmemh("1bit_rf.txt", memory);
end


wire [39:0] phase_inc = 40'h2656abde3; // 936 kHz
wire [15:0] sin;
wire [15:0] cos;

nco nco0
(
	CLK,
	RSTb,

	phase_inc,

	sin,
	cos
);

wire RF_out;
reg RF_in;
reg [25:0] addr = 26'd0;

always @(posedge CLK)
begin
	addr <= addr + 1;
	RF_in <= memory[addr];
end

wire [15:0] I_out;
wire [15:0] Q_out;

mixer mix0 
(
	CLK,
	RSTb,

	RF_in,
	RF_out,

	sin,
	cos,

	I_out,
	Q_out	
);

// Instantiate CIC

wire [15:0] xI_out;
wire [15:0] xQ_out;
wire out_tickI;
wire out_tickQ;

cic cic0
(
	CLK,
	RSTb,
	I_out,
	3'b000,
	xI_out,
	out_tickI
);

cic cic1
(
	CLK,
	RSTb,
	Q_out,
	3'b000,
	xQ_out,
	out_tickQ
);

wire out_tick;
wire [15:0] demod_out;

am_demod am0 
(
	CLK,
	RSTb,

	xI_out,
	xQ_out,
	out_tickI,	/* tick should go high when new sample is ready */

	demod_out,
	out_tick	/* tick will go high when the new AM demodulated sample is ready */

);




initial begin
	$dumpfile("dump.vcd");
	$dumpvars(0, tb);
	# 20000000 $finish;
end

endmodule;
