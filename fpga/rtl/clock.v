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
    output wire clk_10mhz,
    output wire rst_250mhz,
    output wire rst_10mhz,

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
               DCM                DCM                       |
                |                  |                        |
          clk_250mhz_int     clk_250mhz_ext                 |
                |                  |                        |
    Logic  <----+                  |                        |
    DDR2        |                  |                        |
              __V__________________V__                      |
              \______________________/ <--------------------+
                         |
                         V
                ,-------DCM--------,
                |                  |
            clk_250mhz         clk_10mhz


*/


// clocks
wire clk_10mhz_int_ibufg;
wire clk_10mhz_int_bufg;
wire clk_10mhz_ext_ibufg;
wire clk_10mhz_ext_bufg;

wire clk_250mhz_int_dcm;
wire clk_250mhz_ext_dcm;

wire clk_250mhz_to_dcm;
wire clk_250mhz_out;
wire clk_10mhz_out;

// resets
reg rst_10mhz_int_reg = 1;
reg rst_250mhz_int_reg = 1;
reg rst_250mhz_out_reg = 1;
reg rst_10mhz_out_reg = 1;

// clock management
wire clk_250mhz_int_dcm_reset;
wire clk_250mhz_int_dcm_locked;
wire [7:0] clk_250mhz_int_dcm_status;
wire clk_250mhz_int_dcm_stopped = clk_250mhz_int_dcm_status[1];

wire clk_250mhz_ext_dcm_reset;
wire clk_250mhz_ext_dcm_locked;
wire [7:0] clk_250mhz_ext_dcm_status;
wire clk_250mhz_ext_dcm_stopped = clk_250mhz_ext_dcm_status[1];

wire clk_250mhz_out_dcm_reset;
wire clk_250mhz_out_dcm_locked;
wire [7:0] clk_250mhz_out_dcm_status;
wire clk_250mhz_out_dcm_stopped = clk_250mhz_out_dcm_status[1];

reg clk_out_select = 0;

// reset logic

// 10mhz_int clock domain reset
reg [3:0] rst_10mhz_int_count_reg = 0;

// hold reset for 16 clock cyles
always @(posedge clk_10mhz_int_bufg or posedge reset_in) begin
    if (reset_in) begin
        // reset
        rst_10mhz_int_count_reg <= 0;
        rst_10mhz_int_reg <= 1;
    end else begin
        if (&rst_10mhz_int_count_reg) begin
            rst_10mhz_int_reg <= 0;
        end else begin
            rst_10mhz_int_reg <= 1;
            rst_10mhz_int_count_reg <= rst_10mhz_int_count_reg + 1;
        end
    end
end

// 250mhz_int clock domain reset
reg [3:0] rst_250mhz_int_count_reg = 0;
// reset 250mhz_int clock domain if parent clock domain is in reset or DCM is not locked input clock is stopped
wire rst_250mhz_int_in = rst_10mhz_int_reg | ~clk_250mhz_int_dcm_locked | clk_250mhz_int_dcm_stopped;
// reset 250mhz_int DCM if parent clock domain is in reset or DCM is not locked and input clock is stopped
assign clk_250mhz_int_dcm_reset = rst_10mhz_int_reg | (~clk_250mhz_int_dcm_locked & clk_250mhz_int_dcm_stopped);

assign rst_250mhz_int = rst_250mhz_int_reg;

// hold reset for 16 clock cyles
always @(posedge clk_250mhz_int or posedge rst_250mhz_int_in) begin
    if (rst_250mhz_int_in) begin
        // reset
        rst_250mhz_int_count_reg <= 0;
        rst_250mhz_int_reg <= 1;
    end else begin
        if (&rst_250mhz_int_count_reg) begin
            rst_250mhz_int_reg <= 0;
        end else begin
            rst_250mhz_int_reg <= 1;
            rst_250mhz_int_count_reg <= rst_250mhz_int_count_reg + 1;
        end
    end
end

