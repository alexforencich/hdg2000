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

`timescale 1 ns / 1 ps

module test_srl_fifo_reg;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg write_en = 0;
reg [7:0] write_data = 0;
reg read_en = 0;

// Outputs
wire [7:0] read_data;
wire full;
wire empty;

initial begin
    // myhdl integration
    $from_myhdl(clk,
                rst,
                current_test,
                write_en,
                write_data,
                read_en);
    $to_myhdl(read_data,
                full,
                empty);

    // dump file
    $dumpfile("test_srl_fifo_reg.lxt");
    $dumpvars(0, test_srl_fifo_reg);
end

srl_fifo_reg #(
    .WIDTH(8)
)
UUT (
    .clk(clk),
    .rst(rst),
    .write_en(write_en),
    .write_data(write_data),
    .read_en(read_en),
    .read_data(read_data),
    .full(full),
    .empty(empty)
);

endmodule
