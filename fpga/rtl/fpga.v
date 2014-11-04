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


	// ram 1 (U12)
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

	.ext_clock_selected(ext_clock_selected)
);


// generate 10 MHz ref out
// 25 cycle counter, falling edge interpolated
reg [4:0] count_reg = 0;
reg q0 = 0;
reg q1 = 0;

always @(posedge clk_250mhz or posedge rst_250mhz) begin
    if (rst_250mhz) begin
        count_reg <= 0;
        q0 <= 0;
        q1 <= 0;
    end else begin
        if (count_reg < 24) begin
            count_reg <= count_reg + 1;
        end else begin
            count_reg <= 0;
        end
        q0 <= count_reg < 12;
        q1 <= count_reg < 13;
    end
end

ODDR2
clk_10mhz_out_oddr2_inst
(
	.Q(clk_10mhz_out),
	.C0(clk_250mhz),
	.C1(~clk_250mhz),
	.CE(1),
	.D0(q0),
	.D1(q1),
	.R(0),
	.S(0)
);

reg [15:0] count = 0;

assign cntrl_miso = 0;

assign ferc_dat = 0;
assign ferc_lat = 0;
assign ferc_clk = 0;

assign mux_s = 0;

assign adc_sclk = 0;
assign adc_sdi = 0;
assign adc_cs = 0;
assign adc_convst = 0;

wire dac_clk;

