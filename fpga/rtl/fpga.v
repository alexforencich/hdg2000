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
module fpga
(
    // clocks
    input  wire  clk_10mhz_int,
    input  wire  clk_10mhz_ext,
    output wire  clk_10mhz_out,

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
    output wire dac_clk_p,
    output wire dac_clk_n,
    output wire [15:0] dac_p1_d,
    output wire [15:0] dac_p2_d,
    input  wire dac_sdo,
    output wire dac_sdio,
    output wire dac_sclk,
    output wire dac_csb,
    output wire dac_reset,

    // ram 1 (U8)
    output wire ram1_cke,
    output wire ram1_ck_p,
    output wire ram1_ck_n,
    output wire ram1_cs_n,
    output wire ram1_ras_n,
    output wire ram1_cas_n,
    output wire ram1_we_n,
    output wire [12:0] ram1_a,
    output wire [2:0]  ram1_ba,
    inout  wire [15:0] ram1_dq,
    inout  wire ram1_ldqs_p,
    inout  wire ram1_ldqs_n,
    output wire ram1_ldm,
    inout  wire ram1_udqs_p,
    inout  wire ram1_udqs_n,
    output wire ram1_udm,
    output wire ram1_odt,
    inout  wire ram1_rzq,
    inout  wire ram1_zio,

    // ram 2 (U12)
    output wire ram2_cke,
    output wire ram2_ck_p,
    output wire ram2_ck_n,
    output wire ram2_cs_n,
    output wire ram2_ras_n,
    output wire ram2_cas_n,
    output wire ram2_we_n,
    output wire [12:0] ram2_a,
    output wire [2:0]  ram2_ba,
    inout  wire [15:0] ram2_dq,
    inout  wire ram2_ldqs_p,
    inout  wire ram2_ldqs_n,
    output wire ram2_ldm,
    inout  wire ram2_udqs_p,
    inout  wire ram2_udqs_n,
    output wire ram2_udm,
    output wire ram2_odt,
    inout  wire ram2_rzq,
    inout  wire ram2_zio
);

wire clk_250mhz_int;
wire rst_250mhz_int;

wire clk_250mhz;
wire rst_250mhz;

wire clk_10mhz;
wire rst_10mhz;

wire ext_clock_selected;

clock
clock_inst
(
    .reset_in(0),

    .clk_10mhz_int(clk_10mhz_int),
    .clk_10mhz_ext(clk_10mhz_ext),

    .clk_250mhz_int(clk_250mhz_int),
    .rst_250mhz_int(rst_250mhz_int),

    .clk_250mhz(clk_250mhz),
    .rst_250mhz(rst_250mhz),

    .clk_10mhz(clk_10mhz),
    .rst_10mhz(rst_10mhz),

    .ext_clock_selected(ext_clock_selected)
);

ODDR2
clk_10mhz_out_oddr2_inst
(
    .Q(clk_10mhz_out),
    .C0(clk_10mhz),
    .C1(~clk_10mhz),
    .CE(1),
    .D0(0),
    .D1(1),
    .R(0),
    .S(0)
);

wire dac_clk_int;
wire [15:0] dac_p1_d_int;
wire [15:0] dac_p2_d_int;

wire dac_clk;

ODDR2
dac_clk_oddr2_inst
(
    .Q(dac_clk),
    .C0(dac_clk_int),
    .C1(~dac_clk_int),
    .CE(1),
    .D0(0),
    .D1(1),
    .R(0),
    .S(0)
);

OBUFDS
dac_clk_obufds_inst
(
    .I(dac_clk),
    .O(dac_clk_p),
    .OB(dac_clk_n)
);

(* IOB = "TRUE" *)
reg [15:0] dac_p1_d_oreg;
(* IOB = "TRUE" *)
reg [15:0] dac_p2_d_oreg;

always @(posedge dac_clk_int) begin
    dac_p1_d_oreg <= dac_p1_d_int;
    dac_p2_d_oreg <= dac_p2_d_int;
end

assign dac_p1_d = dac_p1_d_oreg;
assign dac_p2_d = dac_p2_d_oreg;

assign dac_sdo_int = dac_sdo;
assign dac_sdio = dac_sdio_int;
assign dac_sclk = dac_sclk_int;
assign dac_csb = dac_csb_int;
assign dac_reset = dac_reset_int;

/////////////////////////////////////////////////
//                                             //
// DDR2 Interface                              //
//                                             //
/////////////////////////////////////////////////

wire mcb_clk_0;
wire mcb_clk_180;
wire mcb_drp_clk;
wire mcb_clk_locked;

wire ram1_p0_cmd_clk;
wire ram1_p0_cmd_en;
wire [2:0] ram1_p0_cmd_instr;
wire [5:0] ram1_p0_cmd_bl;
wire [31:0] ram1_p0_cmd_byte_addr;
wire ram1_p0_cmd_empty;
wire ram1_p0_cmd_full;
wire ram1_p0_wr_clk;
wire ram1_p0_wr_en;
wire [3:0] ram1_p0_wr_mask;
wire [31:0] ram1_p0_wr_data;
wire ram1_p0_wr_empty;
wire ram1_p0_wr_full;
wire ram1_p0_wr_underrun;
wire [6:0] ram1_p0_wr_count;
wire ram1_p0_wr_error;
wire ram1_p0_rd_clk;
wire ram1_p0_rd_en;
wire [31:0] ram1_p0_rd_data;
wire ram1_p0_rd_empty;
wire ram1_p0_rd_full;
wire ram1_p0_rd_overflow;
wire [6:0] ram1_p0_rd_count;
wire ram1_p0_rd_error;

