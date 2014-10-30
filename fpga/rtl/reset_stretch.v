/*

Copyright (c) 2014 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * Clock management
 */
module reset_stretch #(
    parameter N = 4
)(
    input  wire clk,
    input  wire rst_in,
    output wire rst_out
);

reg reset_reg = 1;
reg [N-1:0] count_reg = 0;

assign rst_out = reset_reg;

// async assert, hold reset for 2^N clocks
always @(posedge clk or posedge rst_in) begin
    if (rst_in) begin
        // reset
        count_reg <= 0;
        reset_reg <= 1;
    end else begin
        if (&count_reg) begin
            reset_reg <= 0;
        end else begin
            reset_reg <= 1;
            count_reg <= count_reg + 1;
        end
    end
end

endmodule
