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

module test_soc_interface;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [7:0] input_axis_tdata = 8'd0;
reg input_axis_tvalid = 1'b0;
reg input_axis_tlast = 1'b0;
reg output_axis_tready = 1'b0;

reg  port0_cmd_empty = 1'b0;
reg  port0_cmd_full = 1'b0;
reg  port0_wr_empty = 1'b0;
reg  port0_wr_full = 1'b0;
reg  port0_wr_underrun = 1'b0;
reg [6:0] port0_wr_count = 7'b0;
reg  port0_wr_error = 1'b0;
reg [31:0] port0_rd_data = 32'b0;
reg  port0_rd_empty = 1'b0;
reg  port0_rd_full = 1'b0;
reg  port0_rd_overflow = 1'b0;
reg [6:0] port0_rd_count = 7'b0;
reg  port0_rd_error = 1'b0;

reg  port1_cmd_empty = 1'b0;
reg  port1_cmd_full = 1'b0;
reg  port1_wr_empty = 1'b0;
reg  port1_wr_full = 1'b0;
reg  port1_wr_underrun = 1'b0;
reg [6:0] port1_wr_count = 7'b0;
reg  port1_wr_error = 1'b0;
reg [31:0] port1_rd_data = 32'b0;
reg  port1_rd_empty = 1'b0;
reg  port1_rd_full = 1'b0;
reg  port1_rd_overflow = 1'b0;
reg [6:0] port1_rd_count = 7'b0;
reg  port1_rd_error = 1'b0;

// Outputs
wire input_axis_tready;
wire [7:0] output_axis_tdata;
wire output_axis_tvalid;
wire output_axis_tlast;

wire port0_cmd_clk;
wire port0_cmd_en;
wire [2:0] port0_cmd_instr;
wire [5:0] port0_cmd_bl;
wire [31:0] port0_cmd_byte_addr;
wire port0_wr_clk;
wire port0_wr_en;
wire [3:0] port0_wr_mask;
wire [31:0] port0_wr_data;
wire port0_rd_clk;
wire port0_rd_en;

wire port1_cmd_clk;
wire port1_cmd_en;
wire [2:0] port1_cmd_instr;
wire [5:0] port1_cmd_bl;
wire [31:0] port1_cmd_byte_addr;
wire port1_wr_clk;
wire port1_wr_en;
wire [3:0] port1_wr_mask;
wire [31:0] port1_wr_data;
wire port1_rd_clk;
wire port1_rd_en;

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
                port0_cmd_empty,
                port0_cmd_full,
                port0_wr_empty,
                port0_wr_full,
                port0_wr_underrun,
                port0_wr_count,
                port0_wr_error,
                port0_rd_data,
                port0_rd_empty,
                port0_rd_full,
                port0_rd_overflow,
                port0_rd_count,
                port0_rd_error,
                port1_cmd_empty,
                port1_cmd_full,
                port1_wr_empty,
                port1_wr_full,
                port1_wr_underrun,
                port1_wr_count,
                port1_wr_error,
                port1_rd_data,
                port1_rd_empty,
                port1_rd_full,
                port1_rd_overflow,
                port1_rd_count,
                port1_rd_error);
    $to_myhdl(input_axis_tready,
                output_axis_tdata,
                output_axis_tvalid,
                output_axis_tlast,
                port0_cmd_clk,
                port0_cmd_en,
                port0_cmd_instr,
                port0_cmd_bl,
                port0_cmd_byte_addr,
                port0_wr_clk,
                port0_wr_en,
                port0_wr_mask,
                port0_wr_data,
                port0_rd_clk,
                port0_rd_en,
                port1_cmd_clk,
                port1_cmd_en,
                port1_cmd_instr,
                port1_cmd_bl,
                port1_cmd_byte_addr,
                port1_wr_clk,
                port1_wr_en,
                port1_wr_mask,
                port1_wr_data,
                port1_rd_clk,
                port1_rd_en,
                busy);

    // dump file
    $dumpfile("test_soc_interface.lxt");
    $dumpvars(0, test_soc_interface);
end

soc_interface
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
    // mcb interface port 0
    .port0_cmd_clk(port0_cmd_clk),
    .port0_cmd_en(port0_cmd_en),
    .port0_cmd_instr(port0_cmd_instr),
    .port0_cmd_bl(port0_cmd_bl),
    .port0_cmd_byte_addr(port0_cmd_byte_addr),
    .port0_cmd_empty(port0_cmd_empty),
    .port0_cmd_full(port0_cmd_full),
    .port0_wr_clk(port0_wr_clk),
    .port0_wr_en(port0_wr_en),
    .port0_wr_mask(port0_wr_mask),
    .port0_wr_data(port0_wr_data),
    .port0_wr_empty(port0_wr_empty),
    .port0_wr_full(port0_wr_full),
    .port0_wr_underrun(port0_wr_underrun),
    .port0_wr_count(port0_wr_count),
    .port0_wr_error(port0_wr_error),
    .port0_rd_clk(port0_rd_clk),
    .port0_rd_en(port0_rd_en),
    .port0_rd_data(port0_rd_data),
    .port0_rd_empty(port0_rd_empty),
    .port0_rd_full(port0_rd_full),
    .port0_rd_overflow(port0_rd_overflow),
    .port0_rd_count(port0_rd_count),
    .port0_rd_error(port0_rd_error),
    // mcb interface port 1
    .port1_cmd_clk(port1_cmd_clk),
    .port1_cmd_en(port1_cmd_en),
    .port1_cmd_instr(port1_cmd_instr),
    .port1_cmd_bl(port1_cmd_bl),
    .port1_cmd_byte_addr(port1_cmd_byte_addr),
    .port1_cmd_empty(port1_cmd_empty),
    .port1_cmd_full(port1_cmd_full),
    .port1_wr_clk(port1_wr_clk),
    .port1_wr_en(port1_wr_en),
    .port1_wr_mask(port1_wr_mask),
    .port1_wr_data(port1_wr_data),
    .port1_wr_empty(port1_wr_empty),
    .port1_wr_full(port1_wr_full),
    .port1_wr_underrun(port1_wr_underrun),
    .port1_wr_count(port1_wr_count),
    .port1_wr_error(port1_wr_error),
    .port1_rd_clk(port1_rd_clk),
    .port1_rd_en(port1_rd_en),
    .port1_rd_data(port1_rd_data),
    .port1_rd_empty(port1_rd_empty),
    .port1_rd_full(port1_rd_full),
    .port1_rd_overflow(port1_rd_overflow),
    .port1_rd_count(port1_rd_count),
    .port1_rd_error(port1_rd_error),
    // status
    .busy(busy)
);

endmodule
