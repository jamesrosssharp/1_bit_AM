#!/usr/bin/python3

import math
import numpy as np

theFile = open("../src/noise_table.v", "w")

theFile.write("module noiseTable(input clk, input [9:0] addr, output reg [15:0] data);\n")
theFile.write("reg [15:0] mem [0:1023];\n")


for i in range(0, 1024):
	noiseval = (np.random.random() - 0.5) * 0.5 * 32767
	text = "initial mem[%d] = 16'h%x;\n" % (i, int(noiseval) & 0xffff)
	theFile.write(text)

theFile.write("always @(posedge clk) begin\n")
theFile.write("\tdata <= mem[addr];\n")
theFile.write("end\n")

theFile.write("endmodule\n")
theFile.close()

