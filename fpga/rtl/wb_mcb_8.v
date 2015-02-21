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
 * Wishbone wrapper for MCB interface
 */
module wb_mcb_8
(
    input  wire        clk,
    input  wire        rst,

    /*
     * Wishbone interface
     */
    input  wire [31:0] wb_adr_i,     // ADR_I() address input
    input  wire [7:0]  wb_dat_i,     // DAT_I() data in
    output wire [7:0]  wb_dat_o,     // DAT_O() data out
    input  wire        wb_we_i,      // WE_I write enable input
    input  wire        wb_stb_i,     // STB_I strobe input
    output wire        wb_ack_o,     // ACK_O acknowledge output
    input  wire        wb_cyc_i,     // CYC_I cycle input

    /*
     * MCB interface
     */
    output wire        mcb_cmd_clk,
    output wire        mcb_cmd_en,
    output wire [2:0]  mcb_cmd_instr,
    output wire [5:0]  mcb_cmd_bl,
    output wire [31:0] mcb_cmd_byte_addr,
    input  wire        mcb_cmd_empty,
    input  wire        mcb_cmd_full,
    output wire        mcb_wr_clk,
    output wire        mcb_wr_en,
    output wire [3:0]  mcb_wr_mask,
    output wire [31:0] mcb_wr_data,
    input  wire        mcb_wr_empty,
    input  wire        mcb_wr_full,
    input  wire        mcb_wr_underrun,
    input  wire [6:0]  mcb_wr_count,
    input  wire        mcb_wr_error,
    output wire        mcb_rd_clk,
    output wire        mcb_rd_en,
    input  wire [31:0] mcb_rd_data,
    input  wire        mcb_rd_empty,
    input  wire        mcb_rd_full,
    input  wire        mcb_rd_overflow,
    input  wire [6:0]  mcb_rd_count,
    input  wire        mcb_rd_error
);

reg cycle_reg = 0;

reg [7:0] wb_dat_reg = 0;
reg wb_ack_reg = 0;

reg mcb_cmd_en_reg = 0;
reg mcb_cmd_instr_reg = 0;
reg mcb_wr_en_reg = 0;
reg [3:0] mcb_wr_mask_reg = 0;

assign wb_dat_o = wb_dat_reg;
assign wb_ack_o = wb_ack_reg;

assign mcb_cmd_clk = clk;
assign mcb_cmd_en = mcb_cmd_en_reg;
assign mcb_cmd_instr = mcb_cmd_instr_reg;
assign mcb_cmd_bl = 0;
assign mcb_cmd_byte_addr = wb_adr_i & 32'hFFFFFFFC;
assign mcb_wr_clk = clk;
assign mcb_wr_en = mcb_wr_en_reg;
assign mcb_wr_mask = mcb_wr_mask_reg;
assign mcb_wr_data = {wb_dat_i, wb_dat_i, wb_dat_i, wb_dat_i};
assign mcb_rd_clk = clk;
assign mcb_rd_en = 1;

always @(posedge clk) begin
    if (rst) begin
        cycle_reg <= 0;
        mcb_cmd_en_reg <= 0;
        mcb_cmd_instr_reg <= 0;
        mcb_wr_en_reg <= 0;
    end else begin
        wb_ack_reg <= 0;
        mcb_cmd_en_reg <= 0;
        mcb_cmd_instr_reg <= 0;
        mcb_wr_en_reg <= 0;

        if (cycle_reg) begin
            if (~mcb_rd_empty) begin
                cycle_reg <= 0;
                wb_dat_reg <= mcb_rd_data[8*(wb_adr_i & 3) +: 8];
                wb_ack_reg <= 1;
            end
        end else if (wb_cyc_i & wb_stb_i & ~wb_ack_o) begin
            if (wb_we_i) begin
                mcb_cmd_instr_reg <= 3'b000;
                mcb_cmd_en_reg <= 1;
                mcb_wr_en_reg <= 1;
                mcb_wr_mask_reg <= ~(1 << (wb_adr_i & 3));
                wb_ack_reg <= 1;
            end else begin
                mcb_cmd_instr_reg <= 3'b001;
                mcb_cmd_en_reg <= 1;
                cycle_reg <= 1;
            end
        end
    end
end

endmodule