wire ram1_p1_cmd_clk;
wire ram1_p1_cmd_en;
wire [2:0] ram1_p1_cmd_instr;
wire [5:0] ram1_p1_cmd_bl;
wire [31:0] ram1_p1_cmd_byte_addr;
wire ram1_p1_cmd_empty;
wire ram1_p1_cmd_full;
wire ram1_p1_wr_clk;
wire ram1_p1_wr_en;
wire [3:0] ram1_p1_wr_mask;
wire [31:0] ram1_p1_wr_data;
wire ram1_p1_wr_empty;
wire ram1_p1_wr_full;
wire ram1_p1_wr_underrun;
wire [6:0] ram1_p1_wr_count;
wire ram1_p1_wr_error;
wire ram1_p1_rd_clk;
wire ram1_p1_rd_en;
wire [31:0] ram1_p1_rd_data;
wire ram1_p1_rd_empty;
wire ram1_p1_rd_full;
wire ram1_p1_rd_overflow;
wire [6:0] ram1_p1_rd_count;
wire ram1_p1_rd_error;

wire ram1_p2_cmd_clk;
wire ram1_p2_cmd_en;
wire [2:0] ram1_p2_cmd_instr;
wire [5:0] ram1_p2_cmd_bl;
wire [31:0] ram1_p2_cmd_byte_addr;
wire ram1_p2_cmd_empty;
wire ram1_p2_cmd_full;
wire ram1_p2_rd_clk;
wire ram1_p2_rd_en;
wire [31:0] ram1_p2_rd_data;
wire ram1_p2_rd_empty;
wire ram1_p2_rd_full;
wire ram1_p2_rd_overflow;
wire [6:0] ram1_p2_rd_count;
wire ram1_p2_rd_error;

wire ram1_p3_cmd_clk;
wire ram1_p3_cmd_en;
wire [2:0] ram1_p3_cmd_instr;
wire [5:0] ram1_p3_cmd_bl;
wire [31:0] ram1_p3_cmd_byte_addr;
wire ram1_p3_cmd_empty;
wire ram1_p3_cmd_full;
wire ram1_p3_rd_clk;
wire ram1_p3_rd_en;
wire [31:0] ram1_p3_rd_data;
wire ram1_p3_rd_empty;
wire ram1_p3_rd_full;
wire ram1_p3_rd_overflow;
wire [6:0] ram1_p3_rd_count;
wire ram1_p3_rd_error;

wire ram1_p4_cmd_clk;
wire ram1_p4_cmd_en;
wire [2:0] ram1_p4_cmd_instr;
wire [5:0] ram1_p4_cmd_bl;
wire [31:0] ram1_p4_cmd_byte_addr;
wire ram1_p4_cmd_empty;
wire ram1_p4_cmd_full;
wire ram1_p4_rd_clk;
wire ram1_p4_rd_en;
wire [31:0] ram1_p4_rd_data;
wire ram1_p4_rd_empty;
wire ram1_p4_rd_full;
wire ram1_p4_rd_overflow;
wire [6:0] ram1_p4_rd_count;
wire ram1_p4_rd_error;

wire ram1_p5_cmd_clk;
wire ram1_p5_cmd_en;
wire [2:0] ram1_p5_cmd_instr;
wire [5:0] ram1_p5_cmd_bl;
wire [31:0] ram1_p5_cmd_byte_addr;
wire ram1_p5_cmd_empty;
wire ram1_p5_cmd_full;
wire ram1_p5_rd_clk;
wire ram1_p5_rd_en;
wire [31:0] ram1_p5_rd_data;
wire ram1_p5_rd_empty;
wire ram1_p5_rd_full;
wire ram1_p5_rd_overflow;
wire [6:0] ram1_p5_rd_count;
wire ram1_p5_rd_error;

wire ram2_p0_cmd_clk;
wire ram2_p0_cmd_en;
wire [2:0] ram2_p0_cmd_instr;
wire [5:0] ram2_p0_cmd_bl;
wire [31:0] ram2_p0_cmd_byte_addr;
wire ram2_p0_cmd_empty;
wire ram2_p0_cmd_full;
wire ram2_p0_wr_clk;
wire ram2_p0_wr_en;
wire [3:0] ram2_p0_wr_mask;
wire [31:0] ram2_p0_wr_data;
wire ram2_p0_wr_empty;
wire ram2_p0_wr_full;
wire ram2_p0_wr_underrun;
wire [6:0] ram2_p0_wr_count;
wire ram2_p0_wr_error;
wire ram2_p0_rd_clk;
wire ram2_p0_rd_en;
wire [31:0] ram2_p0_rd_data;
wire ram2_p0_rd_empty;
wire ram2_p0_rd_full;
wire ram2_p0_rd_overflow;
wire [6:0] ram2_p0_rd_count;
wire ram2_p0_rd_error;

wire ram2_p1_cmd_clk;
wire ram2_p1_cmd_en;
wire [2:0] ram2_p1_cmd_instr;
wire [5:0] ram2_p1_cmd_bl;
wire [31:0] ram2_p1_cmd_byte_addr;
wire ram2_p1_cmd_empty;
wire ram2_p1_cmd_full;
wire ram2_p1_wr_clk;
wire ram2_p1_wr_en;
wire [3:0] ram2_p1_wr_mask;
wire [31:0] ram2_p1_wr_data;
wire ram2_p1_wr_empty;
wire ram2_p1_wr_full;
wire ram2_p1_wr_underrun;
wire [6:0] ram2_p1_wr_count;
wire ram2_p1_wr_error;
wire ram2_p1_rd_clk;
wire ram2_p1_rd_en;
wire [31:0] ram2_p1_rd_data;
wire ram2_p1_rd_empty;
wire ram2_p1_rd_full;
wire ram2_p1_rd_overflow;
wire [6:0] ram2_p1_rd_count;
wire ram2_p1_rd_error;

wire ram2_p2_cmd_clk;
wire ram2_p2_cmd_en;
wire [2:0] ram2_p2_cmd_instr;
wire [5:0] ram2_p2_cmd_bl;
wire [31:0] ram2_p2_cmd_byte_addr;
wire ram2_p2_cmd_empty;
wire ram2_p2_cmd_full;
wire ram2_p2_rd_clk;
wire ram2_p2_rd_en;
wire [31:0] ram2_p2_rd_data;
wire ram2_p2_rd_empty;
wire ram2_p2_rd_full;
wire ram2_p2_rd_overflow;
wire [6:0] ram2_p2_rd_count;
wire ram2_p2_rd_error;

