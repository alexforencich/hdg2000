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
 * Hantek HDG2000 FPGA
 */
module fpga_core
(
    // clocks
    input  wire  clk_250mhz_int,
    input  wire  rst_250mhz_int,

    input  wire  clk_250mhz,
    input  wire  rst_250mhz,

    input  wire  clk_10mhz,
    input  wire  rst_10mhz,

    input  wire  ext_clock_selected,

    // SoC interface
    input  wire  cntrl_cs,
    input  wire  cntrl_sck,
    input  wire  cntrl_mosi,
    output wire  cntrl_miso,

    // Trigger
    input  wire  ext_trig,

    // Frequency counter
    input  wire  ext_prescale,

    // Front end relay control
    output wire  ferc_dat,
    output wire  ferc_clk,
    output wire  ferc_lat,

    // Analog mux
    output wire  [2:0] mux_s,

    // ADC
    output wire  adc_sclk,
    input  wire  adc_sdo,
    output wire  adc_sdi,
    output wire  adc_cs,
    input  wire  adc_eoc,
    output wire  adc_convst,

    // digital output
    output wire [15:0] dout,

    // Sync DAC
    output wire [7:0] sync_dac,

    // Main DAC
    output wire dac_clk,
    output wire [15:0] dac_p1_d,
    output wire [15:0] dac_p2_d,
    input  wire dac_sdo,
    output wire dac_sdio,
    output wire dac_sclk,
    output wire dac_csb,
    output wire dac_reset,

    // ram 1 MCB (U8)
    input  wire ram1_calib_done,

    output wire ram1_p0_cmd_clk,
    output wire ram1_p0_cmd_en,
    output wire [2:0] ram1_p0_cmd_instr,
    output wire [5:0] ram1_p0_cmd_bl,
    output wire [31:0] ram1_p0_cmd_byte_addr,
    input  wire ram1_p0_cmd_empty,
    input  wire ram1_p0_cmd_full,
    output wire ram1_p0_wr_clk,
    output wire ram1_p0_wr_en,
    output wire [3:0] ram1_p0_wr_mask,
    output wire [31:0] ram1_p0_wr_data,
    input  wire ram1_p0_wr_empty,
    input  wire ram1_p0_wr_full,
    input  wire ram1_p0_wr_underrun,
    input  wire [6:0] ram1_p0_wr_count,
    input  wire ram1_p0_wr_error,
    output wire ram1_p0_rd_clk,
    output wire ram1_p0_rd_en,
    input  wire [31:0] ram1_p0_rd_data,
    input  wire ram1_p0_rd_empty,
    input  wire ram1_p0_rd_full,
    input  wire ram1_p0_rd_overflow,
    input  wire [6:0] ram1_p0_rd_count,
    input  wire ram1_p0_rd_error,

    output wire ram1_p1_cmd_clk,
    output wire ram1_p1_cmd_en,
    output wire [2:0] ram1_p1_cmd_instr,
    output wire [5:0] ram1_p1_cmd_bl,
    output wire [31:0] ram1_p1_cmd_byte_addr,
    input  wire ram1_p1_cmd_empty,
    input  wire ram1_p1_cmd_full,
    output wire ram1_p1_wr_clk,
    output wire ram1_p1_wr_en,
    output wire [3:0] ram1_p1_wr_mask,
    output wire [31:0] ram1_p1_wr_data,
    input  wire ram1_p1_wr_empty,
    input  wire ram1_p1_wr_full,
    input  wire ram1_p1_wr_underrun,
    input  wire [6:0] ram1_p1_wr_count,
    input  wire ram1_p1_wr_error,
    output wire ram1_p1_rd_clk,
    output wire ram1_p1_rd_en,
    input  wire [31:0] ram1_p1_rd_data,
    input  wire ram1_p1_rd_empty,
    input  wire ram1_p1_rd_full,
    input  wire ram1_p1_rd_overflow,
    input  wire [6:0] ram1_p1_rd_count,
    input  wire ram1_p1_rd_error,

    output wire ram1_p2_cmd_clk,
    output wire ram1_p2_cmd_en,
    output wire [2:0] ram1_p2_cmd_instr,
    output wire [5:0] ram1_p2_cmd_bl,
    output wire [31:0] ram1_p2_cmd_byte_addr,
    input  wire ram1_p2_cmd_empty,
    input  wire ram1_p2_cmd_full,
    output wire ram1_p2_rd_clk,
    output wire ram1_p2_rd_en,
    input  wire [31:0] ram1_p2_rd_data,
    input  wire ram1_p2_rd_empty,
    input  wire ram1_p2_rd_full,
    input  wire ram1_p2_rd_overflow,
    input  wire [6:0] ram1_p2_rd_count,
    input  wire ram1_p2_rd_error,

    output wire ram1_p3_cmd_clk,
    output wire ram1_p3_cmd_en,
    output wire [2:0] ram1_p3_cmd_instr,
    output wire [5:0] ram1_p3_cmd_bl,
    output wire [31:0] ram1_p3_cmd_byte_addr,
    input  wire ram1_p3_cmd_empty,
    input  wire ram1_p3_cmd_full,
    output wire ram1_p3_rd_clk,
    output wire ram1_p3_rd_en,
    input  wire [31:0] ram1_p3_rd_data,
    input  wire ram1_p3_rd_empty,
    input  wire ram1_p3_rd_full,
    input  wire ram1_p3_rd_overflow,
    input  wire [6:0] ram1_p3_rd_count,
    input  wire ram1_p3_rd_error,

    output wire ram1_p4_cmd_clk,
    output wire ram1_p4_cmd_en,
    output wire [2:0] ram1_p4_cmd_instr,
    output wire [5:0] ram1_p4_cmd_bl,
    output wire [31:0] ram1_p4_cmd_byte_addr,
    input  wire ram1_p4_cmd_empty,
    input  wire ram1_p4_cmd_full,
    output wire ram1_p4_rd_clk,
    output wire ram1_p4_rd_en,
    input  wire [31:0] ram1_p4_rd_data,
    input  wire ram1_p4_rd_empty,
    input  wire ram1_p4_rd_full,
    input  wire ram1_p4_rd_overflow,
    input  wire [6:0] ram1_p4_rd_count,
    input  wire ram1_p4_rd_error,

    output wire ram1_p5_cmd_clk,
    output wire ram1_p5_cmd_en,
    output wire [2:0] ram1_p5_cmd_instr,
    output wire [5:0] ram1_p5_cmd_bl,
    output wire [31:0] ram1_p5_cmd_byte_addr,
    input  wire ram1_p5_cmd_empty,
    input  wire ram1_p5_cmd_full,
    output wire ram1_p5_rd_clk,
    output wire ram1_p5_rd_en,
    input  wire [31:0] ram1_p5_rd_data,
    input  wire ram1_p5_rd_empty,
    input  wire ram1_p5_rd_full,
    input  wire ram1_p5_rd_overflow,
    input  wire [6:0] ram1_p5_rd_count,
    input  wire ram1_p5_rd_error,

    // ram 2 MCB (U12)
    input  wire ram2_calib_done,

    output wire ram2_p0_cmd_clk,
    output wire ram2_p0_cmd_en,
    output wire [2:0] ram2_p0_cmd_instr,
    output wire [5:0] ram2_p0_cmd_bl,
    output wire [31:0] ram2_p0_cmd_byte_addr,
    input  wire ram2_p0_cmd_empty,
    input  wire ram2_p0_cmd_full,
    output wire ram2_p0_wr_clk,
    output wire ram2_p0_wr_en,
    output wire [3:0] ram2_p0_wr_mask,
    output wire [31:0] ram2_p0_wr_data,
    input  wire ram2_p0_wr_empty,
    input  wire ram2_p0_wr_full,
    input  wire ram2_p0_wr_underrun,
    input  wire [6:0] ram2_p0_wr_count,
    input  wire ram2_p0_wr_error,
    output wire ram2_p0_rd_clk,
    output wire ram2_p0_rd_en,
    input  wire [31:0] ram2_p0_rd_data,
    input  wire ram2_p0_rd_empty,
    input  wire ram2_p0_rd_full,
    input  wire ram2_p0_rd_overflow,
    input  wire [6:0] ram2_p0_rd_count,
    input  wire ram2_p0_rd_error,

    output wire ram2_p1_cmd_clk,
    output wire ram2_p1_cmd_en,
    output wire [2:0] ram2_p1_cmd_instr,
    output wire [5:0] ram2_p1_cmd_bl,
    output wire [31:0] ram2_p1_cmd_byte_addr,
    input  wire ram2_p1_cmd_empty,
    input  wire ram2_p1_cmd_full,
    output wire ram2_p1_wr_clk,
    output wire ram2_p1_wr_en,
    output wire [3:0] ram2_p1_wr_mask,
    output wire [31:0] ram2_p1_wr_data,
    input  wire ram2_p1_wr_empty,
    input  wire ram2_p1_wr_full,
    input  wire ram2_p1_wr_underrun,
    input  wire [6:0] ram2_p1_wr_count,
    input  wire ram2_p1_wr_error,
    output wire ram2_p1_rd_clk,
    output wire ram2_p1_rd_en,
    input  wire [31:0] ram2_p1_rd_data,
    input  wire ram2_p1_rd_empty,
    input  wire ram2_p1_rd_full,
    input  wire ram2_p1_rd_overflow,
    input  wire [6:0] ram2_p1_rd_count,
    input  wire ram2_p1_rd_error,

    output wire ram2_p2_cmd_clk,
    output wire ram2_p2_cmd_en,
    output wire [2:0] ram2_p2_cmd_instr,
    output wire [5:0] ram2_p2_cmd_bl,
    output wire [31:0] ram2_p2_cmd_byte_addr,
    input  wire ram2_p2_cmd_empty,
    input  wire ram2_p2_cmd_full,
    output wire ram2_p2_rd_clk,
    output wire ram2_p2_rd_en,
    input  wire [31:0] ram2_p2_rd_data,
    input  wire ram2_p2_rd_empty,
    input  wire ram2_p2_rd_full,
    input  wire ram2_p2_rd_overflow,
    input  wire [6:0] ram2_p2_rd_count,
    input  wire ram2_p2_rd_error,

    output wire ram2_p3_cmd_clk,
    output wire ram2_p3_cmd_en,
    output wire [2:0] ram2_p3_cmd_instr,
    output wire [5:0] ram2_p3_cmd_bl,
    output wire [31:0] ram2_p3_cmd_byte_addr,
    input  wire ram2_p3_cmd_empty,
    input  wire ram2_p3_cmd_full,
    output wire ram2_p3_rd_clk,
    output wire ram2_p3_rd_en,
    input  wire [31:0] ram2_p3_rd_data,
    input  wire ram2_p3_rd_empty,
    input  wire ram2_p3_rd_full,
    input  wire ram2_p3_rd_overflow,
    input  wire [6:0] ram2_p3_rd_count,
    input  wire ram2_p3_rd_error,

    output wire ram2_p4_cmd_clk,
    output wire ram2_p4_cmd_en,
    output wire [2:0] ram2_p4_cmd_instr,
    output wire [5:0] ram2_p4_cmd_bl,
    output wire [31:0] ram2_p4_cmd_byte_addr,
    input  wire ram2_p4_cmd_empty,
    input  wire ram2_p4_cmd_full,
    output wire ram2_p4_rd_clk,
    output wire ram2_p4_rd_en,
    input  wire [31:0] ram2_p4_rd_data,
    input  wire ram2_p4_rd_empty,
    input  wire ram2_p4_rd_full,
    input  wire ram2_p4_rd_overflow,
    input  wire [6:0] ram2_p4_rd_count,
    input  wire ram2_p4_rd_error,

    output wire ram2_p5_cmd_clk,
    output wire ram2_p5_cmd_en,
    output wire [2:0] ram2_p5_cmd_instr,
    output wire [5:0] ram2_p5_cmd_bl,
    output wire [31:0] ram2_p5_cmd_byte_addr,
    input  wire ram2_p5_cmd_empty,
    input  wire ram2_p5_cmd_full,
    output wire ram2_p5_rd_clk,
    output wire ram2_p5_rd_en,
    input  wire [31:0] ram2_p5_rd_data,
    input  wire ram2_p5_rd_empty,
    input  wire ram2_p5_rd_full,
    input  wire ram2_p5_rd_overflow,
    input  wire [6:0] ram2_p5_rd_count,
    input  wire ram2_p5_rd_error
);

