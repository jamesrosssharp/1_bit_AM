`timescale 1ns / 1ps
module tb;

reg CLK = 1'b0;
reg RSTb = 1'b0;

always #5 CLK <= !CLK; // 100MHz

initial begin 
	#150 RSTb = 1'b1;
end

wire one_bit_rf;

am_gen am0
(
        CLK,
        RSTb,
        one_bit_rf
);



initial begin
	$dumpfile("dump.vcd");
	$dumpvars(0, tb);
	# 20000000 $finish;
end

endmodule;
