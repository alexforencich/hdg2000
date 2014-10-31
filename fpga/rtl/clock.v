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
 * Clock management
 */
module clock
(
    // system reset (can be tied to zero)
    input wire reset_in,

    // 10 MHz reference clock inputs
    // clk_10mhz_int is internal failsafe clock
    // clk_10mhz_ext is external accurate clock (preferred)
    input wire clk_10mhz_int,
    input wire clk_10mhz_ext,

    // 250 MHz internal clock and reset
    output wire clk_250mhz_int,
    output wire rst_250mhz_int,

    // 250 MHz and 10 MHz clock and reset from best oscillator
    output wire clk_250mhz,
    output wire rst_250mhz,

    output wire ext_clock_selected
);

/*

The clock managment module is desiged to intelligently manage the system
reference clock source.  This module brings in two separate reference clocks -
an onboard low quality clock, and an optional external clock of higher quality.
The module detects the external clock input and automatically switches over
when it is stable.  

          clk_10mhz_int      clk_10mhz_ext
                |                  |
                |                  +---> counter --> threshold/hyst.
                |                  |                        |
                V                  V                        |
           DCM_CLKGEN         DCM_CLKGEN                    |
                |                  |                        |
          clk_250mhz_int     clk_250mhz_ext                 |
                |                  |                        |
    Logic  <----+                  |                        |
    DDR2        |                  |                        |
              __V__________________V__                      |
              \______________________/ <--------------------+
                         |
                         |
                     clk_250mhz
                         |
                         V
               DSP, DDS, DAC, REF out


*/

// clocks
wire clk_10mhz_int_ibufg;
wire clk_10mhz_int_bufg;
wire clk_10mhz_ext_ibufg;
wire clk_10mhz_ext_bufg;

wire clk_250mhz_int_dcm;
wire clk_250mhz_ext_dcm;
wire clk_250mhz_ext;

wire clk_250mhz_out;
wire clk_10mhz_out;

// resets
wire rst_10mhz_int;
wire rst_10mhz_ext;
wire rst_250mhz_ext;

// clock management
wire clk_250mhz_int_dcm_reset;
wire clk_250mhz_int_dcm_locked;
wire [7:0] clk_250mhz_int_dcm_status;
wire clk_250mhz_int_dcm_clkfx_stopped = clk_250mhz_int_dcm_status[1];

wire clk_250mhz_ext_dcm_reset;
wire clk_250mhz_ext_dcm_locked;
wire [7:0] clk_250mhz_ext_dcm_status;
wire clk_250mhz_ext_dcm_clkfx_stopped = clk_250mhz_ext_dcm_status[1];

wire clk_250mhz_out_dcm_reset;
wire clk_250mhz_out_dcm_locked;
wire [7:0] clk_250mhz_out_dcm_status;
wire clk_250mhz_out_dcm_clkin_stopped = clk_250mhz_out_dcm_status[1];
wire clk_250mhz_out_dcm_clkfx_stopped = clk_250mhz_out_dcm_status[2];

wire ref_freq_valid;

wire clk_out_select;

assign ext_clock_selected = clk_out_select;

reg reset_output = 0;

// reset logic

// 10mhz_int clock domain reset
reset_stretch #(.N(4)) rst_10mhz_int_inst (
    .clk(clk_10mhz_int_bufg),
    .rst_in(reset_in),
    .rst_out(rst_10mhz_int)
);

// 10mhz_ext clock domain reset
reset_stretch #(.N(4)) rst_10mhz_ext_inst (
    .clk(clk_10mhz_ext_bufg),
    .rst_in(reset_in | ~ref_freq_valid),
    .rst_out(rst_10mhz_ext)
);

// 250mhz_int clock domain reset
reset_stretch #(.N(4)) rst_250mhz_int_inst (
    .clk(clk_250mhz_int),
    .rst_in(rst_10mhz_int | ~clk_250mhz_int_dcm_locked | clk_250mhz_int_dcm_clkfx_stopped),
    .rst_out(rst_250mhz_int)
);