reg [15:0] count = 0;

assign ferc_dat = 0;
assign ferc_lat = 0;
assign ferc_clk = 0;

assign mux_s = 0;

assign adc_sclk = 0;
assign adc_sdi = 0;
assign adc_cs = 0;
assign adc_convst = 0;

assign dac_clk = clk_250mhz;

reg [15:0] dac_p1_d_reg = 0;
reg [15:0] dac_p2_d_reg = 0;

always @(posedge clk_250mhz) begin
    dac_p1_d_reg <= count;
    dac_p2_d_reg <= -count;
end

assign dac_p1_d = dac_p1_d_reg;
assign dac_p2_d = dac_p2_d_reg;

assign dac_sdio = 0;
assign dac_sclk = 0;
assign dac_csb = 0;
assign dac_reset = 0;

assign sync_dac = count[15:8];
assign dout = count;

always @(posedge clk_250mhz) begin
    count <= count + 1;
end

/////////////////////////////////////////////////
//                                             //
// DDR2 RX path SRL FIFOs                      //
//                                             //
/////////////////////////////////////////////////

// These help timing closure with the MCB read data path since Tmcbcko_RDDATA
// is a very high 2.7 ns.  A LUT in SRL mode has a very low Tds of 90 ps,
// compared to a LUT in RAM mode (Tds 730 ps) or a FF (Tdick 470 ps).