wire ram2_p3_cmd_clk;
wire ram2_p3_cmd_en;
wire [2:0] ram2_p3_cmd_instr;
wire [5:0] ram2_p3_cmd_bl;
wire [31:0] ram2_p3_cmd_byte_addr;
wire ram2_p3_cmd_empty;
wire ram2_p3_cmd_full;
wire ram2_p3_rd_clk;
wire ram2_p3_rd_en;
wire [31:0] ram2_p3_rd_data;
wire ram2_p3_rd_empty;
wire ram2_p3_rd_full;
wire ram2_p3_rd_overflow;
wire [6:0] ram2_p3_rd_count;
wire ram2_p3_rd_error;

wire ram2_p4_cmd_clk;
wire ram2_p4_cmd_en;
wire [2:0] ram2_p4_cmd_instr;
wire [5:0] ram2_p4_cmd_bl;
wire [31:0] ram2_p4_cmd_byte_addr;
wire ram2_p4_cmd_empty;
wire ram2_p4_cmd_full;
wire ram2_p4_rd_clk;
wire ram2_p4_rd_en;
wire [31:0] ram2_p4_rd_data;
wire ram2_p4_rd_empty;
wire ram2_p4_rd_full;
wire ram2_p4_rd_overflow;
wire [6:0] ram2_p4_rd_count;
wire ram2_p4_rd_error;

wire ram2_p5_cmd_clk;
wire ram2_p5_cmd_en;
wire [2:0] ram2_p5_cmd_instr;
wire [5:0] ram2_p5_cmd_bl;
wire [31:0] ram2_p5_cmd_byte_addr;
wire ram2_p5_cmd_empty;
wire ram2_p5_cmd_full;
wire ram2_p5_rd_clk;
wire ram2_p5_rd_en;
wire [31:0] ram2_p5_rd_data;
wire ram2_p5_rd_empty;
wire ram2_p5_rd_full;
wire ram2_p5_rd_overflow;
wire [6:0] ram2_p5_rd_count;
wire ram2_p5_rd_error;

ddr2_clock
ddr2_clock_inst
(
    .clk_250mhz(clk_250mhz_int),
    .rst_250mhz(rst_250mhz_int),

    .mcb_clk_0(mcb_clk_0),
    .mcb_clk_180(mcb_clk_180),
    .mcb_drp_clk(mcb_drp_clk),
    .mcb_clk_locked(mcb_clk_locked)
);

