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

module test_fpga_core;

reg [7:0] current_test = 0;

// clocks
reg clk_250mhz_int = 0;
reg rst_250mhz_int = 0;

reg clk_250mhz = 0;
reg rst_250mhz = 0;

reg clk_10mhz = 0;
reg rst_10mhz = 0;

reg ext_clock_selected = 0;

// SoC interface
reg cntrl_cs = 0;
reg cntrl_sck = 0;
reg cntrl_mosi = 0;
wire cntrl_miso;

// Trigger
reg ext_trig = 0;

// Frequency counter
reg ext_prescale = 0;

// Front end relay control
wire ferc_dat;
wire ferc_clk;
wire ferc_lat;

// Analog mux
wire [2:0] mux_s;

// ADC
wire adc_sclk;
reg adc_sdo = 0;
wire adc_sdi;
wire adc_cs;
reg adc_eoc = 0;
wire adc_convst;

// digital output
wire [15:0] dout;

// Sync DAC
wire [7:0] sync_dac;

// Main DAC
wire dac_clk;
wire [15:0] dac_p1_d;
wire [15:0] dac_p2_d;
reg dac_sdo = 0;
wire dac_sdio;
wire dac_sclk;
wire dac_csb;
wire dac_reset;

// ram 1 MCB (U8)
reg ram1_calib_done = 0;

wire ram1_p0_cmd_clk;
wire ram1_p0_cmd_en;
wire [2:0] ram1_p0_cmd_instr;
wire [5:0] ram1_p0_cmd_bl;
wire [31:0] ram1_p0_cmd_byte_addr;
reg ram1_p0_cmd_empty = 0;
reg ram1_p0_cmd_full = 0;
wire ram1_p0_wr_clk;
wire ram1_p0_wr_en;
wire [3:0] ram1_p0_wr_mask;
wire [31:0] ram1_p0_wr_data;
reg ram1_p0_wr_empty = 0;
reg ram1_p0_wr_full = 0;
reg ram1_p0_wr_underrun = 0;
reg [6:0] ram1_p0_wr_count = 0;
reg ram1_p0_wr_error = 0;
wire ram1_p0_rd_clk;
wire ram1_p0_rd_en;
reg [31:0] ram1_p0_rd_data = 0;
reg ram1_p0_rd_empty = 0;
reg ram1_p0_rd_full = 0;
reg ram1_p0_rd_overflow = 0;
reg [6:0] ram1_p0_rd_count = 0;
reg ram1_p0_rd_error = 0;

wire ram1_p1_cmd_clk;
wire ram1_p1_cmd_en;
wire [2:0] ram1_p1_cmd_instr;
wire [5:0] ram1_p1_cmd_bl;
wire [31:0] ram1_p1_cmd_byte_addr;
reg ram1_p1_cmd_empty = 0;
reg ram1_p1_cmd_full = 0;
wire ram1_p1_wr_clk;
wire ram1_p1_wr_en;
wire [3:0] ram1_p1_wr_mask;
wire [31:0] ram1_p1_wr_data;
reg ram1_p1_wr_empty = 0;
reg ram1_p1_wr_full = 0;
reg ram1_p1_wr_underrun = 0;
reg [6:0] ram1_p1_wr_count = 0;
reg ram1_p1_wr_error = 0;
wire ram1_p1_rd_clk;
wire ram1_p1_rd_en;
reg [31:0] ram1_p1_rd_data = 0;
reg ram1_p1_rd_empty = 0;
reg ram1_p1_rd_full = 0;
reg ram1_p1_rd_overflow = 0;
reg [6:0] ram1_p1_rd_count = 0;
reg ram1_p1_rd_error = 0;

wire ram1_p2_cmd_clk;
wire ram1_p2_cmd_en;
wire [2:0] ram1_p2_cmd_instr;
wire [5:0] ram1_p2_cmd_bl;
wire [31:0] ram1_p2_cmd_byte_addr;
reg ram1_p2_cmd_empty = 0;
reg ram1_p2_cmd_full = 0;
wire ram1_p2_rd_clk;
wire ram1_p2_rd_en;
reg [31:0] ram1_p2_rd_data = 0;
reg ram1_p2_rd_empty = 0;
reg ram1_p2_rd_full = 0;
reg ram1_p2_rd_overflow = 0;
reg [6:0] ram1_p2_rd_count = 0;
reg ram1_p2_rd_error = 0;

