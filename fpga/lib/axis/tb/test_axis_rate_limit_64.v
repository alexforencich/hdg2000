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

module test_axis_rate_limit_64;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [63:0] input_axis_tdata = 8'd0;
reg [7:0] input_axis_tkeep = 8'd0;
reg input_axis_tvalid = 1'b0;
reg input_axis_tlast = 1'b0;
reg input_axis_tuser = 1'b0;
reg output_axis_tready = 1'b0;
reg [7:0] rate_num = 0;
reg [7:0] rate_denom = 0;
reg rate_by_frame = 0;

// Outputs
wire input_axis_tready;
wire [63:0] output_axis_tdata;
wire [7:0] output_axis_tkeep;
wire output_axis_tvalid;
wire output_axis_tlast;
wire output_axis_tuser;

initial begin
    // myhdl integration
    $from_myhdl(clk,
                rst,
                current_test,
                input_axis_tdata,
                input_axis_tkeep,
                input_axis_tvalid,
                input_axis_tlast,
                input_axis_tuser,
                output_axis_tready,
                rate_num,
                rate_denom,
                rate_by_frame);
    $to_myhdl(input_axis_tready,
                output_axis_tdata,
                output_axis_tkeep,
                output_axis_tvalid,
                output_axis_tlast,
                output_axis_tuser);

    // dump file
    $dumpfile("test_axis_rate_limit_64.lxt");
    $dumpvars(0, test_axis_rate_limit_64);
end

axis_rate_limit_64 #(
    .DATA_WIDTH(64)
)
UUT (
    .clk(clk),
    .rst(rst),
    // axi input
    .input_axis_tdata(input_axis_tdata),
    .input_axis_tkeep(input_axis_tkeep),
    .input_axis_tvalid(input_axis_tvalid),
    .input_axis_tready(input_axis_tready),
    .input_axis_tlast(input_axis_tlast),
    .input_axis_tuser(input_axis_tuser),
    // axi output
    .output_axis_tdata(output_axis_tdata),
    .output_axis_tkeep(output_axis_tkeep),
    .output_axis_tvalid(output_axis_tvalid),
    .output_axis_tready(output_axis_tready),
    .output_axis_tlast(output_axis_tlast),
    .output_axis_tuser(output_axis_tuser),
    // configuration
    .rate_num(rate_num),
    .rate_denom(rate_denom),
    .rate_by_frame(rate_by_frame)
);

endmodule