wire ram1_p0_rd_en_fifo;
wire [31:0] ram1_p0_rd_data_fifo;
wire ram1_p0_rd_empty_fifo;
wire ram1_p0_rd_full_fifo;

srl_fifo_reg #(
    .WIDTH(32)
)
ram1_p0_rd_fifo (
    .clk(ram1_p0_rd_clk),
    .rst(rst_250mhz_int),
    .write_en(~ram1_p0_rd_empty),
    .write_data(ram1_p0_rd_data),
    .read_en(ram1_p0_rd_en_fifo),
    .read_data(ram1_p0_rd_data_fifo),
    .full(ram1_p0_rd_full_fifo),
    .empty(ram1_p0_rd_empty_fifo)
);

assign ram1_p0_rd_en = ~ram1_p0_rd_full;

wire ram1_p1_rd_en_fifo;
wire [31:0] ram1_p1_rd_data_fifo;
wire ram1_p1_rd_empty_fifo;
wire ram1_p1_rd_full_fifo;

srl_fifo_reg #(
    .WIDTH(32)
)
ram1_p1_rd_fifo (
    .clk(ram1_p1_rd_clk),
    .rst(rst_250mhz_int),
    .write_en(~ram1_p1_rd_empty),
    .write_data(ram1_p1_rd_data),
    .read_en(ram1_p1_rd_en_fifo),
    .read_data(ram1_p1_rd_data_fifo),
    .full(ram1_p1_rd_full_fifo),
    .empty(ram1_p1_rd_empty_fifo)
);

assign ram1_p1_rd_en = ~ram1_p1_rd_full;