wire ram1_p3_cmd_clk;
wire ram1_p3_cmd_en;
wire [2:0] ram1_p3_cmd_instr;
wire [5:0] ram1_p3_cmd_bl;
wire [31:0] ram1_p3_cmd_byte_addr;
reg ram1_p3_cmd_empty = 0;
reg ram1_p3_cmd_full = 0;
wire ram1_p3_rd_clk;
wire ram1_p3_rd_en;
reg [31:0] ram1_p3_rd_data = 0;
reg ram1_p3_rd_empty = 0;
reg ram1_p3_rd_full = 0;
reg ram1_p3_rd_overflow = 0;
reg [6:0] ram1_p3_rd_count = 0;
reg ram1_p3_rd_error = 0;

wire ram1_p4_cmd_clk;
wire ram1_p4_cmd_en;
wire [2:0] ram1_p4_cmd_instr;
wire [5:0] ram1_p4_cmd_bl;
wire [31:0] ram1_p4_cmd_byte_addr;
reg ram1_p4_cmd_empty = 0;
reg ram1_p4_cmd_full = 0;
wire ram1_p4_rd_clk;
wire ram1_p4_rd_en;
reg [31:0] ram1_p4_rd_data = 0;
reg ram1_p4_rd_empty = 0;
reg ram1_p4_rd_full = 0;
reg ram1_p4_rd_overflow = 0;
reg [6:0] ram1_p4_rd_count = 0;
reg ram1_p4_rd_error = 0;

wire ram1_p5_cmd_clk;
wire ram1_p5_cmd_en;
wire [2:0] ram1_p5_cmd_instr;
wire [5:0] ram1_p5_cmd_bl;
wire [31:0] ram1_p5_cmd_byte_addr;
reg ram1_p5_cmd_empty = 0;
reg ram1_p5_cmd_full = 0;
wire ram1_p5_rd_clk;
wire ram1_p5_rd_en;
reg [31:0] ram1_p5_rd_data = 0;
reg ram1_p5_rd_empty = 0;
reg ram1_p5_rd_full = 0;
reg ram1_p5_rd_overflow = 0;
reg [6:0] ram1_p5_rd_count = 0;
reg ram1_p5_rd_error = 0;

// ram 2 MCB (U12)
reg ram2_calib_done = 0;

wire ram2_p0_cmd_clk;
wire ram2_p0_cmd_en;
wire [2:0] ram2_p0_cmd_instr;
wire [5:0] ram2_p0_cmd_bl;
wire [31:0] ram2_p0_cmd_byte_addr;
reg ram2_p0_cmd_empty = 0;
reg ram2_p0_cmd_full = 0;
wire ram2_p0_wr_clk;
wire ram2_p0_wr_en;
wire [3:0] ram2_p0_wr_mask;
wire [31:0] ram2_p0_wr_data;
reg ram2_p0_wr_empty = 0;
reg ram2_p0_wr_full = 0;
reg ram2_p0_wr_underrun = 0;
reg [6:0] ram2_p0_wr_count = 0;
reg ram2_p0_wr_error = 0;
wire ram2_p0_rd_clk;
wire ram2_p0_rd_en;
reg [31:0] ram2_p0_rd_data = 0;
reg ram2_p0_rd_empty = 0;
reg ram2_p0_rd_full = 0;
reg ram2_p0_rd_overflow = 0;
reg [6:0] ram2_p0_rd_count = 0;
reg ram2_p0_rd_error = 0;

wire ram2_p1_cmd_clk;
wire ram2_p1_cmd_en;
wire [2:0] ram2_p1_cmd_instr;
wire [5:0] ram2_p1_cmd_bl;
wire [31:0] ram2_p1_cmd_byte_addr;
reg ram2_p1_cmd_empty = 0;
reg ram2_p1_cmd_full = 0;
wire ram2_p1_wr_clk;
wire ram2_p1_wr_en;
wire [3:0] ram2_p1_wr_mask;
wire [31:0] ram2_p1_wr_data;
reg ram2_p1_wr_empty = 0;
reg ram2_p1_wr_full = 0;
reg ram2_p1_wr_underrun = 0;
reg [6:0] ram2_p1_wr_count = 0;
reg ram2_p1_wr_error = 0;
wire ram2_p1_rd_clk;
wire ram2_p1_rd_en;
reg [31:0] ram2_p1_rd_data = 0;
reg ram2_p1_rd_empty = 0;
reg ram2_p1_rd_full = 0;
reg ram2_p1_rd_overflow = 0;
reg [6:0] ram2_p1_rd_count = 0;
reg ram2_p1_rd_error = 0;

