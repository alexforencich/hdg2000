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
    // 10 MHz reference clock inputs
    // clk_10mhz_int is internal failsafe clock
    // clk_10mhz_ext is external accurate clock (preferred)
    input wire clk_10mhz_int,
    input wire clk_10mhz_ext,

    // 250 MHz clocks from DCMs
    output wire clk_250mhz_int,
    output wire clk_250mhz_ext,

    // 250 MHz and 10 MHz clocks from PLL
    output wire clk_250mhz,
    output wire clk_10mhz,

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
       __V__________________V__                      |
       \______________________/ <--------------------+
                  |
                  V
         ,-------PLL--------,
         |                  |
     clk_250mhz         clk_10mhz


*/

wire clk_10mhz_int_ibufg;
wire clk_10mhz_ext_ibufg;

wire clk_250mhz_int_dcm;
wire clk_250mhz_ext_dcm;

wire dcm_int_reset = 0;
wire dcm_int_locked;
wire [7:0] dcm_int_status;
//wire dcm_int_stopped = 

wire dcm_ext_reset = 0;
wire dcm_ext_locked;
wire [7:0] dcm_ext_status;

wire clk_250mhz_to_pll;
wire clk_250mhz_pll;
wire clk_10mhz_pll;

wire pll_clkfb;
wire pll_reset = 0;
wire pll_locked;
wire pll_clk_sel = 0;

wire clk_out_enable = 1;

// input clock buffers
IBUFG
clk_10mhz_int_ibufg_inst
(
    .I(clk_10mhz_int),
    .O(clk_10mhz_int_ibufg)
);

IBUFG
clk_10mhz_ext_ibufg_inst
(
    .I(clk_10mhz_ext),
    .O(clk_10mhz_ext_ibufg)
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
    .CLKFB                 (),
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
    .LOCKED                (dcm_int_locked),
    .STATUS                (dcm_int_status),
    .RST                   (dcm_int_reset),
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
    .CLKFB                 (),
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
    .LOCKED                (dcm_locked_ext),
    .STATUS                (dcm_status_ext),
    .RST                   (dcm_reset_ext),
    .DSSEN                 (1'b0)
);

// Buffers for 250 MHz clocks
// ext buffer may be optimized away (it is not used in this module)
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

// Clock mux for PLL reference clock
BUFGMUX
clk_250mhz_to_pll_inst
(
    .I0(clk_250mhz_int_dcm),
    .I1(clk_250mhz_ext_dcm),
    .S(pll_clk_sel),
    .O(clk_250mhz_to_pll)
);

// PLL for jitter attenuation and 10 MHz output generation
PLL_ADV #
(
    .BANDWIDTH          ("OPTIMIZED"),
    .CLKIN1_PERIOD      (4.0),
    .CLKIN2_PERIOD      (4.0),
    .CLKOUT0_DIVIDE     (2),
    .CLKOUT1_DIVIDE     (50),
    .CLKOUT2_DIVIDE     (1),
    .CLKOUT3_DIVIDE     (1),
    .CLKOUT4_DIVIDE     (1),
    .CLKOUT5_DIVIDE     (1),
    .CLKOUT0_PHASE      (0.000),
    .CLKOUT1_PHASE      (0.000),
    .CLKOUT2_PHASE      (0.000),
    .CLKOUT3_PHASE      (0.000),
    .CLKOUT4_PHASE      (0.000),
    .CLKOUT5_PHASE      (0.000),
    .CLKOUT0_DUTY_CYCLE (0.500),
    .CLKOUT1_DUTY_CYCLE (0.500),
    .CLKOUT2_DUTY_CYCLE (0.500),
    .CLKOUT3_DUTY_CYCLE (0.500),
    .CLKOUT4_DUTY_CYCLE (0.500),
    .CLKOUT5_DUTY_CYCLE (0.500),
    .SIM_DEVICE         ("SPARTAN6"),
    .COMPENSATION       ("INTERNAL"),
    .DIVCLK_DIVIDE      (1),
    .CLKFBOUT_MULT      (2),
    .CLKFBOUT_PHASE     (0.0),
    .REF_JITTER         (0.005000)
)    
clk_250mhz_pll_inst
(
    .CLKFBIN     (pll_clkfb),
    .CLKINSEL    (1'b1),
    .CLKIN1      (clk_250mhz_to_pll),
    .CLKIN2      (1'b0),
    .DADDR       (5'b0),
    .DCLK        (1'b0),
    .DEN         (1'b0),
    .DI          (16'b0),
    .DWE         (1'b0),
    .REL         (1'b0),
    .RST         (pll_reset),
    .CLKFBDCM    (),
    .CLKFBOUT    (pll_clkfb),
    .CLKOUTDCM0  (),
    .CLKOUTDCM1  (),
    .CLKOUTDCM2  (),
    .CLKOUTDCM3  (),
    .CLKOUTDCM4  (),
    .CLKOUTDCM5  (),
    .CLKOUT0     (clk_250mhz_pll),
    .CLKOUT1     (clk_10mhz_pll),
    .CLKOUT2     (),
    .CLKOUT3     (),
    .CLKOUT4     (),
    .CLKOUT5     (),
    .DO          (),
    .DRDY        (),
    .LOCKED      (pll_locked)
);

BUFGCE
clk_250mhz_bufg_inst
(
    .I(clk_250mhz_pll),
    .CE(clk_out_enable),
    .O(clk_250mhz)
);

BUFGCE
clk_10mhz_bufg_inst
(
    .I(clk_10mhz_pll),
    .CE(clk_out_enable),
    .O(clk_10mhz)
);

endmodule
