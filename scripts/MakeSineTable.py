#!/usr/bin/python3

import math

theFile = open("../src/sine_table.v", "w")
theFile2 = open("../src/cos_table.v", "w")

theFile.write("module sinTable(input clk, input [9:0] addr, output reg [15:0] data);\n")
theFile.write("reg [15:0] mem [0:1023];\n")

theFile2.write("module cosTable(input clk, input [9:0] addr, output reg [15:0] data);\n")
theFile2.write("reg [15:0] mem [0:1023];\n")

for i in range(0, 1024):
	sinval = math.sin((i / 1024.0) * 2*math.pi) * ((1 << 15) - 1)
	text = "initial mem[%d] = 16'h%x;\n" % (i, int(sinval) & 0xffff)
	theFile.write(text)
	cosval = math.cos((i / 1024.0) * 2*math.pi) * ((1<<15) - 1)
	text = "initial mem[%d] = 16'h%x;\n" % (i, int(cosval) & 0xffff)
	theFile2.write(text)

theFile.write("always @(posedge clk) begin\n")
theFile.write("\tdata <= mem[addr];\n")
theFile.write("end\n")

theFile.write("endmodule\n")
theFile.close()

theFile2.write("always @(posedge clk) begin\n")
theFile2.write("\tdata <= mem[addr];\n")
theFile2.write("end\n")

theFile2.write("endmodule\n")
theFile2.close()