ddr2
ddr2_ram1_inst
(
    .async_rst(rst_250mhz_int | ~mcb_clk_locked),
    .mcb_clk_0(mcb_clk_0),
    .mcb_clk_180(mcb_clk_180),
    .mcb_drp_clk(mcb_drp_clk),
    .mcb_clk_locked(mcb_clk_locked),

    .calib_done(),

    .mcbx_dram_a(ram1_a),
    .mcbx_dram_ba(ram1_ba),
    .mcbx_dram_ras_n(ram1_ras_n),
    .mcbx_dram_cas_n(ram1_cas_n),
    .mcbx_dram_we_n(ram1_we_n),
    .mcbx_dram_cke(ram1_cke),
    .mcbx_dram_ck(ram1_ck_p),
    .mcbx_dram_ck_n(ram1_ck_n),
    .mcbx_dram_dq(ram1_dq),
    .mcbx_dram_dqs(ram1_ldqs_p),
    .mcbx_dram_dqs_n(ram1_ldqs_n),
    .mcbx_dram_udqs(ram1_udqs_p),
    .mcbx_dram_udqs_n(ram1_udqs_n),
    .mcbx_dram_udm(ram1_udm),
    .mcbx_dram_dm(ram1_ldm),
    .mcbx_dram_odt(ram1_odt),
    .mcbx_rzq(ram1_rzq),
    .mcbx_zio(ram1_zio),

    .p0_cmd_clk(ram1_p0_cmd_clk),
    .p0_cmd_en(ram1_p0_cmd_en),
    .p0_cmd_instr(ram1_p0_cmd_instr),
    .p0_cmd_bl(ram1_p0_cmd_bl),
    .p0_cmd_byte_addr(ram1_p0_cmd_byte_addr),
    .p0_cmd_empty(ram1_p0_cmd_empty),
    .p0_cmd_full(ram1_p0_cmd_full),
    .p0_wr_clk(ram1_p0_wr_clk),
    .p0_wr_en(ram1_p0_wr_en),
    .p0_wr_mask(ram1_p0_wr_mask),
    .p0_wr_data(ram1_p0_wr_data),
    .p0_wr_empty(ram1_p0_wr_empty),
    .p0_wr_full(ram1_p0_wr_full),
    .p0_wr_underrun(ram1_p0_wr_underrun),
    .p0_wr_count(ram1_p0_wr_count),
    .p0_wr_error(ram1_p0_wr_error),
    .p0_rd_clk(ram1_p0_rd_clk),
    .p0_rd_en(ram1_p0_rd_en),
    .p0_rd_data(ram1_p0_rd_data),
    .p0_rd_empty(ram1_p0_rd_empty),
    .p0_rd_full(ram1_p0_rd_full),
    .p0_rd_overflow(ram1_p0_rd_overflow),
    .p0_rd_count(ram1_p0_rd_count),
    .p0_rd_error(ram1_p0_rd_error),

    .p1_cmd_clk(ram1_p1_cmd_clk),
    .p1_cmd_en(ram1_p1_cmd_en),
    .p1_cmd_instr(ram1_p1_cmd_instr),
    .p1_cmd_bl(ram1_p1_cmd_bl),
    .p1_cmd_byte_addr(ram1_p1_cmd_byte_addr),
    .p1_cmd_empty(ram1_p1_cmd_empty),
    .p1_cmd_full(ram1_p1_cmd_full),
    .p1_wr_clk(ram1_p1_wr_clk),
    .p1_wr_en(ram1_p1_wr_en),
    .p1_wr_mask(ram1_p1_wr_mask),
    .p1_wr_data(ram1_p1_wr_data),
    .p1_wr_empty(ram1_p1_wr_empty),
    .p1_wr_full(ram1_p1_wr_full),
    .p1_wr_underrun(ram1_p1_wr_underrun),
    .p1_wr_count(ram1_p1_wr_count),
    .p1_wr_error(ram1_p1_wr_error),
    .p1_rd_clk(ram1_p1_rd_clk),
    .p1_rd_en(ram1_p1_rd_en),
    .p1_rd_data(ram1_p1_rd_data),
    .p1_rd_empty(ram1_p1_rd_empty),
    .p1_rd_full(ram1_p1_rd_full),
    .p1_rd_overflow(ram1_p1_rd_overflow),
    .p1_rd_count(ram1_p1_rd_count),
    .p1_rd_error(ram1_p1_rd_error),

    .p2_cmd_clk(ram1_p2_cmd_clk),
    .p2_cmd_en(ram1_p2_cmd_en),
    .p2_cmd_instr(ram1_p2_cmd_instr),
    .p2_cmd_bl(ram1_p2_cmd_bl),
    .p2_cmd_byte_addr(ram1_p2_cmd_byte_addr),
    .p2_cmd_empty(ram1_p2_cmd_empty),
    .p2_cmd_full(ram1_p2_cmd_full),
    .p2_rd_clk(ram1_p2_rd_clk),
    .p2_rd_en(ram1_p2_rd_en),
    .p2_rd_data(ram1_p2_rd_data),
    .p2_rd_empty(ram1_p2_rd_empty),
    .p2_rd_full(ram1_p2_rd_full),
    .p2_rd_overflow(ram1_p2_rd_overflow),
    .p2_rd_count(ram1_p2_rd_count),
    .p2_rd_error(ram1_p2_rd_error),

    .p3_cmd_clk(ram1_p3_cmd_clk),
    .p3_cmd_en(ram1_p3_cmd_en),
    .p3_cmd_instr(ram1_p3_cmd_instr),
    .p3_cmd_bl(ram1_p3_cmd_bl),
    .p3_cmd_byte_addr(ram1_p3_cmd_byte_addr),
    .p3_cmd_empty(ram1_p3_cmd_empty),
    .p3_cmd_full(ram1_p3_cmd_full),
    .p3_rd_clk(ram1_p3_rd_clk),
    .p3_rd_en(ram1_p3_rd_en),
    .p3_rd_data(ram1_p3_rd_data),
    .p3_rd_empty(ram1_p3_rd_empty),
    .p3_rd_full(ram1_p3_rd_full),
    .p3_rd_overflow(ram1_p3_rd_overflow),
    .p3_rd_count(ram1_p3_rd_count),
    .p3_rd_error(ram1_p3_rd_error),

    .p4_cmd_clk(ram1_p4_cmd_clk),
    .p4_cmd_en(ram1_p4_cmd_en),
    .p4_cmd_instr(ram1_p4_cmd_instr),
    .p4_cmd_bl(ram1_p4_cmd_bl),
    .p4_cmd_byte_addr(ram1_p4_cmd_byte_addr),
    .p4_cmd_empty(ram1_p4_cmd_empty),
    .p4_cmd_full(ram1_p4_cmd_full),
    .p4_rd_clk(ram1_p4_rd_clk),
    .p4_rd_en(ram1_p4_rd_en),
    .p4_rd_data(ram1_p4_rd_data),
    .p4_rd_empty(ram1_p4_rd_empty),
    .p4_rd_full(ram1_p4_rd_full),
    .p4_rd_overflow(ram1_p4_rd_overflow),
    .p4_rd_count(ram1_p4_rd_count),
    .p4_rd_error(ram1_p4_rd_error),

    .p5_cmd_clk(ram1_p5_cmd_clk),
    .p5_cmd_en(ram1_p5_cmd_en),
    .p5_cmd_instr(ram1_p5_cmd_instr),
    .p5_cmd_bl(ram1_p5_cmd_bl),
    .p5_cmd_byte_addr(ram1_p5_cmd_byte_addr),
    .p5_cmd_empty(ram1_p5_cmd_empty),
    .p5_cmd_full(ram1_p5_cmd_full),
    .p5_rd_clk(ram1_p5_rd_clk),
    .p5_rd_en(ram1_p5_rd_en),
    .p5_rd_data(ram1_p5_rd_data),
    .p5_rd_empty(ram1_p5_rd_empty),
    .p5_rd_full(ram1_p5_rd_full),
    .p5_rd_overflow(ram1_p5_rd_overflow),
    .p5_rd_count(ram1_p5_rd_count),
    .p5_rd_error(ram1_p5_rd_error)
);