wire ram1_p2_rd_en_fifo;
wire [31:0] ram1_p2_rd_data_fifo;
wire ram1_p2_rd_empty_fifo;
wire ram1_p2_rd_full_fifo;

srl_fifo_reg #(
    .WIDTH(32)
)
ram1_p2_rd_fifo (
    .clk(ram1_p2_rd_clk),
    .rst(rst_250mhz_int),
    .write_en(~ram1_p2_rd_empty),
    .write_data(ram1_p2_rd_data),
    .read_en(ram1_p2_rd_en_fifo),
    .read_data(ram1_p2_rd_data_fifo),
    .full(ram1_p2_rd_full_fifo),
    .empty(ram1_p2_rd_empty_fifo)
);

assign ram1_p2_rd_en = ~ram1_p2_rd_full;

wire ram1_p3_rd_en_fifo;
wire [31:0] ram1_p3_rd_data_fifo;
wire ram1_p3_rd_empty_fifo;
wire ram1_p3_rd_full_fifo;

srl_fifo_reg #(
    .WIDTH(32)
)
ram1_p3_rd_fifo (
    .clk(ram1_p3_rd_clk),
    .rst(rst_250mhz_int),
    .write_en(~ram1_p3_rd_empty),
    .write_data(ram1_p3_rd_data),
    .read_en(ram1_p3_rd_en_fifo),
    .read_data(ram1_p3_rd_data_fifo),
    .full(ram1_p3_rd_full_fifo),
    .empty(ram1_p3_rd_empty_fifo)
);

assign ram1_p3_rd_en = ~ram1_p3_rd_full;

wire ram1_p4_rd_en_fifo;
wire [31:0] ram1_p4_rd_data_fifo;
wire ram1_p4_rd_empty_fifo;
wire ram1_p4_rd_full_fifo;

srl_fifo_reg #(
    .WIDTH(32)
)
ram1_p4_rd_fifo (
    .clk(ram1_p4_rd_clk),
    .rst(rst_250mhz_int),
    .write_en(~ram1_p4_rd_empty),
    .write_data(ram1_p4_rd_data),
    .read_en(ram1_p4_rd_en_fifo),
    .read_data(ram1_p4_rd_data_fifo),
    .full(ram1_p4_rd_full_fifo),
    .empty(ram1_p4_rd_empty_fifo)
);

assign ram1_p4_rd_en = ~ram1_p4_rd_full;

wire ram1_p5_rd_en_fifo;
wire [31:0] ram1_p5_rd_data_fifo;
wire ram1_p5_rd_empty_fifo;
wire ram1_p5_rd_full_fifo;

srl_fifo_reg #(
    .WIDTH(32)
)
ram1_p5_rd_fifo (
    .clk(ram1_p5_rd_clk),
    .rst(rst_250mhz_int),
    .write_en(~ram1_p5_rd_empty),
    .write_data(ram1_p5_rd_data),
    .read_en(ram1_p5_rd_en_fifo),
    .read_data(ram1_p5_rd_data_fifo),
    .full(ram1_p5_rd_full_fifo),
    .empty(ram1_p5_rd_empty_fifo)
);

assign ram1_p5_rd_en = ~ram1_p5_rd_full;

wire ram2_p0_rd_en_fifo;
wire [31:0] ram2_p0_rd_data_fifo;
wire ram2_p0_rd_empty_fifo;
wire ram2_p0_rd_full_fifo;

srl_fifo_reg #(
    .WIDTH(32)
)
ram2_p0_rd_fifo (
    .clk(ram2_p0_rd_clk),
    .rst(rst_250mhz_int),
    .write_en(~ram2_p0_rd_empty),
    .write_data(ram2_p0_rd_data),
    .read_en(ram2_p0_rd_en_fifo),
    .read_data(ram2_p0_rd_data_fifo),
    .full(ram2_p0_rd_full_fifo),
    .empty(ram2_p0_rd_empty_fifo)
);

assign ram2_p0_rd_en = ~ram2_p0_rd_full;

wire ram2_p1_rd_en_fifo;
wire [31:0] ram2_p1_rd_data_fifo;
wire ram2_p1_rd_empty_fifo;
wire ram2_p1_rd_full_fifo;

srl_fifo_reg #(
    .WIDTH(32)
)
ram2_p1_rd_fifo (
    .clk(ram2_p1_rd_clk),
    .rst(rst_250mhz_int),
    .write_en(~ram2_p1_rd_empty),
    .write_data(ram2_p1_rd_data),
    .read_en(ram2_p1_rd_en_fifo),
    .read_data(ram2_p1_rd_data_fifo),
    .full(ram2_p1_rd_full_fifo),
    .empty(ram2_p1_rd_empty_fifo)
);

assign ram2_p1_rd_en = ~ram2_p1_rd_full;

wire ram2_p2_rd_en_fifo;
wire [31:0] ram2_p2_rd_data_fifo;
wire ram2_p2_rd_empty_fifo;
wire ram2_p2_rd_full_fifo;

