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

soc_interface
soc_interface_inst (
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
    // mcb interface port 0
    .port0_cmd_clk(ram1_p0_cmd_clk),
    .port0_cmd_en(ram1_p0_cmd_en),
    .port0_cmd_instr(ram1_p0_cmd_instr),
    .port0_cmd_bl(ram1_p0_cmd_bl),
    .port0_cmd_byte_addr(ram1_p0_cmd_byte_addr),
    .port0_cmd_empty(ram1_p0_cmd_empty),
    .port0_cmd_full(ram1_p0_cmd_full),
    .port0_wr_clk(ram1_p0_wr_clk),
    .port0_wr_en(ram1_p0_wr_en),
    .port0_wr_mask(ram1_p0_wr_mask),
    .port0_wr_data(ram1_p0_wr_data),
    .port0_wr_empty(ram1_p0_wr_empty),
    .port0_wr_full(ram1_p0_wr_full),
    .port0_wr_underrun(ram1_p0_wr_underrun),
    .port0_wr_count(ram1_p0_wr_count),
    .port0_wr_error(ram1_p0_wr_error),
    .port0_rd_clk(ram1_p0_rd_clk),
    .port0_rd_en(ram1_p0_rd_en_fifo),
    .port0_rd_data(ram1_p0_rd_data_fifo),
    .port0_rd_empty(ram1_p0_rd_empty_fifo),
    .port0_rd_full(ram1_p0_rd_full_fifo),
    .port0_rd_overflow(ram1_p0_rd_overflow),
    .port0_rd_count(ram1_p0_rd_count),
    .port0_rd_error(ram1_p0_rd_error),
    // mcb interface port 1
    .port1_cmd_clk(ram2_p0_cmd_clk),
    .port1_cmd_en(ram2_p0_cmd_en),
    .port1_cmd_instr(ram2_p0_cmd_instr),
    .port1_cmd_bl(ram2_p0_cmd_bl),
    .port1_cmd_byte_addr(ram2_p0_cmd_byte_addr),
    .port1_cmd_empty(ram2_p0_cmd_empty),
    .port1_cmd_full(ram2_p0_cmd_full),
    .port1_wr_clk(ram2_p0_wr_clk),
    .port1_wr_en(ram2_p0_wr_en),
    .port1_wr_mask(ram2_p0_wr_mask),
    .port1_wr_data(ram2_p0_wr_data),
    .port1_wr_empty(ram2_p0_wr_empty),
    .port1_wr_full(ram2_p0_wr_full),
    .port1_wr_underrun(ram2_p0_wr_underrun),
    .port1_wr_count(ram2_p0_wr_count),
    .port1_wr_error(ram2_p0_wr_error),
    .port1_rd_clk(ram2_p0_rd_clk),
    .port1_rd_en(ram2_p0_rd_en_fifo),
    .port1_rd_data(ram2_p0_rd_data_fifo),
    .port1_rd_empty(ram2_p0_rd_empty_fifo),
    .port1_rd_full(ram2_p0_rd_full_fifo),
    .port1_rd_overflow(ram2_p0_rd_overflow),
    .port1_rd_count(ram2_p0_rd_count),
    .port1_rd_error(ram2_p0_rd_error),
    // status
    .busy()
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
