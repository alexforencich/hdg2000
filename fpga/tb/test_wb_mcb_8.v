/*

Copyright (c) 2015 Alex Forencich

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
 * Testbench for wb_mcb_8
 */
module test_wb_mcb_8;

// Parameters

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [31:0] wb_adr_i = 0;
reg [7:0] wb_dat_i = 0;
reg wb_we_i = 0;
reg wb_stb_i = 0;
reg wb_cyc_i = 0;
reg mcb_cmd_empty = 0;
reg mcb_cmd_full = 0;
reg mcb_wr_empty = 0;
reg mcb_wr_full = 0;
reg mcb_wr_underrun = 0;
reg [6:0] mcb_wr_count = 0;
reg mcb_wr_error = 0;
reg [31:0] mcb_rd_data = 0;
reg mcb_rd_empty = 0;
reg mcb_rd_full = 0;
reg mcb_rd_overflow = 0;
reg [6:0] mcb_rd_count = 0;
reg mcb_rd_error = 0;

// Outputs
wire [7:0] wb_dat_o;
wire wb_ack_o;
wire mcb_cmd_clk;
wire mcb_cmd_en;
wire [2:0] mcb_cmd_instr;
wire [5:0] mcb_cmd_bl;
wire [31:0] mcb_cmd_byte_addr;
wire mcb_wr_clk;
wire mcb_wr_en;
wire [3:0] mcb_wr_mask;
wire [31:0] mcb_wr_data;
wire mcb_rd_clk;
wire mcb_rd_en;

initial begin
    // myhdl integration
    $from_myhdl(clk,
                rst,
                current_test,
                wb_adr_i,
                wb_dat_i,
                wb_we_i,
                wb_stb_i,
                wb_cyc_i,
                mcb_cmd_empty,
                mcb_cmd_full,
                mcb_wr_empty,
                mcb_wr_full,
                mcb_wr_underrun,
                mcb_wr_count,
                mcb_wr_error,
                mcb_rd_data,
                mcb_rd_empty,
                mcb_rd_full,
                mcb_rd_overflow,
                mcb_rd_count,
                mcb_rd_error);
    $to_myhdl(wb_dat_o,
              wb_ack_o,
              mcb_cmd_clk,
              mcb_cmd_en,
              mcb_cmd_instr,
              mcb_cmd_bl,
              mcb_cmd_byte_addr,
              mcb_wr_clk,
              mcb_wr_en,
              mcb_wr_mask,
              mcb_wr_data,
              mcb_rd_clk,
              mcb_rd_en);

    // dump file
    $dumpfile("test_wb_mcb_8.lxt");
    $dumpvars(0, test_wb_mcb_8);
end

wb_mcb_8
UUT (
    .clk(clk),
    .rst(rst),
    .wb_adr_i(wb_adr_i),
    .wb_dat_i(wb_dat_i),
    .wb_dat_o(wb_dat_o),
    .wb_we_i(wb_we_i),
    .wb_stb_i(wb_stb_i),
    .wb_ack_o(wb_ack_o),
    .wb_cyc_i(wb_cyc_i),
    .mcb_cmd_clk(mcb_cmd_clk),
    .mcb_cmd_en(mcb_cmd_en),
    .mcb_cmd_instr(mcb_cmd_instr),
    .mcb_cmd_bl(mcb_cmd_bl),
    .mcb_cmd_byte_addr(mcb_cmd_byte_addr),
    .mcb_cmd_empty(mcb_cmd_empty),
    .mcb_cmd_full(mcb_cmd_full),
    .mcb_wr_clk(mcb_wr_clk),
    .mcb_wr_en(mcb_wr_en),
    .mcb_wr_mask(mcb_wr_mask),
    .mcb_wr_data(mcb_wr_data),
    .mcb_wr_empty(mcb_wr_empty),
    .mcb_wr_full(mcb_wr_full),
    .mcb_wr_underrun(mcb_wr_underrun),
    .mcb_wr_count(mcb_wr_count),
    .mcb_wr_error(mcb_wr_error),
    .mcb_rd_clk(mcb_rd_clk),
    .mcb_rd_en(mcb_rd_en),
    .mcb_rd_data(mcb_rd_data),
    .mcb_rd_empty(mcb_rd_empty),
    .mcb_rd_full(mcb_rd_full),
    .mcb_rd_overflow(mcb_rd_overflow),
    .mcb_rd_count(mcb_rd_count),
    .mcb_rd_error(mcb_rd_error)
);

endmodule