wire ram2_p2_cmd_clk;
wire ram2_p2_cmd_en;
wire [2:0] ram2_p2_cmd_instr;
wire [5:0] ram2_p2_cmd_bl;
wire [31:0] ram2_p2_cmd_byte_addr;
reg ram2_p2_cmd_empty = 0;
reg ram2_p2_cmd_full = 0;
wire ram2_p2_rd_clk;
wire ram2_p2_rd_en;
reg [31:0] ram2_p2_rd_data = 0;
reg ram2_p2_rd_empty = 0;
reg ram2_p2_rd_full = 0;
reg ram2_p2_rd_overflow = 0;
reg [6:0] ram2_p2_rd_count = 0;
reg ram2_p2_rd_error = 0;

wire ram2_p3_cmd_clk;
wire ram2_p3_cmd_en;
wire [2:0] ram2_p3_cmd_instr;
wire [5:0] ram2_p3_cmd_bl;
wire [31:0] ram2_p3_cmd_byte_addr;
reg ram2_p3_cmd_empty = 0;
reg ram2_p3_cmd_full = 0;
wire ram2_p3_rd_clk;
wire ram2_p3_rd_en;
reg [31:0] ram2_p3_rd_data = 0;
reg ram2_p3_rd_empty = 0;
reg ram2_p3_rd_full = 0;
reg ram2_p3_rd_overflow = 0;
reg [6:0] ram2_p3_rd_count = 0;
reg ram2_p3_rd_error = 0;

wire ram2_p4_cmd_clk;
wire ram2_p4_cmd_en;
wire [2:0] ram2_p4_cmd_instr;
wire [5:0] ram2_p4_cmd_bl;
wire [31:0] ram2_p4_cmd_byte_addr;
reg ram2_p4_cmd_empty = 0;
reg ram2_p4_cmd_full = 0;
wire ram2_p4_rd_clk;
wire ram2_p4_rd_en;
reg [31:0] ram2_p4_rd_data = 0;
reg ram2_p4_rd_empty = 0;
reg ram2_p4_rd_full = 0;
reg ram2_p4_rd_overflow = 0;
reg [6:0] ram2_p4_rd_count = 0;
reg ram2_p4_rd_error = 0;

wire ram2_p5_cmd_clk;
wire ram2_p5_cmd_en;
wire [2:0] ram2_p5_cmd_instr;
wire [5:0] ram2_p5_cmd_bl;
wire [31:0] ram2_p5_cmd_byte_addr;
reg ram2_p5_cmd_empty = 0;
reg ram2_p5_cmd_full = 0;
wire ram2_p5_rd_clk;
wire ram2_p5_rd_en;
reg [31:0] ram2_p5_rd_data = 0;
reg ram2_p5_rd_empty = 0;
reg ram2_p5_rd_full = 0;
reg ram2_p5_rd_overflow = 0;
reg [6:0] ram2_p5_rd_count = 0;
reg ram2_p5_rd_error = 0;

