module cosTable(input clk, input [3:0] addr, output reg [7:0] data);
reg [7:0] mem [0:15];
initial mem[0] = 16'h7f;
initial mem[1] = 16'h75;
initial mem[2] = 16'h59;
initial mem[3] = 16'h30;
initial mem[4] = 16'h0;
initial mem[5] = 16'hd0;
initial mem[6] = 16'ha7;
initial mem[7] = 16'h8b;
initial mem[8] = 16'h81;
initial mem[9] = 16'h8b;
initial mem[10] = 16'ha7;
initial mem[11] = 16'hd0;
initial mem[12] = 16'h0;
initial mem[13] = 16'h30;
initial mem[14] = 16'h59;
initial mem[15] = 16'h75;
always @(posedge clk) begin
	data <= mem[addr];
end
endmodule