ddr2
ddr2_ram2_inst
(
    .async_rst(rst_250mhz_int | ~mcb_clk_locked),
    .mcb_clk_0(mcb_clk_0),
    .mcb_clk_180(mcb_clk_180),
    .mcb_drp_clk(mcb_drp_clk),
    .mcb_clk_locked(mcb_clk_locked),

    .calib_done(),

    .mcbx_dram_a(ram2_a),
    .mcbx_dram_ba(ram2_ba),
    .mcbx_dram_ras_n(ram2_ras_n),
    .mcbx_dram_cas_n(ram2_cas_n),
    .mcbx_dram_we_n(ram2_we_n),
    .mcbx_dram_cke(ram2_cke),
    .mcbx_dram_ck(ram2_ck_p),
    .mcbx_dram_ck_n(ram2_ck_n),
    .mcbx_dram_dq(ram2_dq),
    .mcbx_dram_dqs(ram2_ldqs_p),
    .mcbx_dram_dqs_n(ram2_ldqs_n),
    .mcbx_dram_udqs(ram2_udqs_p),
    .mcbx_dram_udqs_n(ram2_udqs_n),
    .mcbx_dram_udm(ram2_udm),
    .mcbx_dram_dm(ram2_ldm),
    .mcbx_dram_odt(ram2_odt),
    .mcbx_rzq(ram2_rzq),
    .mcbx_zio(ram2_zio),

    .p0_cmd_clk(ram2_p0_cmd_clk),
    .p0_cmd_en(ram2_p0_cmd_en),
    .p0_cmd_instr(ram2_p0_cmd_instr),
    .p0_cmd_bl(ram2_p0_cmd_bl),
    .p0_cmd_byte_addr(ram2_p0_cmd_byte_addr),
    .p0_cmd_empty(ram2_p0_cmd_empty),
    .p0_cmd_full(ram2_p0_cmd_full),
    .p0_wr_clk(ram2_p0_wr_clk),
    .p0_wr_en(ram2_p0_wr_en),
    .p0_wr_mask(ram2_p0_wr_mask),
    .p0_wr_data(ram2_p0_wr_data),
    .p0_wr_empty(ram2_p0_wr_empty),
    .p0_wr_full(ram2_p0_wr_full),
    .p0_wr_underrun(ram2_p0_wr_underrun),
    .p0_wr_count(ram2_p0_wr_count),
    .p0_wr_error(ram2_p0_wr_error),
    .p0_rd_clk(ram2_p0_rd_clk),
    .p0_rd_en(ram2_p0_rd_en),
    .p0_rd_data(ram2_p0_rd_data),
    .p0_rd_empty(ram2_p0_rd_empty),
    .p0_rd_full(ram2_p0_rd_full),
    .p0_rd_overflow(ram2_p0_rd_overflow),
    .p0_rd_count(ram2_p0_rd_count),
    .p0_rd_error(ram2_p0_rd_error),

    .p1_cmd_clk(ram2_p1_cmd_clk),
    .p1_cmd_en(ram2_p1_cmd_en),
    .p1_cmd_instr(ram2_p1_cmd_instr),
    .p1_cmd_bl(ram2_p1_cmd_bl),
    .p1_cmd_byte_addr(ram2_p1_cmd_byte_addr),
    .p1_cmd_empty(ram2_p1_cmd_empty),
    .p1_cmd_full(ram2_p1_cmd_full),
    .p1_wr_clk(ram2_p1_wr_clk),
    .p1_wr_en(ram2_p1_wr_en),
    .p1_wr_mask(ram2_p1_wr_mask),
    .p1_wr_data(ram2_p1_wr_data),
    .p1_wr_empty(ram2_p1_wr_empty),
    .p1_wr_full(ram2_p1_wr_full),
    .p1_wr_underrun(ram2_p1_wr_underrun),
    .p1_wr_count(ram2_p1_wr_count),
    .p1_wr_error(ram2_p1_wr_error),
    .p1_rd_clk(ram2_p1_rd_clk),
    .p1_rd_en(ram2_p1_rd_en),
    .p1_rd_data(ram2_p1_rd_data),
    .p1_rd_empty(ram2_p1_rd_empty),
    .p1_rd_full(ram2_p1_rd_full),
    .p1_rd_overflow(ram2_p1_rd_overflow),
    .p1_rd_count(ram2_p1_rd_count),
    .p1_rd_error(ram2_p1_rd_error),

    .p2_cmd_clk(ram2_p2_cmd_clk),
    .p2_cmd_en(ram2_p2_cmd_en),
    .p2_cmd_instr(ram2_p2_cmd_instr),
    .p2_cmd_bl(ram2_p2_cmd_bl),
    .p2_cmd_byte_addr(ram2_p2_cmd_byte_addr),
    .p2_cmd_empty(ram2_p2_cmd_empty),
    .p2_cmd_full(ram2_p2_cmd_full),
    .p2_rd_clk(ram2_p2_rd_clk),
    .p2_rd_en(ram2_p2_rd_en),
    .p2_rd_data(ram2_p2_rd_data),
    .p2_rd_empty(ram2_p2_rd_empty),
    .p2_rd_full(ram2_p2_rd_full),
    .p2_rd_overflow(ram2_p2_rd_overflow),
    .p2_rd_count(ram2_p2_rd_count),
    .p2_rd_error(ram2_p2_rd_error),

    .p3_cmd_clk(ram2_p3_cmd_clk),
    .p3_cmd_en(ram2_p3_cmd_en),
    .p3_cmd_instr(ram2_p3_cmd_instr),
    .p3_cmd_bl(ram2_p3_cmd_bl),
    .p3_cmd_byte_addr(ram2_p3_cmd_byte_addr),
    .p3_cmd_empty(ram2_p3_cmd_empty),
    .p3_cmd_full(ram2_p3_cmd_full),
    .p3_rd_clk(ram2_p3_rd_clk),
    .p3_rd_en(ram2_p3_rd_en),
    .p3_rd_data(ram2_p3_rd_data),
    .p3_rd_empty(ram2_p3_rd_empty),
    .p3_rd_full(ram2_p3_rd_full),
    .p3_rd_overflow(ram2_p3_rd_overflow),
    .p3_rd_count(ram2_p3_rd_count),
    .p3_rd_error(ram2_p3_rd_error),

    .p4_cmd_clk(ram2_p4_cmd_clk),
    .p4_cmd_en(ram2_p4_cmd_en),
    .p4_cmd_instr(ram2_p4_cmd_instr),
    .p4_cmd_bl(ram2_p4_cmd_bl),
    .p4_cmd_byte_addr(ram2_p4_cmd_byte_addr),
    .p4_cmd_empty(ram2_p4_cmd_empty),
    .p4_cmd_full(ram2_p4_cmd_full),
    .p4_rd_clk(ram2_p4_rd_clk),
    .p4_rd_en(ram2_p4_rd_en),
    .p4_rd_data(ram2_p4_rd_data),
    .p4_rd_empty(ram2_p4_rd_empty),
    .p4_rd_full(ram2_p4_rd_full),
    .p4_rd_overflow(ram2_p4_rd_overflow),
    .p4_rd_count(ram2_p4_rd_count),
    .p4_rd_error(ram2_p4_rd_error),

    .p5_cmd_clk(ram2_p5_cmd_clk),
    .p5_cmd_en(ram2_p5_cmd_en),
    .p5_cmd_instr(ram2_p5_cmd_instr),
    .p5_cmd_bl(ram2_p5_cmd_bl),
    .p5_cmd_byte_addr(ram2_p5_cmd_byte_addr),
    .p5_cmd_empty(ram2_p5_cmd_empty),
    .p5_cmd_full(ram2_p5_cmd_full),
    .p5_rd_clk(ram2_p5_rd_clk),
    .p5_rd_en(ram2_p5_rd_en),
    .p5_rd_data(ram2_p5_rd_data),
    .p5_rd_empty(ram2_p5_rd_empty),
    .p5_rd_full(ram2_p5_rd_full),
    .p5_rd_overflow(ram2_p5_rd_overflow),
    .p5_rd_count(ram2_p5_rd_count),
    .p5_rd_error(ram2_p5_rd_error)
);