// 250mhz_ext clock domain reset
// reg [15:0] rst_250mhz_ext_count_reg = 0;
// // reset 250mhz_ext clock domain if parent clock domain is in reset or DCM is not locked input clock is stopped
// wire rst_250mhz_ext_in = rst_10mhz_ext_reg | ~clk_250mhz_ext_dcm_locked | clk_250mhz_ext_dcm_stopped;
// reset 250mhz_ext DCM if parent clock domain is in reset or DCM is not locked and input clock is stopped
assign clk_250mhz_ext_dcm_reset = rst_10mhz_int_reg | (~clk_250mhz_ext_dcm_locked & clk_250mhz_ext_dcm_stopped);

// // hold reset for 16 clock cyles
// always @(posedge clk_250mhz_ext or posedge rst_250mhz_ext_in) begin
//     if (rst_250mhz_ext_in) begin
//         // reset
//         rst_250mhz_ext_reg <= 1;
//         rst_250mhz_ext_count_reg <= 0;
//     end else begin
//         if (&rst_250mhz_ext_count_reg) begin
//             rst_250mhz_ext_reg <= 0;
//         end else begin
//             rst_250mhz_ext_reg <= 1;
//             rst_250mhz_ext_count_reg <= rst_250mhz_ext_count_reg + 1;
//         end
//     end
// end

// 250mhz_out clock domain reset
reg [3:0] rst_250mhz_out_count_reg = 0;
// reset 250mhz_out clock domain if parent clock domain is in reset or DCM is not locked input clock is stopped
// TODO parent reset mux
wire rst_250mhz_out_in = rst_250mhz_int_reg | ~clk_250mhz_out_dcm_locked | clk_250mhz_out_dcm_stopped;
// reset 250mhz_out DCM if parent clock domain is in reset or DCM is not locked and input clock is stopped
assign clk_250mhz_out_dcm_reset = rst_250mhz_int_reg | (~clk_250mhz_out_dcm_locked & clk_250mhz_out_dcm_stopped);

assign rst_250mhz = rst_250mhz_out_reg;

// hold reset for 16 clock cyles
always @(posedge clk_250mhz_out or posedge rst_250mhz_out_in) begin
    if (rst_250mhz_out_in) begin
        // reset
        rst_250mhz_out_count_reg <= 0;
        rst_250mhz_out_reg <= 1;
    end else begin
        if (&rst_250mhz_out_count_reg) begin
            rst_250mhz_out_reg <= 0;
        end else begin
            rst_250mhz_out_reg <= 1;
            rst_250mhz_out_count_reg <= rst_250mhz_out_count_reg + 1;
        end
    end
end

// 10mhz clock domain reset
reg [3:0] rst_10mhz_out_count_reg = 0;

assign rst_10mhz = rst_10mhz_out_reg;

// hold reset for 16 clock cyles
always @(posedge clk_10mhz_out or posedge rst_250mhz_out_in) begin
    if (rst_250mhz_out_in) begin
        // reset
        rst_10mhz_out_count_reg <= 0;
        rst_10mhz_out_reg <= 1;
    end else begin
        if (&rst_10mhz_out_count_reg) begin
            rst_10mhz_out_reg <= 0;
        end else begin
            rst_10mhz_out_reg <= 1;
            rst_10mhz_out_count_reg <= rst_10mhz_out_count_reg + 1;
        end
    end
end


