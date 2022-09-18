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


wire [39:0] phase_inc = 40'h2656abde3; // 1000 Hz?
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

wire [15:0] x_out;
wire out_tick;

cic cic0
(
	CLK,
	RSTb,
	I_out,
	3'b000,
	x_out,
	out_tick
);



initial begin
	$dumpfile("dump.vcd");
	$dumpvars(0, tb);
	# 20000000 $finish;
end

endmodule;