/////////////////////////////////////////////////
//                                             //
// Core Logic                                  //
//                                             //
/////////////////////////////////////////////////

fpga_core
fpga_core_inst
(
    // clocks
    .clk_250mhz_int(clk_250mhz_int),
    .rst_250mhz_int(rst_250mhz_int),

    .clk_250mhz(clk_250mhz),
    .rst_250mhz(rst_250mhz),

    .clk_10mhz(clk_10mhz),
    .rst_10mhz(rst_10mhz),

    .ext_clock_selected(ext_clock_selected),

    // SoC interface
    .cntrl_cs(cntrl_cs),
    .cntrl_sck(cntrl_sck),
    .cntrl_mosi(cntrl_mosi),
    .cntrl_miso(cntrl_miso),

    // Trigger
    .ext_trig(ext_trig),

    // Frequency counter
    .ext_prescale(ext_prescale),

    // Front end relay control
    .ferc_dat(ferc_dat),
    .ferc_clk(ferc_clk),
    .ferc_lat(ferc_lat),

    // Analog mux
    .mux_s(mux_s),

    // ADC
    .adc_sclk(adc_sclk),
    .adc_sdo(adc_sdo),
    .adc_sdi(adc_sdi),
    .adc_cs(adc_cs),
    .adc_eoc(adc_eoc),
    .adc_convst(adc_convst),

    // digital output
    .dout(dout),

    // Sync DAC
    .sync_dac(sync_dac),

    // Main DAC
    .dac_clk(dac_clk_int),
    .dac_p1_d(dac_p1_d_int),
    .dac_p2_d(dac_p2_d_int),
    .dac_sdo(dac_sdo_int),
    .dac_sdio(dac_sdio_int),
    .dac_sclk(dac_sclk_int),
    .dac_csb(dac_csb_int),
    .dac_reset(dac_reset_int),

    // ram 1 MCB (U8)
    .ram1_p0_cmd_clk(ram1_p0_cmd_clk),
    .ram1_p0_cmd_en(ram1_p0_cmd_en),
    .ram1_p0_cmd_instr(ram1_p0_cmd_instr),
    .ram1_p0_cmd_bl(ram1_p0_cmd_bl),
    .ram1_p0_cmd_byte_addr(ram1_p0_cmd_byte_addr),
    .ram1_p0_cmd_empty(ram1_p0_cmd_empty),
    .ram1_p0_cmd_full(ram1_p0_cmd_full),
    .ram1_p0_wr_clk(ram1_p0_wr_clk),
    .ram1_p0_wr_en(ram1_p0_wr_en),
    .ram1_p0_wr_mask(ram1_p0_wr_mask),
    .ram1_p0_wr_data(ram1_p0_wr_data),
    .ram1_p0_wr_empty(ram1_p0_wr_empty),
    .ram1_p0_wr_full(ram1_p0_wr_full),
    .ram1_p0_wr_underrun(ram1_p0_wr_underrun),
    .ram1_p0_wr_count(ram1_p0_wr_count),
    .ram1_p0_wr_error(ram1_p0_wr_error),
    .ram1_p0_rd_clk(ram1_p0_rd_clk),
    .ram1_p0_rd_en(ram1_p0_rd_en),
    .ram1_p0_rd_data(ram1_p0_rd_data),
    .ram1_p0_rd_empty(ram1_p0_rd_empty),
    .ram1_p0_rd_full(ram1_p0_rd_full),
    .ram1_p0_rd_overflow(ram1_p0_rd_overflow),
    .ram1_p0_rd_count(ram1_p0_rd_count),
    .ram1_p0_rd_error(ram1_p0_rd_error),

    .ram1_p1_cmd_clk(ram1_p1_cmd_clk),
    .ram1_p1_cmd_en(ram1_p1_cmd_en),
    .ram1_p1_cmd_instr(ram1_p1_cmd_instr),
    .ram1_p1_cmd_bl(ram1_p1_cmd_bl),
    .ram1_p1_cmd_byte_addr(ram1_p1_cmd_byte_addr),
    .ram1_p1_cmd_empty(ram1_p1_cmd_empty),
    .ram1_p1_cmd_full(ram1_p1_cmd_full),
    .ram1_p1_wr_clk(ram1_p1_wr_clk),
    .ram1_p1_wr_en(ram1_p1_wr_en),
    .ram1_p1_wr_mask(ram1_p1_wr_mask),
    .ram1_p1_wr_data(ram1_p1_wr_data),
    .ram1_p1_wr_empty(ram1_p1_wr_empty),
    .ram1_p1_wr_full(ram1_p1_wr_full),
    .ram1_p1_wr_underrun(ram1_p1_wr_underrun),
    .ram1_p1_wr_count(ram1_p1_wr_count),
    .ram1_p1_wr_error(ram1_p1_wr_error),
    .ram1_p1_rd_clk(ram1_p1_rd_clk),
    .ram1_p1_rd_en(ram1_p1_rd_en),
    .ram1_p1_rd_data(ram1_p1_rd_data),
    .ram1_p1_rd_empty(ram1_p1_rd_empty),
    .ram1_p1_rd_full(ram1_p1_rd_full),
    .ram1_p1_rd_overflow(ram1_p1_rd_overflow),
    .ram1_p1_rd_count(ram1_p1_rd_count),
    .ram1_p1_rd_error(ram1_p1_rd_error),

    .ram1_p2_cmd_clk(ram1_p2_cmd_clk),
    .ram1_p2_cmd_en(ram1_p2_cmd_en),
    .ram1_p2_cmd_instr(ram1_p2_cmd_instr),
    .ram1_p2_cmd_bl(ram1_p2_cmd_bl),
    .ram1_p2_cmd_byte_addr(ram1_p2_cmd_byte_addr),
    .ram1_p2_cmd_empty(ram1_p2_cmd_empty),
    .ram1_p2_cmd_full(ram1_p2_cmd_full),
    .ram1_p2_rd_clk(ram1_p2_rd_clk),
    .ram1_p2_rd_en(ram1_p2_rd_en),
    .ram1_p2_rd_data(ram1_p2_rd_data),
    .ram1_p2_rd_empty(ram1_p2_rd_empty),
    .ram1_p2_rd_full(ram1_p2_rd_full),
    .ram1_p2_rd_overflow(ram1_p2_rd_overflow),
    .ram1_p2_rd_count(ram1_p2_rd_count),
    .ram1_p2_rd_error(ram1_p2_rd_error),

    .ram1_p3_cmd_clk(ram1_p3_cmd_clk),
    .ram1_p3_cmd_en(ram1_p3_cmd_en),
    .ram1_p3_cmd_instr(ram1_p3_cmd_instr),
    .ram1_p3_cmd_bl(ram1_p3_cmd_bl),
    .ram1_p3_cmd_byte_addr(ram1_p3_cmd_byte_addr),
    .ram1_p3_cmd_empty(ram1_p3_cmd_empty),
    .ram1_p3_cmd_full(ram1_p3_cmd_full),
    .ram1_p3_rd_clk(ram1_p3_rd_clk),
    .ram1_p3_rd_en(ram1_p3_rd_en),
    .ram1_p3_rd_data(ram1_p3_rd_data),
    .ram1_p3_rd_empty(ram1_p3_rd_empty),
    .ram1_p3_rd_full(ram1_p3_rd_full),
    .ram1_p3_rd_overflow(ram1_p3_rd_overflow),
    .ram1_p3_rd_count(ram1_p3_rd_count),
    .ram1_p3_rd_error(ram1_p3_rd_error),

    .ram1_p4_cmd_clk(ram1_p4_cmd_clk),
    .ram1_p4_cmd_en(ram1_p4_cmd_en),
    .ram1_p4_cmd_instr(ram1_p4_cmd_instr),
    .ram1_p4_cmd_bl(ram1_p4_cmd_bl),
    .ram1_p4_cmd_byte_addr(ram1_p4_cmd_byte_addr),
    .ram1_p4_cmd_empty(ram1_p4_cmd_empty),
    .ram1_p4_cmd_full(ram1_p4_cmd_full),
    .ram1_p4_rd_clk(ram1_p4_rd_clk),
    .ram1_p4_rd_en(ram1_p4_rd_en),
    .ram1_p4_rd_data(ram1_p4_rd_data),
    .ram1_p4_rd_empty(ram1_p4_rd_empty),
    .ram1_p4_rd_full(ram1_p4_rd_full),
    .ram1_p4_rd_overflow(ram1_p4_rd_overflow),
    .ram1_p4_rd_count(ram1_p4_rd_count),
    .ram1_p4_rd_error(ram1_p4_rd_error),

    .ram1_p5_cmd_clk(ram1_p5_cmd_clk),
    .ram1_p5_cmd_en(ram1_p5_cmd_en),
    .ram1_p5_cmd_instr(ram1_p5_cmd_instr),
    .ram1_p5_cmd_bl(ram1_p5_cmd_bl),
    .ram1_p5_cmd_byte_addr(ram1_p5_cmd_byte_addr),
    .ram1_p5_cmd_empty(ram1_p5_cmd_empty),
    .ram1_p5_cmd_full(ram1_p5_cmd_full),
    .ram1_p5_rd_clk(ram1_p5_rd_clk),
    .ram1_p5_rd_en(ram1_p5_rd_en),
    .ram1_p5_rd_data(ram1_p5_rd_data),
    .ram1_p5_rd_empty(ram1_p5_rd_empty),
    .ram1_p5_rd_full(ram1_p5_rd_full),
    .ram1_p5_rd_overflow(ram1_p5_rd_overflow),
    .ram1_p5_rd_count(ram1_p5_rd_count),
    .ram1_p5_rd_error(ram1_p5_rd_error),

    // ram 2 MCB (U12)
    .ram2_p0_cmd_clk(ram2_p0_cmd_clk),
    .ram2_p0_cmd_en(ram2_p0_cmd_en),
    .ram2_p0_cmd_instr(ram2_p0_cmd_instr),
    .ram2_p0_cmd_bl(ram2_p0_cmd_bl),
    .ram2_p0_cmd_byte_addr(ram2_p0_cmd_byte_addr),
    .ram2_p0_cmd_empty(ram2_p0_cmd_empty),
    .ram2_p0_cmd_full(ram2_p0_cmd_full),
    .ram2_p0_wr_clk(ram2_p0_wr_clk),
    .ram2_p0_wr_en(ram2_p0_wr_en),
    .ram2_p0_wr_mask(ram2_p0_wr_mask),
    .ram2_p0_wr_data(ram2_p0_wr_data),
    .ram2_p0_wr_empty(ram2_p0_wr_empty),
    .ram2_p0_wr_full(ram2_p0_wr_full),
    .ram2_p0_wr_underrun(ram2_p0_wr_underrun),
    .ram2_p0_wr_count(ram2_p0_wr_count),
    .ram2_p0_wr_error(ram2_p0_wr_error),
    .ram2_p0_rd_clk(ram2_p0_rd_clk),
    .ram2_p0_rd_en(ram2_p0_rd_en),
    .ram2_p0_rd_data(ram2_p0_rd_data),
    .ram2_p0_rd_empty(ram2_p0_rd_empty),
    .ram2_p0_rd_full(ram2_p0_rd_full),
    .ram2_p0_rd_overflow(ram2_p0_rd_overflow),
    .ram2_p0_rd_count(ram2_p0_rd_count),
    .ram2_p0_rd_error(ram2_p0_rd_error),

    .ram2_p1_cmd_clk(ram2_p1_cmd_clk),
    .ram2_p1_cmd_en(ram2_p1_cmd_en),
    .ram2_p1_cmd_instr(ram2_p1_cmd_instr),
    .ram2_p1_cmd_bl(ram2_p1_cmd_bl),
    .ram2_p1_cmd_byte_addr(ram2_p1_cmd_byte_addr),
    .ram2_p1_cmd_empty(ram2_p1_cmd_empty),
    .ram2_p1_cmd_full(ram2_p1_cmd_full),
    .ram2_p1_wr_clk(ram2_p1_wr_clk),
    .ram2_p1_wr_en(ram2_p1_wr_en),
    .ram2_p1_wr_mask(ram2_p1_wr_mask),
    .ram2_p1_wr_data(ram2_p1_wr_data),
    .ram2_p1_wr_empty(ram2_p1_wr_empty),
    .ram2_p1_wr_full(ram2_p1_wr_full),
    .ram2_p1_wr_underrun(ram2_p1_wr_underrun),
    .ram2_p1_wr_count(ram2_p1_wr_count),
    .ram2_p1_wr_error(ram2_p1_wr_error),
    .ram2_p1_rd_clk(ram2_p1_rd_clk),
    .ram2_p1_rd_en(ram2_p1_rd_en),
    .ram2_p1_rd_data(ram2_p1_rd_data),
    .ram2_p1_rd_empty(ram2_p1_rd_empty),
    .ram2_p1_rd_full(ram2_p1_rd_full),
    .ram2_p1_rd_overflow(ram2_p1_rd_overflow),
    .ram2_p1_rd_count(ram2_p1_rd_count),
    .ram2_p1_rd_error(ram2_p1_rd_error),

    .ram2_p2_cmd_clk(ram2_p2_cmd_clk),
    .ram2_p2_cmd_en(ram2_p2_cmd_en),
    .ram2_p2_cmd_instr(ram2_p2_cmd_instr),
    .ram2_p2_cmd_bl(ram2_p2_cmd_bl),
    .ram2_p2_cmd_byte_addr(ram2_p2_cmd_byte_addr),
    .ram2_p2_cmd_empty(ram2_p2_cmd_empty),
    .ram2_p2_cmd_full(ram2_p2_cmd_full),
    .ram2_p2_rd_clk(ram2_p2_rd_clk),
    .ram2_p2_rd_en(ram2_p2_rd_en),
    .ram2_p2_rd_data(ram2_p2_rd_data),
    .ram2_p2_rd_empty(ram2_p2_rd_empty),
    .ram2_p2_rd_full(ram2_p2_rd_full),
    .ram2_p2_rd_overflow(ram2_p2_rd_overflow),
    .ram2_p2_rd_count(ram2_p2_rd_count),
    .ram2_p2_rd_error(ram2_p2_rd_error),

    .ram2_p3_cmd_clk(ram2_p3_cmd_clk),
    .ram2_p3_cmd_en(ram2_p3_cmd_en),
    .ram2_p3_cmd_instr(ram2_p3_cmd_instr),
    .ram2_p3_cmd_bl(ram2_p3_cmd_bl),
    .ram2_p3_cmd_byte_addr(ram2_p3_cmd_byte_addr),
    .ram2_p3_cmd_empty(ram2_p3_cmd_empty),
    .ram2_p3_cmd_full(ram2_p3_cmd_full),
    .ram2_p3_rd_clk(ram2_p3_rd_clk),
    .ram2_p3_rd_en(ram2_p3_rd_en),
    .ram2_p3_rd_data(ram2_p3_rd_data),
    .ram2_p3_rd_empty(ram2_p3_rd_empty),
    .ram2_p3_rd_full(ram2_p3_rd_full),
    .ram2_p3_rd_overflow(ram2_p3_rd_overflow),
    .ram2_p3_rd_count(ram2_p3_rd_count),
    .ram2_p3_rd_error(ram2_p3_rd_error),

    .ram2_p4_cmd_clk(ram2_p4_cmd_clk),
    .ram2_p4_cmd_en(ram2_p4_cmd_en),
    .ram2_p4_cmd_instr(ram2_p4_cmd_instr),
    .ram2_p4_cmd_bl(ram2_p4_cmd_bl),
    .ram2_p4_cmd_byte_addr(ram2_p4_cmd_byte_addr),
    .ram2_p4_cmd_empty(ram2_p4_cmd_empty),
    .ram2_p4_cmd_full(ram2_p4_cmd_full),
    .ram2_p4_rd_clk(ram2_p4_rd_clk),
    .ram2_p4_rd_en(ram2_p4_rd_en),
    .ram2_p4_rd_data(ram2_p4_rd_data),
    .ram2_p4_rd_empty(ram2_p4_rd_empty),
    .ram2_p4_rd_full(ram2_p4_rd_full),
    .ram2_p4_rd_overflow(ram2_p4_rd_overflow),
    .ram2_p4_rd_count(ram2_p4_rd_count),
    .ram2_p4_rd_error(ram2_p4_rd_error),

    .ram2_p5_cmd_clk(ram2_p5_cmd_clk),
    .ram2_p5_cmd_en(ram2_p5_cmd_en),
    .ram2_p5_cmd_instr(ram2_p5_cmd_instr),
    .ram2_p5_cmd_bl(ram2_p5_cmd_bl),
    .ram2_p5_cmd_byte_addr(ram2_p5_cmd_byte_addr),
    .ram2_p5_cmd_empty(ram2_p5_cmd_empty),
    .ram2_p5_cmd_full(ram2_p5_cmd_full),
    .ram2_p5_rd_clk(ram2_p5_rd_clk),
    .ram2_p5_rd_en(ram2_p5_rd_en),
    .ram2_p5_rd_data(ram2_p5_rd_data),
    .ram2_p5_rd_empty(ram2_p5_rd_empty),
    .ram2_p5_rd_full(ram2_p5_rd_full),
    .ram2_p5_rd_overflow(ram2_p5_rd_overflow),
    .ram2_p5_rd_count(ram2_p5_rd_count),
    .ram2_p5_rd_error(ram2_p5_rd_error)
);

endmodule