// Source switching logic
// TODO


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
DCM_SP #
(
    .CLKDV_DIVIDE          (2.000),
    .CLKFX_DIVIDE          (1),
    .CLKFX_MULTIPLY        (25),
    .CLKIN_DIVIDE_BY_2     ("FALSE"),
    .CLKIN_PERIOD          (100.0),
    .CLKOUT_PHASE_SHIFT    ("NONE"),
    .CLK_FEEDBACK          ("NONE"),
    .DESKEW_ADJUST         ("SYSTEM_SYNCHRONOUS"),
    .PHASE_SHIFT           (0),
    .STARTUP_WAIT          ("FALSE")
)
clk_10mhz_int_dcm_sp_inst
(
    .CLKIN                 (clk_10mhz_int_ibufg),
    .CLKFB                 (1'b0),
    .CLK0                  (),
    .CLK90                 (),
    .CLK180                (),
    .CLK270                (),
    .CLK2X                 (),
    .CLK2X180              (),
    .CLKFX                 (clk_250mhz_int_dcm),
    .CLKFX180              (),
    .CLKDV                 (),
    .PSCLK                 (1'b0),
    .PSEN                  (1'b0),
    .PSINCDEC              (1'b0),
    .PSDONE                (),
    .LOCKED                (clk_250mhz_int_dcm_locked),
    .STATUS                (clk_250mhz_int_dcm_status),
    .RST                   (clk_250mhz_int_dcm_reset),
    .DSSEN                 (1'b0)
);

DCM_SP #
(
    .CLKDV_DIVIDE          (2.000),
    .CLKFX_DIVIDE          (1),
    .CLKFX_MULTIPLY        (25),
    .CLKIN_DIVIDE_BY_2     ("FALSE"),
    .CLKIN_PERIOD          (100.0),
    .CLKOUT_PHASE_SHIFT    ("NONE"),
    .CLK_FEEDBACK          ("NONE"),
    .DESKEW_ADJUST         ("SYSTEM_SYNCHRONOUS"),
    .PHASE_SHIFT           (0),
    .STARTUP_WAIT          ("FALSE")
)
clk_10mhz_ext_dcm_sp_inst
(
    .CLKIN                 (clk_10mhz_ext_ibufg),
    .CLKFB                 (1'b0),
    .CLK0                  (),
    .CLK90                 (),
    .CLK180                (),
    .CLK270                (),
    .CLK2X                 (),
    .CLK2X180              (),
    .CLKFX                 (clk_250mhz_ext_dcm),
    .CLKFX180              (),
    .CLKDV                 (),
    .PSCLK                 (1'b0),
    .PSEN                  (1'b0),
    .PSINCDEC              (1'b0),
    .PSDONE                (),
    .LOCKED                (clk_250mhz_ext_dcm_locked),
    .STATUS                (clk_250mhz_ext_dcm_status),
    .RST                   (clk_250mhz_ext_dcm_reset),
    .DSSEN                 (1'b0)
);

// Buffers for 250 MHz internal clock
BUFG
clk_250mhz_int_bufg_inst
(
    .I(clk_250mhz_int_dcm),
    .O(clk_250mhz_int)
);

// Clock mux for reference selection
BUFGMUX
clk_250mhz_to_pll_inst
(
    .I0(clk_250mhz_int_dcm),
    .I1(clk_250mhz_ext_dcm),
    .S(clk_out_select),
    .O(clk_250mhz_to_dcm)
);

// DCM to generate 10 MHz output
// CLKFX and CLKDV coefficient range insufficient without input divide by 2
// After divide by 2, get original clock from CLK2X and 1/25 from CLKFX 2/25
DCM_SP #
(
    .CLKDV_DIVIDE          (2.000),
    .CLKFX_DIVIDE          (25),
    .CLKFX_MULTIPLY        (2),
    .CLKIN_DIVIDE_BY_2     ("TRUE"),
    .CLKIN_PERIOD          (4.0),
    .CLKOUT_PHASE_SHIFT    ("NONE"),
    .CLK_FEEDBACK          ("2X"),
    .DESKEW_ADJUST         ("SYSTEM_SYNCHRONOUS"),
    .PHASE_SHIFT           (0),
    .STARTUP_WAIT          ("FALSE")
)
clk_250mhz_out_dcm_sp_inst
(
    .CLKIN                 (clk_250mhz_to_dcm),
    .CLKFB                 (clk_250mhz),
    .CLK0                  (),
    .CLK90                 (),
    .CLK180                (),
    .CLK270                (),
    .CLK2X                 (clk_250mhz_out),
    .CLK2X180              (),
    .CLKFX                 (clk_10mhz_out),
    .CLKFX180              (),
    .CLKDV                 (),
    .PSCLK                 (1'b0),
    .PSEN                  (1'b0),
    .PSINCDEC              (1'b0),
    .PSDONE                (),
    .LOCKED                (clk_250mhz_out_dcm_locked),
    .STATUS                (clk_250mhz_out_dcm_status),
    .RST                   (clk_250mhz_out_dcm_reset),
    .DSSEN                 (1'b0)
);

BUFG
clk_250mhz_bufg_inst
(
    .I(clk_250mhz_out),
    .O(clk_250mhz)
);

BUFG
clk_10mhz_bufg_inst
(
    .I(clk_10mhz_out),
    .O(clk_10mhz)
);

endmodule