srl_fifo_reg #(
    .WIDTH(32)
)
ram2_p2_rd_fifo (
    .clk(ram2_p2_rd_clk),
    .rst(rst_250mhz_int),
    .write_en(~ram2_p2_rd_empty),
    .write_data(ram2_p2_rd_data),
    .read_en(ram2_p2_rd_en_fifo),
    .read_data(ram2_p2_rd_data_fifo),
    .full(ram2_p2_rd_full_fifo),
    .empty(ram2_p2_rd_empty_fifo)
);

assign ram2_p2_rd_en = ~ram2_p2_rd_full;

wire ram2_p3_rd_en_fifo;
wire [31:0] ram2_p3_rd_data_fifo;
wire ram2_p3_rd_empty_fifo;
wire ram2_p3_rd_full_fifo;

srl_fifo_reg #(
    .WIDTH(32)
)
ram2_p3_rd_fifo (
    .clk(ram2_p3_rd_clk),
    .rst(rst_250mhz_int),
    .write_en(~ram2_p3_rd_empty),
    .write_data(ram2_p3_rd_data),
    .read_en(ram2_p3_rd_en_fifo),
    .read_data(ram2_p3_rd_data_fifo),
    .full(ram2_p3_rd_full_fifo),
    .empty(ram2_p3_rd_empty_fifo)
);

assign ram2_p3_rd_en = ~ram2_p3_rd_full;

wire ram2_p4_rd_en_fifo;
wire [31:0] ram2_p4_rd_data_fifo;
wire ram2_p4_rd_empty_fifo;
wire ram2_p4_rd_full_fifo;

srl_fifo_reg #(
    .WIDTH(32)
)
ram2_p4_rd_fifo (
    .clk(ram2_p4_rd_clk),
    .rst(rst_250mhz_int),
    .write_en(~ram2_p4_rd_empty),
    .write_data(ram2_p4_rd_data),
    .read_en(ram2_p4_rd_en_fifo),
    .read_data(ram2_p4_rd_data_fifo),
    .full(ram2_p4_rd_full_fifo),
    .empty(ram2_p4_rd_empty_fifo)
);

assign ram2_p4_rd_en = ~ram2_p4_rd_full;

wire ram2_p5_rd_en_fifo;
wire [31:0] ram2_p5_rd_data_fifo;
wire ram2_p5_rd_empty_fifo;
wire ram2_p5_rd_full_fifo;

srl_fifo_reg #(
    .WIDTH(32)
)
ram2_p5_rd_fifo (
    .clk(ram2_p5_rd_clk),
    .rst(rst_250mhz_int),
    .write_en(~ram2_p5_rd_empty),
    .write_data(ram2_p5_rd_data),
    .read_en(ram2_p5_rd_en_fifo),
    .read_data(ram2_p5_rd_data_fifo),
    .full(ram2_p5_rd_full_fifo),
    .empty(ram2_p5_rd_empty_fifo)
);

assign ram2_p5_rd_en = ~ram2_p5_rd_full;

/////////////////////////////////////////////////
//                                             //
// SoC Interface                               //
//                                             //
/////////////////////////////////////////////////

wire [7:0] cntrl_rx_tdata;
wire cntrl_rx_tvalid;
wire cntrl_rx_tready;
wire cntrl_rx_tlast;

wire [7:0] cntrl_tx_tdata;
wire cntrl_tx_tvalid;
wire cntrl_tx_tready;
wire cntrl_tx_tlast;

wire [35:0] wbm_adr_o;
wire [31:0] wbm_dat_i;
wire [31:0] wbm_dat_o;
wire wbm_we_o;
wire [3:0] wbm_sel_o;
wire wbm_stb_o;
wire wbm_ack_i;
wire wbm_err_i;
wire wbm_cyc_o;

wire [31:0] ram1_wb_adr_i;
wire [31:0] ram1_wb_dat_i;
wire [31:0] ram1_wb_dat_o;
wire ram1_wb_we_i;
wire [3:0] ram1_wb_sel_i;
wire ram1_wb_stb_i;
wire ram1_wb_ack_o;
wire ram1_wb_err_o;
wire ram1_wb_cyc_i;

wire [31:0] ram2_wb_adr_i;
wire [31:0] ram2_wb_dat_i;
wire [31:0] ram2_wb_dat_o;
wire ram2_wb_we_i;
wire [3:0] ram2_wb_sel_i;
wire ram2_wb_stb_i;
wire ram2_wb_ack_o;
wire ram2_wb_err_o;
wire ram2_wb_cyc_i;

wire [31:0] ctrl_wb_adr_i;
wire [31:0] ctrl_wb_dat_i;
wire [31:0] ctrl_wb_dat_o;
wire ctrl_wb_we_i;
wire [3:0] ctrl_wb_sel_i;
wire ctrl_wb_stb_i;
wire ctrl_wb_ack_o;
wire ctrl_wb_err_o;
wire ctrl_wb_cyc_i;

wire [31:0] ctrl_int_wb_adr_i;
wire [31:0] ctrl_int_wb_dat_i;
wire [31:0] ctrl_int_wb_dat_o;
wire ctrl_int_wb_we_i;
wire [3:0] ctrl_int_wb_sel_i;
wire ctrl_int_wb_stb_i;
wire ctrl_int_wb_ack_o;
wire ctrl_int_wb_err_o;
wire ctrl_int_wb_cyc_i;

