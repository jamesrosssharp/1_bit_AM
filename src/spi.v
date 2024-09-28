/* vim: set et ts=4 sw=4: */

/*
	1-bit AM radio

spi.v: SPI configuration

License: MIT License

Copyright 2023 J.R.Sharp

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

module spi
(
    input CLK,
    input RSTb,
    input MOSI,
    input SCK,
    input CS,

    output reg [25:0] phase_inc = 26'h1312eb,
    output reg [3:0]  gain

);

localparam state_idle = 2'b00;
localparam state_rx   = 2'b01;
localparam state_done = 2'b10;

reg [31:0] shift_reg = 32'h1312eb;

reg [1:0] state = state_idle;

reg CS_q;
reg CS_qq;
reg CS_qqq;

reg SCK_q;
reg SCK_qq;
reg SCK_qqq;

reg MOSI_q;
reg MOSI_qq;

always @(posedge CLK)
begin
    if (RSTb == 1'b0) begin
        state <= state_idle;
        gain <= 3'd7;
    end
    else begin
        CS_q    <= CS;
        CS_qq   <= CS_q;
        CS_qqq  <= CS_qq;

        SCK_q   <= SCK;
        SCK_qq  <= SCK_q;
        SCK_qqq <= SCK_qq;

        MOSI_q  <= MOSI;
        MOSI_qq <= MOSI_q;

        case (state)
            state_idle:
                if (CS_qq == 1'b0 && CS_qqq == 1'b1) begin // falling edge of chip select
                    state       <= state_rx;
                    shift_reg   <= 32'd0;
                end
            state_rx: begin
                if (SCK_qq == 1'b1 && SCK_qqq == 1'b0) begin // rising edge
                    shift_reg <= {shift_reg[30:0], MOSI_qq};     
                end

                if (CS_qq == 1'b1 && CS_qqq == 1'b0) begin
                    state <= state_done;
                end
            end
            state_done: begin
                phase_inc <= shift_reg[25:0];
                gain      <= shift_reg[28:26];
                state <= state_idle;
            end
        endcase
    end        
end

endmodule
