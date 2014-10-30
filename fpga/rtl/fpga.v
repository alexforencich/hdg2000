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
	output wire dac_reset

	// // ram 1 (U8)
	// output wire ram1_cke,
	// output wire ram1_ck_p,
	// output wire ram1_ck_n,
	// output wire ram1_cs_n,
	// output wire ram1_ras_n,
	// output wire ram1_cas_n,
	// output wire ram1_we_n,
	// output wire [12:0] ram1_a,
	// output wire [2:0]  ram1_ba,
	// inout  wire [15:0] ram1_dq,
	// inout  wire ram1_lqds_p,
	// inout  wire ram1_lqds_n,
	// output wire ram1_ldm,
	// inout  wire ram1_uqds_p,
	// inout  wire ram1_uqds_n,
	// output wire ram1_udm,

	// // ram 1 (U12)
	// output wire ram2_cke,
	// output wire ram2_ck_p,
	// output wire ram2_ck_n,
	// output wire ram2_cs_n,
	// output wire ram2_ras_n,
	// output wire ram2_cas_n,
	// output wire ram2_we_n,
	// output wire [12:0] ram2_a,
	// output wire [2:0]  ram2_ba,
	// inout  wire [15:0] ram2_dq,
	// inout  wire ram2_lqds_p,
	// inout  wire ram2_lqds_n,
	// output wire ram2_ldm,
	// inout  wire ram2_uqds_p,
	// inout  wire ram2_uqds_n,
	// output wire ram2_udm
);

wire clk_250mhz_int;

wire clk_250mhz;
wire clk_10mhz;

clock
clock_inst
(
	.reset_in(0),

	.clk_10mhz_int(clk_10mhz_int),
	.clk_10mhz_ext(clk_10mhz_ext),

	.clk_250mhz_int(clk_250mhz_int),

	.clk_250mhz(clk_250mhz),
	.clk_10mhz(clk_10mhz)
);

ODDR2
clk_10mhz_out_oddr2_inst
(
	.Q(clk_10mhz_out),
	.C0(clk_10mhz),
	.C1(~clk_10mhz),
	.CE(1),
	.D0(1),
	.D1(0),
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

assign dac_p1_d = count;
assign dac_p2_d = count;
assign dac_sdio = 0;
assign dac_sclk = 0;
assign dac_csb = 0;
assign dac_reset = 0;

assign sync_dac = count[15:8];
assign dout = count;


always @(posedge clk_250mhz) begin
	count <= count + 1;
end

endmodule