initial begin
    // myhdl integration
    $from_myhdl(current_test,
                clk_250mhz_int,
                rst_250mhz_int,
                clk_250mhz,
                rst_250mhz,
                clk_10mhz,
                rst_10mhz,
                ext_clock_selected,
                cntrl_cs,
                cntrl_sck,
                cntrl_mosi,
                ext_trig,
                ext_prescale,
                adc_sdo,
                adc_eoc,
                dac_sdo,
                ram1_calib_done,
                ram1_p0_cmd_empty,
                ram1_p0_cmd_full,
                ram1_p0_wr_empty,
                ram1_p0_wr_full,
                ram1_p0_wr_underrun,
                ram1_p0_wr_count,
                ram1_p0_wr_error,
                ram1_p0_rd_data,
                ram1_p0_rd_empty,
                ram1_p0_rd_full,
                ram1_p0_rd_overflow,
                ram1_p0_rd_count,
                ram1_p0_rd_error,
                ram1_p1_cmd_empty,
                ram1_p1_cmd_full,
                ram1_p1_wr_empty,
                ram1_p1_wr_full,
                ram1_p1_wr_underrun,
                ram1_p1_wr_count,
                ram1_p1_wr_error,
                ram1_p1_rd_data,
                ram1_p1_rd_empty,
                ram1_p1_rd_full,
                ram1_p1_rd_overflow,
                ram1_p1_rd_count,
                ram1_p1_rd_error,
                ram1_p2_cmd_empty,
                ram1_p2_cmd_full,
                ram1_p2_rd_data,
                ram1_p2_rd_empty,
                ram1_p2_rd_full,
                ram1_p2_rd_overflow,
                ram1_p2_rd_count,
                ram1_p2_rd_error,
                ram1_p3_cmd_empty,
                ram1_p3_cmd_full,
                ram1_p3_rd_data,
                ram1_p3_rd_empty,
                ram1_p3_rd_full,
                ram1_p3_rd_overflow,
                ram1_p3_rd_count,
                ram1_p3_rd_error,
                ram1_p4_cmd_empty,
                ram1_p4_cmd_full,
                ram1_p4_rd_data,
                ram1_p4_rd_empty,
                ram1_p4_rd_full,
                ram1_p4_rd_overflow,
                ram1_p4_rd_count,
                ram1_p4_rd_error,
                ram1_p5_cmd_empty,
                ram1_p5_cmd_full,
                ram1_p5_rd_data,
                ram1_p5_rd_empty,
                ram1_p5_rd_full,
                ram1_p5_rd_overflow,
                ram1_p5_rd_count,
                ram1_p5_rd_error,
                ram2_calib_done,
                ram2_p0_cmd_empty,
                ram2_p0_cmd_full,
                ram2_p0_wr_empty,
                ram2_p0_wr_full,
                ram2_p0_wr_underrun,
                ram2_p0_wr_count,
                ram2_p0_wr_error,
                ram2_p0_rd_data,
                ram2_p0_rd_empty,
                ram2_p0_rd_full,
                ram2_p0_rd_overflow,
                ram2_p0_rd_count,
                ram2_p0_rd_error,
                ram2_p1_cmd_empty,
                ram2_p1_cmd_full,
                ram2_p1_wr_empty,
                ram2_p1_wr_full,
                ram2_p1_wr_underrun,
                ram2_p1_wr_count,
                ram2_p1_wr_error,
                ram2_p1_rd_data,
                ram2_p1_rd_empty,
                ram2_p1_rd_full,
                ram2_p1_rd_overflow,
                ram2_p1_rd_count,
                ram2_p1_rd_error,
                ram2_p2_cmd_empty,
                ram2_p2_cmd_full,
                ram2_p2_rd_data,
                ram2_p2_rd_empty,
                ram2_p2_rd_full,
                ram2_p2_rd_overflow,
                ram2_p2_rd_count,
                ram2_p2_rd_error,
                ram2_p3_cmd_empty,
                ram2_p3_cmd_full,
                ram2_p3_rd_data,
                ram2_p3_rd_empty,
                ram2_p3_rd_full,
                ram2_p3_rd_overflow,
                ram2_p3_rd_count,
                ram2_p3_rd_error,
                ram2_p4_cmd_empty,
                ram2_p4_cmd_full,
                ram2_p4_rd_data,
                ram2_p4_rd_empty,
                ram2_p4_rd_full,
                ram2_p4_rd_overflow,
                ram2_p4_rd_count,
                ram2_p4_rd_error,
                ram2_p5_cmd_empty,
                ram2_p5_cmd_full,
                ram2_p5_rd_data,
                ram2_p5_rd_empty,
                ram2_p5_rd_full,
                ram2_p5_rd_overflow,
                ram2_p5_rd_count,
                ram2_p5_rd_error);
    $to_myhdl(cntrl_miso,
                ferc_dat,
                ferc_clk,
                ferc_lat,
                mux_s,
                adc_sclk,
                adc_sdi,
                adc_cs,
                adc_convst,
                dout,
                sync_dac,
                dac_clk,
                dac_p1_d,
                dac_p2_d,
                dac_sdio,
                dac_sclk,
                dac_csb,
                dac_reset,
                ram1_p0_cmd_clk,
                ram1_p0_cmd_en,
                ram1_p0_cmd_instr,
                ram1_p0_cmd_bl,
                ram1_p0_cmd_byte_addr,
                ram1_p0_wr_clk,
                ram1_p0_wr_en,
                ram1_p0_wr_mask,
                ram1_p0_wr_data,
                ram1_p0_rd_clk,
                ram1_p0_rd_en,
                ram1_p1_cmd_clk,
                ram1_p1_cmd_en,
                ram1_p1_cmd_instr,
                ram1_p1_cmd_bl,
                ram1_p1_cmd_byte_addr,
                ram1_p1_wr_clk,
                ram1_p1_wr_en,
                ram1_p1_wr_mask,
                ram1_p1_wr_data,
                ram1_p1_rd_clk,
                ram1_p1_rd_en,
                ram1_p2_cmd_clk,
                ram1_p2_cmd_en,
                ram1_p2_cmd_instr,
                ram1_p2_cmd_bl,
                ram1_p2_cmd_byte_addr,
                ram1_p2_rd_clk,
                ram1_p2_rd_en,
                ram1_p3_cmd_clk,
                ram1_p3_cmd_en,
                ram1_p3_cmd_instr,
                ram1_p3_cmd_bl,
                ram1_p3_cmd_byte_addr,
                ram1_p3_rd_clk,
                ram1_p3_rd_en,
                ram1_p4_cmd_clk,
                ram1_p4_cmd_en,
                ram1_p4_cmd_instr,
                ram1_p4_cmd_bl,
                ram1_p4_cmd_byte_addr,
                ram1_p4_rd_clk,
                ram1_p4_rd_en,
                ram1_p5_cmd_clk,
                ram1_p5_cmd_en,
                ram1_p5_cmd_instr,
                ram1_p5_cmd_bl,
                ram1_p5_cmd_byte_addr,
                ram1_p5_rd_clk,
                ram1_p5_rd_en,
                ram2_p0_cmd_clk,
                ram2_p0_cmd_en,
                ram2_p0_cmd_instr,
                ram2_p0_cmd_bl,
                ram2_p0_cmd_byte_addr,
                ram2_p0_wr_clk,
                ram2_p0_wr_en,
                ram2_p0_wr_mask,
                ram2_p0_wr_data,
                ram2_p0_rd_clk,
                ram2_p0_rd_en,
                ram2_p1_cmd_clk,
                ram2_p1_cmd_en,
                ram2_p1_cmd_instr,
                ram2_p1_cmd_bl,
                ram2_p1_cmd_byte_addr,
                ram2_p1_wr_clk,
                ram2_p1_wr_en,
                ram2_p1_wr_mask,
                ram2_p1_wr_data,
                ram2_p1_rd_clk,
                ram2_p1_rd_en,
                ram2_p2_cmd_clk,
                ram2_p2_cmd_en,
                ram2_p2_cmd_instr,
                ram2_p2_cmd_bl,
                ram2_p2_cmd_byte_addr,
                ram2_p2_rd_clk,
                ram2_p2_rd_en,
                ram2_p3_cmd_clk,
                ram2_p3_cmd_en,
                ram2_p3_cmd_instr,
                ram2_p3_cmd_bl,
                ram2_p3_cmd_byte_addr,
                ram2_p3_rd_clk,
                ram2_p3_rd_en,
                ram2_p4_cmd_clk,
                ram2_p4_cmd_en,
                ram2_p4_cmd_instr,
                ram2_p4_cmd_bl,
                ram2_p4_cmd_byte_addr,
                ram2_p4_rd_clk,
                ram2_p4_rd_en,
                ram2_p5_cmd_clk,
                ram2_p5_cmd_en,
                ram2_p5_cmd_instr,
                ram2_p5_cmd_bl,
                ram2_p5_cmd_byte_addr,
                ram2_p5_rd_clk,
                ram2_p5_rd_en);

    // dump file
    $dumpfile("test_fpga_core.lxt");
    $dumpvars(0, test_fpga_core);
end

fpga_core
UUT (
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
    .dac_clk(dac_clk),
    .dac_p1_d(dac_p1_d),
    .dac_p2_d(dac_p2_d),
    .dac_sdo(dac_sdo),
    .dac_sdio(dac_sdio),
    .dac_sclk(dac_sclk),
    .dac_csb(dac_csb),
    .dac_reset(dac_reset),

    // ram 1 MCB (U8)
    .ram1_calib_done(ram1_calib_done),

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
    .ram2_calib_done(ram2_calib_done),

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