reset_stretch #(.N(3)) rst_250mhz_int_dcm_inst (
    .clk(clk_10mhz_int_bufg),
    .rst_in(rst_10mhz_int | (~clk_250mhz_int_dcm_locked & clk_250mhz_int_dcm_clkfx_stopped) | clk_250mhz_int_dcm_clkfx_stopped),
    .rst_out(clk_250mhz_int_dcm_reset)
);

// 250mhz_ext clock domain reset
reset_stretch #(.N(4)) rst_250mhz_ext_inst (
    .clk(clk_250mhz_ext),
    .rst_in(rst_10mhz_ext | ~clk_250mhz_ext_dcm_locked | clk_250mhz_ext_dcm_clkfx_stopped),
    .rst_out(rst_250mhz_ext)
);

reset_stretch #(.N(3)) rst_250mhz_ext_dcm_inst (
    .clk(clk_10mhz_ext_bufg),
    .rst_in(rst_10mhz_ext | (~clk_250mhz_ext_dcm_locked & clk_250mhz_ext_dcm_clkfx_stopped) | clk_250mhz_ext_dcm_clkfx_stopped),
    .rst_out(clk_250mhz_ext_dcm_reset)
);

// 250mhz_out clock domain reset
reset_stretch #(.N(4)) rst_250mhz_inst (
    .clk(clk_250mhz),
    .rst_in((clk_out_select ? rst_250mhz_ext : rst_250mhz_int) | reset_output),
    .rst_out(rst_250mhz)
);

// Source switching logic
reg ref_clk_src_reg = 0;
reg [2:0] ref_clk_sync_reg = 0;
reg [2:0] rst_250mhz_ext_sync_reg = 0;
reg ref_clk_reg = 0;
reg ref_clk_last_reg = 0;
reg [7:0] ref_freq_gate_reg = 0;
reg [7:0] ref_freq_count_reg = 0;
reg [6:0] ref_freq_valid_count_reg = 0;
reg ref_freq_valid_reg = 0;

assign ref_freq_valid = ref_freq_valid_reg;

reg clk_out_select_reg = 0;

assign clk_out_select = clk_out_select_reg;

always @(posedge clk_10mhz_ext_bufg) begin
    ref_clk_src_reg <= ~ref_clk_src_reg;
end

always @(posedge clk_250mhz_int) begin
    ref_clk_sync_reg <= {ref_clk_sync_reg[1:0], ref_clk_src_reg};
    rst_250mhz_ext_sync_reg <= {rst_250mhz_ext_sync_reg[1:0], rst_250mhz_ext};
end

always @(posedge clk_250mhz_int or posedge rst_250mhz_int) begin
    if (rst_250mhz_int) begin
        // reset
        ref_clk_reg <= 0;
        ref_clk_last_reg <= 0;
        ref_freq_gate_reg <= 0;
        ref_freq_count_reg <= 0;
        ref_freq_valid_count_reg <= 0;
        ref_freq_valid_reg <= 0;
        reset_output <= 0;
    end else begin
        ref_clk_reg <= ref_clk_sync_reg[2];
        ref_clk_last_reg <= ref_clk_reg;

        ref_freq_gate_reg <= ref_freq_gate_reg + 1;

        // measure edge rate of reference signal
        // count edges
        if (ref_clk_reg ^ ref_clk_last_reg) begin
            ref_freq_count_reg <= ref_freq_count_reg + 1;
        end

        // gate every 256 cycles and check edge count
        if (ref_freq_gate_reg == 0) begin
            ref_freq_count_reg <= 0;

            // 10 MHz should be 10.24 cycles, allow one cycle window
            // 4 us (250 MHz) * 256 (gate) / 100 us (10 MHz) = 10.24 cycles
            if (ref_freq_count_reg >= 8 & ref_freq_count_reg <= 12) begin
                if (&ref_freq_valid_count_reg) begin
                    ref_freq_valid_reg <= 1;
                end else begin
                    ref_freq_valid_count_reg <= ref_freq_valid_count_reg + 1;
                end
            end else begin
                ref_freq_valid_count_reg <= 0;
                ref_freq_valid_reg <= 0;
            end
        end

        reset_output <= 0;

        if (ref_freq_valid_reg) begin
            if (~rst_250mhz_ext_sync_reg[2]) begin
                clk_out_select_reg <= 1;
                reset_output <= ~clk_out_select_reg;
            end
        end else begin
            clk_out_select_reg <= 0;
            reset_output <= clk_out_select_reg;
        end
    end
