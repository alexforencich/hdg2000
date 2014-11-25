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
 * Clock generation for DDR2 MCB
 */
module ddr2_clock
(
    // 250 MHz clock and reset
    input wire clk_250mhz,
    input wire rst_250mhz,

    // Output clocks to MCB
    output wire mcb_clk_0,
    output wire mcb_clk_180,
    output wire mcb_drp_clk,
    output wire mcb_clk_locked
);

wire clkfb;

wire mcb_clk_0_int;
wire mcb_clk_180_int;
wire mcb_drp_clk_int;

// input is 250 MHz
// output0/1 are 250 MHz * 5 / 2 = 625 MHz (MCB 2x clock)
// output2 is 625 MHz / 10 = 62.5 MHz (MCB DRP clock)
PLL_ADV #
(
    .BANDWIDTH             ("OPTIMIZED"),
    .CLKIN1_PERIOD         (4.000),
    .CLKIN2_PERIOD         (4.000),
    .CLKOUT0_DIVIDE        (1),
    .CLKOUT1_DIVIDE        (1),
    .CLKOUT2_DIVIDE        (10),
    .CLKOUT3_DIVIDE        (1),
    .CLKOUT4_DIVIDE        (1),
    .CLKOUT5_DIVIDE        (1),
    .CLKOUT0_PHASE         (0.000),
    .CLKOUT1_PHASE         (180.000),
    .CLKOUT2_PHASE         (0.000),
    .CLKOUT3_PHASE         (0.000),
    .CLKOUT4_PHASE         (0.000),
    .CLKOUT5_PHASE         (0.000),
    .CLKOUT0_DUTY_CYCLE    (0.500),
    .CLKOUT1_DUTY_CYCLE    (0.500),
    .CLKOUT2_DUTY_CYCLE    (0.500),
    .CLKOUT3_DUTY_CYCLE    (0.500),
    .CLKOUT4_DUTY_CYCLE    (0.500),
    .CLKOUT5_DUTY_CYCLE    (0.500),
    .SIM_DEVICE            ("SPARTAN6"),
    .COMPENSATION          ("INTERNAL"),
    .DIVCLK_DIVIDE         (2),
    .CLKFBOUT_MULT         (5),
    .CLKFBOUT_PHASE        (0.0),
    .REF_JITTER            (0.025000)
)
mcb_pll
(
    .CLKFBIN               (clkfb),
    .CLKINSEL              (1'b1),
    .CLKIN1                (clk_250mhz),
    .CLKIN2                (1'b0),
    .DADDR                 (5'b0),
    .DCLK                  (1'b0),
    .DEN                   (1'b0),
    .DI                    (16'b0),
    .DWE                   (1'b0),
    .REL                   (1'b0),
    .RST                   (rst_250mhz),
    .CLKFBDCM              (),
    .CLKFBOUT              (clkfb),
    .CLKOUTDCM0            (),
    .CLKOUTDCM1            (),
    .CLKOUTDCM2            (),
    .CLKOUTDCM3            (),
    .CLKOUTDCM4            (),
    .CLKOUTDCM5            (),
    .CLKOUT0               (mcb_clk_0),
    .CLKOUT1               (mcb_clk_180),
    .CLKOUT2               (mcb_drp_clk_int),
    .CLKOUT3               (),
    .CLKOUT4               (),
    .CLKOUT5               (),
    .DO                    (),
    .DRDY                  (),
    .LOCKED                (mcb_clk_locked)
);

BUFGCE
mcb_drp_clk_bufg_inst
(
    .I(mcb_drp_clk_int),
    .O(mcb_drp_clk),
    .CE(mcb_clk_locked)
);

endmodule