ODDR2
dac_clk_oddr2_inst
(
	.Q(dac_clk),
	.C0(clk_250mhz),
	.C1(~clk_250mhz),
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

reg [15:0] dac_p1_d_reg = 0;
reg [15:0] dac_p2_d_reg = 0;

always @(posedge clk_250mhz) begin
	dac_p1_d_reg <= count;
	dac_p2_d_reg <= -count;
end

(* IOB = "TRUE" *)
reg [15:0] dac_p1_d_oreg;
(* IOB = "TRUE" *)
reg [15:0] dac_p2_d_oreg;

always @(posedge clk_250mhz) begin
	dac_p1_d_oreg <= dac_p1_d_reg;
	dac_p2_d_oreg <= dac_p2_d_reg;
end

assign dac_p1_d = dac_p1_d_oreg;
assign dac_p2_d = dac_p2_d_oreg;

assign dac_sdio = 0;
assign dac_sclk = 0;
assign dac_csb = 0;
assign dac_reset = 0;

assign sync_dac = count[15:8];
assign dout = count;


always @(posedge clk_250mhz) begin
	count <= count + 1;
end

wire mcb_clk_0;
wire mcb_clk_180;
wire mcb_drp_clk;
wire mcb_clk_locked;

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

    .p0_cmd_clk(0),
    .p0_cmd_en(0),
    .p0_cmd_instr(0),
    .p0_cmd_bl(0),
    .p0_cmd_byte_addr(0),
    .p0_cmd_empty(),
    .p0_cmd_full(),
    .p0_wr_clk(0),
    .p0_wr_en(0),
    .p0_wr_mask(0),
    .p0_wr_data(0),
    .p0_wr_empty(),
    .p0_wr_full(),
    .p0_wr_underrun(),
    .p0_wr_count(),
    .p0_wr_error(),
    .p0_rd_clk(0),
    .p0_rd_en(0),
    .p0_rd_data(),
    .p0_rd_empty(),
    .p0_rd_full(),
    .p0_rd_overflow(),
    .p0_rd_count(),
    .p0_rd_error(),

    .p1_cmd_clk(0),
    .p1_cmd_en(0),
    .p1_cmd_instr(0),
    .p1_cmd_bl(0),
    .p1_cmd_byte_addr(0),
    .p1_cmd_empty(),
    .p1_cmd_full(),
    .p1_wr_clk(0),
    .p1_wr_en(0),
    .p1_wr_mask(0),
    .p1_wr_data(0),
    .p1_wr_empty(),
    .p1_wr_full(),
    .p1_wr_underrun(),
    .p1_wr_count(),
    .p1_wr_error(),
    .p1_rd_clk(0),
    .p1_rd_en(0),
    .p1_rd_data(),
    .p1_rd_empty(),
    .p1_rd_full(),
    .p1_rd_overflow(),
    .p1_rd_count(),
    .p1_rd_error(),

    .p2_cmd_clk(0),
    .p2_cmd_en(0),
    .p2_cmd_instr(0),
    .p2_cmd_bl(0),
    .p2_cmd_byte_addr(0),
    .p2_cmd_empty(),
    .p2_cmd_full(),
    .p2_rd_clk(0),
    .p2_rd_en(0),
    .p2_rd_data(),
    .p2_rd_empty(),
    .p2_rd_full(),
    .p2_rd_overflow(),
    .p2_rd_count(),
    .p2_rd_error(),

    .p3_cmd_clk(0),
    .p3_cmd_en(0),
    .p3_cmd_instr(0),
    .p3_cmd_bl(0),
    .p3_cmd_byte_addr(0),
    .p3_cmd_empty(),
    .p3_cmd_full(),
    .p3_rd_clk(0),
    .p3_rd_en(0),
    .p3_rd_data(),
    .p3_rd_empty(),
    .p3_rd_full(),
    .p3_rd_overflow(),
    .p3_rd_count(),
    .p3_rd_error(),

    .p4_cmd_clk(0),
    .p4_cmd_en(0),
    .p4_cmd_instr(0),
    .p4_cmd_bl(0),
    .p4_cmd_byte_addr(0),
    .p4_cmd_empty(),
    .p4_cmd_full(),
    .p4_rd_clk(0),
    .p4_rd_en(0),
    .p4_rd_data(),
    .p4_rd_empty(),
    .p4_rd_full(),
    .p4_rd_overflow(),
    .p4_rd_count(),
    .p4_rd_error(),

    .p5_cmd_clk(0),
    .p5_cmd_en(0),
    .p5_cmd_instr(0),
    .p5_cmd_bl(0),
    .p5_cmd_byte_addr(0),
    .p5_cmd_empty(),
    .p5_cmd_full(),
    .p5_rd_clk(0),
    .p5_rd_en(0),
    .p5_rd_data(),
    .p5_rd_empty(),
    .p5_rd_full(),
    .p5_rd_overflow(),
    .p5_rd_count(),
    .p5_rd_error()
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

    .p0_cmd_clk(0),
    .p0_cmd_en(0),
    .p0_cmd_instr(0),
    .p0_cmd_bl(0),
    .p0_cmd_byte_addr(0),
    .p0_cmd_empty(),
    .p0_cmd_full(),
    .p0_wr_clk(0),
    .p0_wr_en(0),
    .p0_wr_mask(0),
    .p0_wr_data(0),
    .p0_wr_empty(),
    .p0_wr_full(),
    .p0_wr_underrun(),
    .p0_wr_count(),
    .p0_wr_error(),
    .p0_rd_clk(0),
    .p0_rd_en(0),
    .p0_rd_data(),
    .p0_rd_empty(),
    .p0_rd_full(),
    .p0_rd_overflow(),
    .p0_rd_count(),
    .p0_rd_error(),

    .p1_cmd_clk(0),
    .p1_cmd_en(0),
    .p1_cmd_instr(0),
    .p1_cmd_bl(0),
    .p1_cmd_byte_addr(0),
    .p1_cmd_empty(),
    .p1_cmd_full(),
    .p1_wr_clk(0),
    .p1_wr_en(0),
    .p1_wr_mask(0),
    .p1_wr_data(0),
    .p1_wr_empty(),
    .p1_wr_full(),
    .p1_wr_underrun(),
    .p1_wr_count(),
    .p1_wr_error(),
    .p1_rd_clk(0),
    .p1_rd_en(0),
    .p1_rd_data(),
    .p1_rd_empty(),
    .p1_rd_full(),
    .p1_rd_overflow(),
    .p1_rd_count(),
    .p1_rd_error(),

    .p2_cmd_clk(0),
    .p2_cmd_en(0),
    .p2_cmd_instr(0),
    .p2_cmd_bl(0),
    .p2_cmd_byte_addr(0),
    .p2_cmd_empty(),
    .p2_cmd_full(),
    .p2_rd_clk(0),
    .p2_rd_en(0),
    .p2_rd_data(),
    .p2_rd_empty(),
    .p2_rd_full(),
    .p2_rd_overflow(),
    .p2_rd_count(),
    .p2_rd_error(),

    .p3_cmd_clk(0),
    .p3_cmd_en(0),
    .p3_cmd_instr(0),
    .p3_cmd_bl(0),
    .p3_cmd_byte_addr(0),
    .p3_cmd_empty(),
    .p3_cmd_full(),
    .p3_rd_clk(0),
    .p3_rd_en(0),
    .p3_rd_data(),
    .p3_rd_empty(),
    .p3_rd_full(),
    .p3_rd_overflow(),
    .p3_rd_count(),
    .p3_rd_error(),

    .p4_cmd_clk(0),
    .p4_cmd_en(0),
    .p4_cmd_instr(0),
    .p4_cmd_bl(0),
    .p4_cmd_byte_addr(0),
    .p4_cmd_empty(),
    .p4_cmd_full(),
    .p4_rd_clk(0),
    .p4_rd_en(0),
    .p4_rd_data(),
    .p4_rd_empty(),
    .p4_rd_full(),
    .p4_rd_overflow(),
    .p4_rd_count(),
    .p4_rd_error(),

    .p5_cmd_clk(0),
    .p5_cmd_en(0),
    .p5_cmd_instr(0),
    .p5_cmd_bl(0),
    .p5_cmd_byte_addr(0),
    .p5_cmd_empty(),
    .p5_cmd_full(),
    .p5_rd_clk(0),
    .p5_rd_en(0),
    .p5_rd_data(),
    .p5_rd_empty(),
    .p5_rd_full(),
    .p5_rd_overflow(),
    .p5_rd_count(),
    .p5_rd_error()
);

endmodule