end

// clock management components

// input clock buffers
IBUFG
clk_10mhz_int_ibufg_inst
(
    .I(clk_10mhz_int),
    .O(clk_10mhz_int_ibufg)
);

BUFG
clk_10mhz_int_bufg_inst
(
    .I(clk_10mhz_int_ibufg),
    .O(clk_10mhz_int_bufg)
);

IBUFG
clk_10mhz_ext_ibufg_inst
(
    .I(clk_10mhz_ext),
    .O(clk_10mhz_ext_ibufg)
);

BUFG
clk_10mhz_ext_bufg_inst
(
    .I(clk_10mhz_ext_ibufg),
    .O(clk_10mhz_ext_bufg)
);

// DCMs to convert input clocks to 250 MHz
DCM_CLKGEN #
(
    .CLKFXDV_DIVIDE        (2),
    .CLKFX_DIVIDE          (1),
    .CLKFX_MULTIPLY        (25),
    .SPREAD_SPECTRUM       ("NONE"),
    .STARTUP_WAIT          ("FALSE"),
    .CLKIN_PERIOD          (100.0),
    .CLKFX_MD_MAX          (0.000)
)
clk_10mhz_int_dcm_clkgen_inst
(
    .CLKIN                 (clk_10mhz_int_ibufg),
    .CLKFX                 (clk_250mhz_int_dcm),
    .CLKFX180              (),
    .CLKFXDV               (),
    .PROGCLK               (1'b0),
    .PROGDATA              (1'b0),
    .PROGEN                (1'b0),
    .PROGDONE              (),
    .FREEZEDCM             (1'b0),
    .LOCKED                (clk_250mhz_int_dcm_locked),
    .STATUS                (clk_250mhz_int_dcm_status),
    .RST                   (clk_250mhz_int_dcm_reset)
);

DCM_CLKGEN #
(
    .CLKFXDV_DIVIDE        (2),
    .CLKFX_DIVIDE          (1),
    .CLKFX_MULTIPLY        (25),
    .SPREAD_SPECTRUM       ("NONE"),
    .STARTUP_WAIT          ("FALSE"),
    .CLKIN_PERIOD          (100.0),
    .CLKFX_MD_MAX          (0.000)
)
clk_10mhz_ext_dcm_clkgen_inst
(
    .CLKIN                 (clk_10mhz_ext_ibufg),
    .CLKFX                 (clk_250mhz_ext_dcm),
    .CLKFX180              (),
    .CLKFXDV               (),
    .PROGCLK               (1'b0),
    .PROGDATA              (1'b0),
    .PROGEN                (1'b0),
    .PROGDONE              (),
    .FREEZEDCM             (1'b0),
    .LOCKED                (clk_250mhz_ext_dcm_locked),
    .STATUS                (clk_250mhz_ext_dcm_status),
    .RST                   (clk_250mhz_ext_dcm_reset)
);

// Buffers for 250 MHz internal clock
BUFG
clk_250mhz_int_bufg_inst
(
    .I(clk_250mhz_int_dcm),
    .O(clk_250mhz_int)
);

BUFG
clk_250mhz_ext_bufg_inst
(
    .I(clk_250mhz_ext_dcm),
    .O(clk_250mhz_ext)
);

// Clock mux for reference selection
BUFGMUX #
(
    .CLK_SEL_TYPE("ASYNC")
)
clk_250mhz_bufgmux_inst
(
    .I0(clk_250mhz_int_dcm),
    .I1(clk_250mhz_ext_dcm),
    .S(clk_out_select),
    .O(clk_250mhz)
);

endmodule
