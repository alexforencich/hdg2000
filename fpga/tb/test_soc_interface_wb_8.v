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

module test_soc_interface_wb_8;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [7:0] input_axis_tdata = 0;
reg input_axis_tvalid = 0;
reg input_axis_tlast = 0;
reg output_axis_tready = 0;

reg [7:0] wb_dat_i = 0;
reg wb_ack_i = 0;
reg wb_err_i = 0;

// Outputs
wire input_axis_tready;
wire [7:0] output_axis_tdata;
wire output_axis_tvalid;
wire output_axis_tlast;

wire [35:0] wb_adr_o;
wire [7:0] wb_dat_o;
wire wb_we_o;
wire wb_stb_o;
wire wb_cyc_o;

wire busy;

initial begin
    // myhdl integration
    $from_myhdl(clk,
                rst,
                current_test,
                input_axis_tdata,
                input_axis_tvalid,
                input_axis_tlast,
                output_axis_tready,
                wb_dat_i,
                wb_ack_i,
                wb_err_i);
    $to_myhdl(input_axis_tready,
                output_axis_tdata,
                output_axis_tvalid,
                output_axis_tlast,
                wb_adr_o,
                wb_dat_o,
                wb_we_o,
                wb_stb_o,
                wb_cyc_o,
                busy);

    // dump file
    $dumpfile("test_soc_interface_wb_8.lxt");
    $dumpvars(0, test_soc_interface_wb_8);
end

soc_interface_wb_8
UUT (
    .clk(clk),
    .rst(rst),
    // axi input
    .input_axis_tdata(input_axis_tdata),
    .input_axis_tvalid(input_axis_tvalid),
    .input_axis_tready(input_axis_tready),
    .input_axis_tlast(input_axis_tlast),
    // axi output
    .output_axis_tdata(output_axis_tdata),
    .output_axis_tvalid(output_axis_tvalid),
    .output_axis_tready(output_axis_tready),
    .output_axis_tlast(output_axis_tlast),
    // WB interface
    .wb_adr_o(wb_adr_o),
    .wb_dat_i(wb_dat_i),
    .wb_dat_o(wb_dat_o),
    .wb_we_o(wb_we_o),
    .wb_stb_o(wb_stb_o),
    .wb_ack_i(wb_ack_i),
    .wb_err_i(wb_err_i),
    .wb_cyc_o(wb_cyc_o),
    // status
    .busy(busy)
);

endmodule