axis_spi_slave #(
    .DATA_WIDTH(8)
)
spi_slave_inst (
    .clk(clk_250mhz_int),
    .rst(rst_250mhz_int),
    // axi input
    .input_axis_tdata(cntrl_tx_tdata),
    .input_axis_tvalid(cntrl_tx_tvalid),
    .input_axis_tready(cntrl_tx_tready),
    .input_axis_tlast(cntrl_tx_tlast),
    // axi output
    .output_axis_tdata(cntrl_rx_tdata),
    .output_axis_tvalid(cntrl_rx_tvalid),
    .output_axis_tready(cntrl_rx_tready),
    .output_axis_tlast(cntrl_rx_tlast),
    // spi interface
    .cs(cntrl_cs),
    .sck(cntrl_sck),
    .mosi(cntrl_mosi),
    .miso(cntrl_miso),
    // status
    .busy()
);

soc_interface_wb_32
soc_interface_wb_inst (
    .clk(clk_250mhz_int),
    .rst(rst_250mhz_int),
    // axi input
    .input_axis_tdata(cntrl_rx_tdata),
    .input_axis_tvalid(cntrl_rx_tvalid),
    .input_axis_tready(cntrl_rx_tready),
    .input_axis_tlast(cntrl_rx_tlast),
    // axi output
    .output_axis_tdata(cntrl_tx_tdata),
    .output_axis_tvalid(cntrl_tx_tvalid),
    .output_axis_tready(cntrl_tx_tready),
    .output_axis_tlast(cntrl_tx_tlast),
    // wb interface
    .wb_adr_o(wbm_adr_o),
    .wb_dat_i(wbm_dat_i),
    .wb_dat_o(wbm_dat_o),
    .wb_we_o(wbm_we_o),
    .wb_sel_o(wbm_sel_o),
    .wb_stb_o(wbm_stb_o),
    .wb_ack_i(wbm_ack_i),
    .wb_err_i(wbm_err_i),
    .wb_cyc_o(wbm_cyc_o),
    // status
    .busy()
);

