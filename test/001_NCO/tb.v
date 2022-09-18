`timescale 1ns / 1ps
module tb;

reg CLK = 1'b0;
reg RSTb = 1'b0;

always #5 CLK <= !CLK; // 100MHz

initial begin 
	#150 RSTb = 1'b1;
end

wire [39:0] phase_inc = 40'ha7c5ac; // 1000 Hz?
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

initial begin
	$dumpfile("dump.vcd");
	$dumpvars(0, tb);
	# 2000000 $finish;
end



endmodule;