wb_mux_3 #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(36),
    .SELECT_WIDTH(4)
)
wb_mux_inst (
    .clk(clk_250mhz_int),
    .rst(rst_250mhz_int),
    // from SoC interface
    .wbm_adr_i(wbm_adr_o),
    .wbm_dat_i(wbm_dat_o),
    .wbm_dat_o(wbm_dat_i),
    .wbm_we_i(wbm_we_o),
    .wbm_sel_i(wbm_sel_o),
    .wbm_stb_i(wbm_stb_o),
    .wbm_ack_o(wbm_ack_i),
    .wbm_err_o(wbm_err_i),
    .wbm_rty_o(),
    .wbm_cyc_i(wbm_cyc_o),
    // MCB 1
    .wbs0_adr_o(ram1_wb_adr_i),
    .wbs0_dat_i(ram1_wb_dat_o),
    .wbs0_dat_o(ram1_wb_dat_i),
    .wbs0_we_o(ram1_wb_we_i),
    .wbs0_sel_o(ram1_wb_sel_i),
    .wbs0_stb_o(ram1_wb_stb_i),
    .wbs0_ack_i(ram1_wb_ack_o),
    .wbs0_err_i(ram1_wb_err_o),
    .wbs0_rty_i(0),
    .wbs0_cyc_o(ram1_wb_cyc_i),
    .wbs0_addr(36'h000000000),
    .wbs0_addr_msk(36'hF00000000),
    // MCB 2
    .wbs1_adr_o(ram2_wb_adr_i),
    .wbs1_dat_i(ram2_wb_dat_o),
    .wbs1_dat_o(ram2_wb_dat_i),
    .wbs1_we_o(ram2_wb_we_i),
    .wbs1_sel_o(ram2_wb_sel_i),
    .wbs1_stb_o(ram2_wb_stb_i),
    .wbs1_ack_i(ram2_wb_ack_o),
    .wbs1_err_i(ram2_wb_err_o),
    .wbs1_rty_i(0),
    .wbs1_cyc_o(ram2_wb_cyc_i),
    .wbs1_addr(36'h100000000),
    .wbs1_addr_msk(36'hF00000000),
    // Control
    .wbs2_adr_o(ctrl_wb_adr_i),
    .wbs2_dat_i(ctrl_wb_dat_o),
    .wbs2_dat_o(ctrl_wb_dat_i),
    .wbs2_we_o(ctrl_wb_we_i),
    .wbs2_sel_o(ctrl_wb_sel_i),
    .wbs2_stb_o(ctrl_wb_stb_i),
    .wbs2_ack_i(ctrl_wb_ack_o),
    .wbs2_err_i(ctrl_wb_err_o),
    .wbs2_rty_i(0),
    .wbs2_cyc_o(ctrl_wb_cyc_i),
    .wbs2_addr(36'hF00000000),
    .wbs2_addr_msk(36'hF00000000)
);

assign ram1_wb_err_o = 0;

wb_mcb_32
wb_mcb_ram1_inst (
    .clk(clk_250mhz_int),
    .rst(rst_250mhz_int),
    // wb interface
    .wb_adr_i(ram1_wb_adr_i),
    .wb_dat_i(ram1_wb_dat_i),
    .wb_dat_o(ram1_wb_dat_o),
    .wb_we_i(ram1_wb_we_i),
    .wb_sel_i(ram1_wb_sel_i),
    .wb_stb_i(ram1_wb_stb_i),
    .wb_ack_o(ram1_wb_ack_o),
    .wb_cyc_i(ram1_wb_cyc_i),
    // mcb interface
    .mcb_cmd_clk(ram1_p0_cmd_clk),
    .mcb_cmd_en(ram1_p0_cmd_en),
    .mcb_cmd_instr(ram1_p0_cmd_instr),
    .mcb_cmd_bl(ram1_p0_cmd_bl),
    .mcb_cmd_byte_addr(ram1_p0_cmd_byte_addr),
    .mcb_cmd_empty(ram1_p0_cmd_empty),
    .mcb_cmd_full(ram1_p0_cmd_full),
    .mcb_wr_clk(ram1_p0_wr_clk),
    .mcb_wr_en(ram1_p0_wr_en),
    .mcb_wr_mask(ram1_p0_wr_mask),
    .mcb_wr_data(ram1_p0_wr_data),
    .mcb_wr_empty(ram1_p0_wr_empty),
    .mcb_wr_full(ram1_p0_wr_full),
    .mcb_wr_underrun(ram1_p0_wr_underrun),
    .mcb_wr_count(ram1_p0_wr_count),
    .mcb_wr_error(ram1_p0_wr_error),
    .mcb_rd_clk(ram1_p0_rd_clk),
    .mcb_rd_en(ram1_p0_rd_en_fifo),
    .mcb_rd_data(ram1_p0_rd_data_fifo),
    .mcb_rd_empty(ram1_p0_rd_empty_fifo),
    .mcb_rd_full(ram1_p0_rd_full_fifo),
    .mcb_rd_overflow(ram1_p0_rd_overflow),
    .mcb_rd_count(ram1_p0_rd_count),
    .mcb_rd_error(ram1_p0_rd_error)
);

assign ram2_wb_err_o = 0;

wb_mcb_32
wb_mcb_ram2_inst (
    .clk(clk_250mhz_int),
    .rst(rst_250mhz_int),
    // wb interface
    .wb_adr_i(ram2_wb_adr_i),
    .wb_dat_i(ram2_wb_dat_i),
    .wb_dat_o(ram2_wb_dat_o),
    .wb_we_i(ram2_wb_we_i),
    .wb_sel_i(ram2_wb_sel_i),
    .wb_stb_i(ram2_wb_stb_i),
    .wb_ack_o(ram2_wb_ack_o),
    .wb_cyc_i(ram2_wb_cyc_i),
    // mcb interface
    .mcb_cmd_clk(ram2_p0_cmd_clk),
    .mcb_cmd_en(ram2_p0_cmd_en),
    .mcb_cmd_instr(ram2_p0_cmd_instr),
    .mcb_cmd_bl(ram2_p0_cmd_bl),
    .mcb_cmd_byte_addr(ram2_p0_cmd_byte_addr),
    .mcb_cmd_empty(ram2_p0_cmd_empty),
    .mcb_cmd_full(ram2_p0_cmd_full),
    .mcb_wr_clk(ram2_p0_wr_clk),
    .mcb_wr_en(ram2_p0_wr_en),
    .mcb_wr_mask(ram2_p0_wr_mask),
    .mcb_wr_data(ram2_p0_wr_data),
    .mcb_wr_empty(ram2_p0_wr_empty),
    .mcb_wr_full(ram2_p0_wr_full),
    .mcb_wr_underrun(ram2_p0_wr_underrun),
    .mcb_wr_count(ram2_p0_wr_count),
    .mcb_wr_error(ram2_p0_wr_error),
    .mcb_rd_clk(ram2_p0_rd_clk),
    .mcb_rd_en(ram2_p0_rd_en_fifo),
    .mcb_rd_data(ram2_p0_rd_data_fifo),
    .mcb_rd_empty(ram2_p0_rd_empty_fifo),
    .mcb_rd_full(ram2_p0_rd_full_fifo),
    .mcb_rd_overflow(ram2_p0_rd_overflow),
    .mcb_rd_count(ram2_p0_rd_count),
    .mcb_rd_error(ram2_p0_rd_error)
);

wb_async_reg #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(32),
    .SELECT_WIDTH(4)
)
wb_async_reg_inst (
    .wbm_clk(clk_250mhz_int),
    .wbm_rst(rst_250mhz_int),
    .wbm_adr_i(ctrl_wb_adr_i),
    .wbm_dat_i(ctrl_wb_dat_i),
    .wbm_dat_o(ctrl_wb_dat_o),
    .wbm_we_i(ctrl_wb_we_i),
    .wbm_sel_i(ctrl_wb_sel_i),
    .wbm_stb_i(ctrl_wb_stb_i),
    .wbm_ack_o(ctrl_wb_ack_o),
    .wbm_err_o(ctrl_wb_err_o),
    .wbm_rty_o(),
    .wbm_cyc_i(ctrl_wb_cyc_i),
    .wbs_clk(clk_250mhz),
    .wbs_rst(rst_250mhz),
    .wbs_adr_o(ctrl_int_wb_adr_i),
    .wbs_dat_i(ctrl_int_wb_dat_o),
    .wbs_dat_o(ctrl_int_wb_dat_i),
    .wbs_we_o(ctrl_int_wb_we_i),
    .wbs_sel_o(ctrl_int_wb_sel_i),
    .wbs_stb_o(ctrl_int_wb_stb_i),
    .wbs_ack_i(ctrl_int_wb_ack_o),
    .wbs_err_i(ctrl_int_wb_err_o),
    .wbs_rty_i(0),
    .wbs_cyc_o(ctrl_int_wb_cyc_i)
);

assign ctrl_int_wb_err_o = 0;

wb_ram #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(8),
    .SELECT_WIDTH(4)
)
wb_ram_inst(
    .clk(clk_250mhz),
    .adr_i(ctrl_int_wb_adr_i),
    .dat_i(ctrl_int_wb_dat_i),
    .dat_o(ctrl_int_wb_dat_o),
    .we_i(ctrl_int_wb_we_i),
    .sel_i(ctrl_int_wb_sel_i),
    .stb_i(ctrl_int_wb_stb_i),
    .ack_o(ctrl_int_wb_ack_o),
    .cyc_i(ctrl_int_wb_cyc_i)
);

// currenly unused signals
assign ram1_p1_cmd_clk = 0;
assign ram1_p1_cmd_en = 0;
assign ram1_p1_cmd_instr = 0;
assign ram1_p1_cmd_bl = 0;
assign ram1_p1_cmd_byte_addr = 0;
assign ram1_p1_wr_clk = 0;
assign ram1_p1_wr_en = 0;
assign ram1_p1_wr_mask = 0;
assign ram1_p1_wr_data = 0;
assign ram1_p1_rd_clk = 0;
assign ram1_p1_rd_en_fifo = 0;

assign ram1_p2_cmd_clk = 0;
assign ram1_p2_cmd_en = 0;
assign ram1_p2_cmd_instr = 0;
assign ram1_p2_cmd_bl = 0;
assign ram1_p2_cmd_byte_addr = 0;
assign ram1_p2_rd_clk = 0;
assign ram1_p2_rd_en_fifo = 0;

assign ram1_p3_cmd_clk = 0;
assign ram1_p3_cmd_en = 0;
assign ram1_p3_cmd_instr = 0;
assign ram1_p3_cmd_bl = 0;
assign ram1_p3_cmd_byte_addr = 0;
assign ram1_p3_rd_clk = 0;
assign ram1_p3_rd_en_fifo = 0;

assign ram1_p4_cmd_clk = 0;
assign ram1_p4_cmd_en = 0;
assign ram1_p4_cmd_instr = 0;
assign ram1_p4_cmd_bl = 0;
assign ram1_p4_cmd_byte_addr = 0;
assign ram1_p4_rd_clk = 0;
assign ram1_p4_rd_en_fifo = 0;

assign ram1_p5_cmd_clk = 0;
assign ram1_p5_cmd_en = 0;
assign ram1_p5_cmd_instr = 0;
assign ram1_p5_cmd_bl = 0;
assign ram1_p5_cmd_byte_addr = 0;
assign ram1_p5_rd_clk = 0;
assign ram1_p5_rd_en_fifo = 0;

assign ram2_p1_cmd_clk = 0;
assign ram2_p1_cmd_en = 0;
assign ram2_p1_cmd_instr = 0;
assign ram2_p1_cmd_bl = 0;
assign ram2_p1_cmd_byte_addr = 0;
assign ram2_p1_wr_clk = 0;
assign ram2_p1_wr_en = 0;
assign ram2_p1_wr_mask = 0;
assign ram2_p1_wr_data = 0;
assign ram2_p1_rd_clk = 0;
assign ram2_p1_rd_en_fifo = 0;

assign ram2_p2_cmd_clk = 0;
assign ram2_p2_cmd_en = 0;
assign ram2_p2_cmd_instr = 0;
assign ram2_p2_cmd_bl = 0;
assign ram2_p2_cmd_byte_addr = 0;
assign ram2_p2_rd_clk = 0;
assign ram2_p2_rd_en_fifo = 0;

assign ram2_p3_cmd_clk = 0;
assign ram2_p3_cmd_en = 0;
assign ram2_p3_cmd_instr = 0;
assign ram2_p3_cmd_bl = 0;
assign ram2_p3_cmd_byte_addr = 0;
assign ram2_p3_rd_clk = 0;
assign ram2_p3_rd_en_fifo = 0;

assign ram2_p4_cmd_clk = 0;
assign ram2_p4_cmd_en = 0;
assign ram2_p4_cmd_instr = 0;
assign ram2_p4_cmd_bl = 0;
assign ram2_p4_cmd_byte_addr = 0;
assign ram2_p4_rd_clk = 0;
assign ram2_p4_rd_en_fifo = 0;

assign ram2_p5_cmd_clk = 0;
assign ram2_p5_cmd_en = 0;
assign ram2_p5_cmd_instr = 0;
assign ram2_p5_cmd_bl = 0;
assign ram2_p5_cmd_byte_addr = 0;
assign ram2_p5_rd_clk = 0;
assign ram2_p5_rd_en_fifo = 0;

endmodule
