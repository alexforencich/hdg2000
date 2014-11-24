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
 * DDR2 memory controller block
 */
module ddr2 #(
    parameter P0_MASK_SIZE           = 4,
    parameter P0_DATA_PORT_SIZE      = 32,
    parameter P1_MASK_SIZE           = 4,
    parameter P1_DATA_PORT_SIZE      = 32,
    parameter MEMCLK_PERIOD          = 3200,
                                       // Memory data transfer clock period
    parameter CALIB_SOFT_IP          = "TRUE",
                                       // # = TRUE, Enables the soft calibration logic,
                                       // # = FALSE, Disables the soft calibration logic.
    parameter SIMULATION             = "FALSE",
                                       // # = TRUE, Simulating the design. Useful to reduce the simulation time,
                                       // # = FALSE, Implementing the design.
    parameter MEM_ADDR_ORDER         = "ROW_BANK_COLUMN",
                                       // The order in which user address is provided to the memory controller,
                                       // ROW_BANK_COLUMN or BANK_ROW_COLUMN
    parameter NUM_DQ_PINS            = 16,
                                       // External memory data width
    parameter MEM_ADDR_WIDTH         = 13,
                                       // External memory address width
    parameter MEM_BANKADDR_WIDTH     = 3
                                       // External memory bank address width
)
(
    // clock and reset
    input  wire async_rst,
    input  wire mcb_clk_0,
    input  wire mcb_clk_180,
    input  wire mcb_drp_clk,
    input  wire mcb_clk_locked,

    // Calibration status
    output wire calib_done,

    // DDR2 DRAM connection
    output wire [MEM_ADDR_WIDTH-1:0]     mcbx_dram_a,
    output wire [MEM_BANKADDR_WIDTH-1:0] mcbx_dram_ba,
    output wire                          mcbx_dram_ras_n,
    output wire                          mcbx_dram_cas_n,
    output wire                          mcbx_dram_we_n,
    output wire                          mcbx_dram_cke,
    output wire                          mcbx_dram_ck,
    output wire                          mcbx_dram_ck_n,
    inout  wire [NUM_DQ_PINS-1:0]        mcbx_dram_dq,
    inout  wire                          mcbx_dram_dqs,
    inout  wire                          mcbx_dram_dqs_n,
    inout  wire                          mcbx_dram_udqs,
    inout  wire                          mcbx_dram_udqs_n,
    output wire                          mcbx_dram_udm,
    output wire                          mcbx_dram_dm,
    output wire                          mcbx_dram_odt,
    inout  wire                          mcbx_rzq,
    inout  wire                          mcbx_zio,

    // MCB ports
    // port 0
    input  wire                          p0_cmd_clk,
    input  wire                          p0_cmd_en,
    input  wire [2:0]                    p0_cmd_instr,
    input  wire [5:0]                    p0_cmd_bl,
    input  wire [29:0]                   p0_cmd_byte_addr,
    output wire                          p0_cmd_empty,
    output wire                          p0_cmd_full,
    input  wire                          p0_wr_clk,
    input  wire                          p0_wr_en,
    input  wire [P0_MASK_SIZE-1:0]       p0_wr_mask,
    input  wire [P0_DATA_PORT_SIZE-1:0]  p0_wr_data,
    output wire                          p0_wr_empty,
    output wire                          p0_wr_full,
    output wire                          p0_wr_underrun,
    output wire [6:0]                    p0_wr_count,
    output wire                          p0_wr_error,
    input  wire                          p0_rd_clk,
    input  wire                          p0_rd_en,
    output wire [P0_DATA_PORT_SIZE-1:0]  p0_rd_data,
    output wire                          p0_rd_empty,
    output wire                          p0_rd_full,
    output wire                          p0_rd_overflow,
    output wire [6:0]                    p0_rd_count,
    output wire                          p0_rd_error,
    // port 1
    input  wire                          p1_cmd_clk,
    input  wire                          p1_cmd_en,
    input  wire [2:0]                    p1_cmd_instr,
    input  wire [5:0]                    p1_cmd_bl,
    input  wire [29:0]                   p1_cmd_byte_addr,
    output wire                          p1_cmd_empty,
    output wire                          p1_cmd_full,
    input  wire                          p1_wr_clk,
    input  wire                          p1_wr_en,
    input  wire [P1_MASK_SIZE-1:0]       p1_wr_mask,
    input  wire [P1_DATA_PORT_SIZE-1:0]  p1_wr_data,
    output wire                          p1_wr_empty,
    output wire                          p1_wr_full,
    output wire                          p1_wr_underrun,
    output wire [6:0]                    p1_wr_count,
    output wire                          p1_wr_error,
    input  wire                          p1_rd_clk,
    input  wire                          p1_rd_en,
    output wire [P1_DATA_PORT_SIZE-1:0]  p1_rd_data,
    output wire                          p1_rd_empty,
    output wire                          p1_rd_full,
    output wire                          p1_rd_overflow,
    output wire [6:0]                    p1_rd_count,
    output wire                          p1_rd_error,
    // port 2
    input  wire                          p2_cmd_clk,
    input  wire                          p2_cmd_en,
    input  wire [2:0]                    p2_cmd_instr,
    input  wire [5:0]                    p2_cmd_bl,
    input  wire [29:0]                   p2_cmd_byte_addr,
    output wire                          p2_cmd_empty,
    output wire                          p2_cmd_full,
    input  wire                          p2_rd_clk,
    input  wire                          p2_rd_en,
    output wire [31:0]                   p2_rd_data,
    output wire                          p2_rd_empty,
    output wire                          p2_rd_full,
    output wire                          p2_rd_overflow,
    output wire [6:0]                    p2_rd_count,
    output wire                          p2_rd_error,
    // port 3
    input  wire                          p3_cmd_clk,
    input  wire                          p3_cmd_en,
    input  wire [2:0]                    p3_cmd_instr,
    input  wire [5:0]                    p3_cmd_bl,
    input  wire [29:0]                   p3_cmd_byte_addr,
    output wire                          p3_cmd_empty,
    output wire                          p3_cmd_full,
    input  wire                          p3_rd_clk,
    input  wire                          p3_rd_en,
    output wire [31:0]                   p3_rd_data,
    output wire                          p3_rd_empty,
    output wire                          p3_rd_full,
    output wire                          p3_rd_overflow,
    output wire [6:0]                    p3_rd_count,
    output wire                          p3_rd_error,
    // port 4
    input  wire                          p4_cmd_clk,
    input  wire                          p4_cmd_en,
    input  wire [2:0]                    p4_cmd_instr,
    input  wire [5:0]                    p4_cmd_bl,
    input  wire [29:0]                   p4_cmd_byte_addr,
    output wire                          p4_cmd_empty,
    output wire                          p4_cmd_full,
    input  wire                          p4_rd_clk,
    input  wire                          p4_rd_en,
    output wire [31:0]                   p4_rd_data,
    output wire                          p4_rd_empty,
    output wire                          p4_rd_full,
    output wire                          p4_rd_overflow,
    output wire [6:0]                    p4_rd_count,
    output wire                          p4_rd_error,
    // port 5
    input  wire                          p5_cmd_clk,
    input  wire                          p5_cmd_en,
    input  wire [2:0]                    p5_cmd_instr,
    input  wire [5:0]                    p5_cmd_bl,
    input  wire [29:0]                   p5_cmd_byte_addr,
    output wire                          p5_cmd_empty,
    output wire                          p5_cmd_full,
    input  wire                          p5_rd_clk,
    input  wire                          p5_rd_en,
    output wire [31:0]                   p5_rd_data,
    output wire                          p5_rd_empty,
    output wire                          p5_rd_full,
    output wire                          p5_rd_overflow,
    output wire [6:0]                    p5_rd_count,
    output wire                          p5_rd_error
);

// The parameter CX_PORT_ENABLE shows all the active user ports in the design.
// For example, the value 6'b111100 tells that only port-2, port-3, port-4
// and port-5 are enabled. The other two ports are inactive. An inactive port
// can be a disabled port or an invisible logical port. Few examples to the
// invisible logical port are port-4 and port-5 in the user port configuration,
// Config-2: Four 32-bit bi-directional ports and the ports port-2 through
// port-5 in Config-4: Two 64-bit bi-directional ports. Please look into the
// Chapter-2 of ug388.pdf in the /docs directory for further details.
localparam PORT_ENABLE              = 6'b111111;
localparam PORT_CONFIG              = "B32_B32_R32_R32_R32_R32";
localparam ARB_ALGORITHM            = 0;
localparam ARB_NUM_TIME_SLOTS       = 12;
localparam ARB_TIME_SLOT_0          = 18'o012345;
localparam ARB_TIME_SLOT_1          = 18'o123450;
localparam ARB_TIME_SLOT_2          = 18'o234501;
localparam ARB_TIME_SLOT_3          = 18'o345012;
localparam ARB_TIME_SLOT_4          = 18'o450123;
localparam ARB_TIME_SLOT_5          = 18'o501234;
localparam ARB_TIME_SLOT_6          = 18'o012345;
localparam ARB_TIME_SLOT_7          = 18'o123450;
localparam ARB_TIME_SLOT_8          = 18'o234501;
localparam ARB_TIME_SLOT_9          = 18'o345012;
localparam ARB_TIME_SLOT_10         = 18'o450123;
localparam ARB_TIME_SLOT_11         = 18'o501234;
localparam MEM_TRAS                 = 42500;
localparam MEM_TRCD                 = 12500;
localparam MEM_TREFI                = 7800000;
localparam MEM_TRFC                 = 127500;
localparam MEM_TRP                  = 12500;
localparam MEM_TWR                  = 15000;
localparam MEM_TRTP                 = 7500;
localparam MEM_TWTR                 = 7500;
localparam MEM_TYPE                 = "DDR2";
localparam MEM_DENSITY              = "1Gb";
localparam MEM_BURST_LEN            = 4;
localparam MEM_CAS_LATENCY          = 5;
localparam MEM_NUM_COL_BITS         = 10;
localparam MEM_DDR1_2_ODS           = "FULL";
localparam MEM_DDR2_RTT             = "50OHMS";
localparam MEM_DDR2_DIFF_DQS_EN     = "YES";
localparam MEM_DDR2_3_PA_SR         = "FULL";
localparam MEM_DDR2_3_HIGH_TEMP_SR  = "NORMAL";
localparam MEM_DDR3_CAS_LATENCY     = 6;
localparam MEM_DDR3_ODS             = "DIV6";
localparam MEM_DDR3_RTT             = "DIV2";
localparam MEM_DDR3_CAS_WR_LATENCY  = 5;
localparam MEM_DDR3_AUTO_SR         = "ENABLED";
localparam MEM_MOBILE_PA_SR         = "FULL";
localparam MEM_MDDR_ODS             = "FULL";
localparam MC_CALIB_BYPASS          = "NO";
localparam MC_CALIBRATION_MODE      = "CALIBRATION";
localparam MC_CALIBRATION_DELAY     = "HALF";
localparam SKIP_IN_TERM_CAL         = 0;
localparam SKIP_DYNAMIC_CAL         = 0;
localparam LDQSP_TAP_DELAY_VAL      = 0;
localparam LDQSN_TAP_DELAY_VAL      = 0;
localparam UDQSP_TAP_DELAY_VAL      = 0;
localparam UDQSN_TAP_DELAY_VAL      = 0;
localparam DQ0_TAP_DELAY_VAL        = 0;
localparam DQ1_TAP_DELAY_VAL        = 0;
localparam DQ2_TAP_DELAY_VAL        = 0;
localparam DQ3_TAP_DELAY_VAL        = 0;
localparam DQ4_TAP_DELAY_VAL        = 0;
localparam DQ5_TAP_DELAY_VAL        = 0;
localparam DQ6_TAP_DELAY_VAL        = 0;
localparam DQ7_TAP_DELAY_VAL        = 0;
localparam DQ8_TAP_DELAY_VAL        = 0;
localparam DQ9_TAP_DELAY_VAL        = 0;
localparam DQ10_TAP_DELAY_VAL       = 0;
localparam DQ11_TAP_DELAY_VAL       = 0;
localparam DQ12_TAP_DELAY_VAL       = 0;
localparam DQ13_TAP_DELAY_VAL       = 0;
localparam DQ14_TAP_DELAY_VAL       = 0;
localparam DQ15_TAP_DELAY_VAL       = 0;
localparam ARB_TIME0_SLOT           = {ARB_TIME_SLOT_0[17:15],  ARB_TIME_SLOT_0[14:12],  ARB_TIME_SLOT_0[11:9],  ARB_TIME_SLOT_0[8:6],  ARB_TIME_SLOT_0[5:3],  ARB_TIME_SLOT_0[2:0]};
localparam ARB_TIME1_SLOT           = {ARB_TIME_SLOT_1[17:15],  ARB_TIME_SLOT_1[14:12],  ARB_TIME_SLOT_1[11:9],  ARB_TIME_SLOT_1[8:6],  ARB_TIME_SLOT_1[5:3],  ARB_TIME_SLOT_1[2:0]};
localparam ARB_TIME2_SLOT           = {ARB_TIME_SLOT_2[17:15],  ARB_TIME_SLOT_2[14:12],  ARB_TIME_SLOT_2[11:9],  ARB_TIME_SLOT_2[8:6],  ARB_TIME_SLOT_2[5:3],  ARB_TIME_SLOT_2[2:0]};
localparam ARB_TIME3_SLOT           = {ARB_TIME_SLOT_3[17:15],  ARB_TIME_SLOT_3[14:12],  ARB_TIME_SLOT_3[11:9],  ARB_TIME_SLOT_3[8:6],  ARB_TIME_SLOT_3[5:3],  ARB_TIME_SLOT_3[2:0]};
localparam ARB_TIME4_SLOT           = {ARB_TIME_SLOT_4[17:15],  ARB_TIME_SLOT_4[14:12],  ARB_TIME_SLOT_4[11:9],  ARB_TIME_SLOT_4[8:6],  ARB_TIME_SLOT_4[5:3],  ARB_TIME_SLOT_4[2:0]};
localparam ARB_TIME5_SLOT           = {ARB_TIME_SLOT_5[17:15],  ARB_TIME_SLOT_5[14:12],  ARB_TIME_SLOT_5[11:9],  ARB_TIME_SLOT_5[8:6],  ARB_TIME_SLOT_5[5:3],  ARB_TIME_SLOT_5[2:0]};
localparam ARB_TIME6_SLOT           = {ARB_TIME_SLOT_6[17:15],  ARB_TIME_SLOT_6[14:12],  ARB_TIME_SLOT_6[11:9],  ARB_TIME_SLOT_6[8:6],  ARB_TIME_SLOT_6[5:3],  ARB_TIME_SLOT_6[2:0]};
localparam ARB_TIME7_SLOT           = {ARB_TIME_SLOT_7[17:15],  ARB_TIME_SLOT_7[14:12],  ARB_TIME_SLOT_7[11:9],  ARB_TIME_SLOT_7[8:6],  ARB_TIME_SLOT_7[5:3],  ARB_TIME_SLOT_7[2:0]};
localparam ARB_TIME8_SLOT           = {ARB_TIME_SLOT_8[17:15],  ARB_TIME_SLOT_8[14:12],  ARB_TIME_SLOT_8[11:9],  ARB_TIME_SLOT_8[8:6],  ARB_TIME_SLOT_8[5:3],  ARB_TIME_SLOT_8[2:0]};
localparam ARB_TIME9_SLOT           = {ARB_TIME_SLOT_9[17:15],  ARB_TIME_SLOT_9[14:12],  ARB_TIME_SLOT_9[11:9],  ARB_TIME_SLOT_9[8:6],  ARB_TIME_SLOT_9[5:3],  ARB_TIME_SLOT_9[2:0]};
localparam ARB_TIME10_SLOT          = {ARB_TIME_SLOT_10[17:15], ARB_TIME_SLOT_10[14:12], ARB_TIME_SLOT_10[11:9], ARB_TIME_SLOT_10[8:6], ARB_TIME_SLOT_10[5:3], ARB_TIME_SLOT_10[2:0]};
localparam ARB_TIME11_SLOT          = {ARB_TIME_SLOT_11[17:15], ARB_TIME_SLOT_11[14:12], ARB_TIME_SLOT_11[11:9], ARB_TIME_SLOT_11[8:6], ARB_TIME_SLOT_11[5:3], ARB_TIME_SLOT_11[2:0]};

// Unused signals
wire        p2_wr_clk;
wire        p2_wr_en;
wire [3:0]  p2_wr_mask;
wire [31:0] p2_wr_data;
wire        p2_wr_full;
wire        p2_wr_empty;
wire [6:0]  p2_wr_count;
wire        p2_wr_underrun;
wire        p2_wr_error;
wire        p3_wr_clk;
wire        p3_wr_en;
wire [3:0]  p3_wr_mask;
wire [31:0] p3_wr_data;
wire        p3_wr_full;
wire        p3_wr_empty;
wire [6:0]  p3_wr_count;
wire        p3_wr_underrun;
wire        p3_wr_error;
wire        p4_wr_clk;
wire        p4_wr_en;
wire [3:0]  p4_wr_mask;
wire [31:0] p4_wr_data;
wire        p4_wr_full;
wire        p4_wr_empty;
wire [6:0]  p4_wr_count;
wire        p4_wr_underrun;
wire        p4_wr_error;
wire        p5_wr_clk;
wire        p5_wr_en;
wire [3:0]  p5_wr_mask;
wire [31:0] p5_wr_data;
wire        p5_wr_full;
wire        p5_wr_empty;
wire [6:0]  p5_wr_count;
wire        p5_wr_underrun;
wire        p5_wr_error;

// BUFPLL_MCB to supply clock to MCB
wire sysclk_2x;
wire sysclk_2x_180;
wire pll_ce_0;
wire pll_ce_90;
wire pll_lock;

BUFPLL_MCB
bufpll_mcb_inst
(
    .GCLK           (mcb_drp_clk),
    .PLLIN0         (mcb_clk_0),
    .PLLIN1         (mcb_clk_180),
    .LOCKED         (mcb_clk_locked),
    .IOCLK0         (sysclk_2x),
    .IOCLK1         (sysclk_2x_180),
    .SERDESSTROBE0  (pll_ce_0),
    .SERDESSTROBE1  (pll_ce_90),
    .LOCK           (pll_lock)
);

// MCB wrapper
memc_wrapper #
(
    .C_MEMCLK_PERIOD                (MEMCLK_PERIOD),
    .C_CALIB_SOFT_IP                (CALIB_SOFT_IP),
    //synthesis translate_off
    .C_SIMULATION                   (SIMULATION),
    //synthesis translate_on
    .C_ARB_NUM_TIME_SLOTS           (ARB_NUM_TIME_SLOTS),
    .C_ARB_TIME_SLOT_0              (ARB_TIME0_SLOT),
    .C_ARB_TIME_SLOT_1              (ARB_TIME1_SLOT),
    .C_ARB_TIME_SLOT_2              (ARB_TIME2_SLOT),
    .C_ARB_TIME_SLOT_3              (ARB_TIME3_SLOT),
    .C_ARB_TIME_SLOT_4              (ARB_TIME4_SLOT),
    .C_ARB_TIME_SLOT_5              (ARB_TIME5_SLOT),
    .C_ARB_TIME_SLOT_6              (ARB_TIME6_SLOT),
    .C_ARB_TIME_SLOT_7              (ARB_TIME7_SLOT),
    .C_ARB_TIME_SLOT_8              (ARB_TIME8_SLOT),
    .C_ARB_TIME_SLOT_9              (ARB_TIME9_SLOT),
    .C_ARB_TIME_SLOT_10             (ARB_TIME10_SLOT),
    .C_ARB_TIME_SLOT_11             (ARB_TIME11_SLOT),
    .C_ARB_ALGORITHM                (ARB_ALGORITHM),
    .C_PORT_ENABLE                  (PORT_ENABLE),
    .C_PORT_CONFIG                  (PORT_CONFIG),
    .C_MEM_TRAS                     (MEM_TRAS),
    .C_MEM_TRCD                     (MEM_TRCD),
    .C_MEM_TREFI                    (MEM_TREFI),
    .C_MEM_TRFC                     (MEM_TRFC),
    .C_MEM_TRP                      (MEM_TRP),
    .C_MEM_TWR                      (MEM_TWR),
    .C_MEM_TRTP                     (MEM_TRTP),
    .C_MEM_TWTR                     (MEM_TWTR),
    .C_MEM_ADDR_ORDER               (MEM_ADDR_ORDER),
    .C_NUM_DQ_PINS                  (NUM_DQ_PINS),
    .C_MEM_TYPE                     (MEM_TYPE),
    .C_MEM_DENSITY                  (MEM_DENSITY),
    .C_MEM_BURST_LEN                (MEM_BURST_LEN),
    .C_MEM_CAS_LATENCY              (MEM_CAS_LATENCY),
    .C_MEM_ADDR_WIDTH               (MEM_ADDR_WIDTH),
    .C_MEM_BANKADDR_WIDTH           (MEM_BANKADDR_WIDTH),
    .C_MEM_NUM_COL_BITS             (MEM_NUM_COL_BITS),
    .C_MEM_DDR1_2_ODS               (MEM_DDR1_2_ODS),
    .C_MEM_DDR2_RTT                 (MEM_DDR2_RTT),
    .C_MEM_DDR2_DIFF_DQS_EN         (MEM_DDR2_DIFF_DQS_EN),
    .C_MEM_DDR2_3_PA_SR             (MEM_DDR2_3_PA_SR),
    .C_MEM_DDR2_3_HIGH_TEMP_SR      (MEM_DDR2_3_HIGH_TEMP_SR),
    .C_MEM_DDR3_CAS_LATENCY         (MEM_DDR3_CAS_LATENCY),
    .C_MEM_DDR3_ODS                 (MEM_DDR3_ODS),
    .C_MEM_DDR3_RTT                 (MEM_DDR3_RTT),
    .C_MEM_DDR3_CAS_WR_LATENCY      (MEM_DDR3_CAS_WR_LATENCY),
    .C_MEM_DDR3_AUTO_SR             (MEM_DDR3_AUTO_SR),
    .C_MEM_MOBILE_PA_SR             (MEM_MOBILE_PA_SR),
    .C_MEM_MDDR_ODS                 (MEM_MDDR_ODS),
    .C_MC_CALIB_BYPASS              (MC_CALIB_BYPASS),
    .C_MC_CALIBRATION_MODE          (MC_CALIBRATION_MODE),
    .C_MC_CALIBRATION_DELAY         (MC_CALIBRATION_DELAY),
    .C_SKIP_IN_TERM_CAL             (SKIP_IN_TERM_CAL),
    .C_SKIP_DYNAMIC_CAL             (SKIP_DYNAMIC_CAL),
    .LDQSP_TAP_DELAY_VAL            (LDQSP_TAP_DELAY_VAL),
    .UDQSP_TAP_DELAY_VAL            (UDQSP_TAP_DELAY_VAL),
    .LDQSN_TAP_DELAY_VAL            (LDQSN_TAP_DELAY_VAL),
    .UDQSN_TAP_DELAY_VAL            (UDQSN_TAP_DELAY_VAL),
    .DQ0_TAP_DELAY_VAL              (DQ0_TAP_DELAY_VAL),
    .DQ1_TAP_DELAY_VAL              (DQ1_TAP_DELAY_VAL),
    .DQ2_TAP_DELAY_VAL              (DQ2_TAP_DELAY_VAL),
    .DQ3_TAP_DELAY_VAL              (DQ3_TAP_DELAY_VAL),
    .DQ4_TAP_DELAY_VAL              (DQ4_TAP_DELAY_VAL),
    .DQ5_TAP_DELAY_VAL              (DQ5_TAP_DELAY_VAL),
    .DQ6_TAP_DELAY_VAL              (DQ6_TAP_DELAY_VAL),
    .DQ7_TAP_DELAY_VAL              (DQ7_TAP_DELAY_VAL),
    .DQ8_TAP_DELAY_VAL              (DQ8_TAP_DELAY_VAL),
    .DQ9_TAP_DELAY_VAL              (DQ9_TAP_DELAY_VAL),
    .DQ10_TAP_DELAY_VAL             (DQ10_TAP_DELAY_VAL),
    .DQ11_TAP_DELAY_VAL             (DQ11_TAP_DELAY_VAL),
    .DQ12_TAP_DELAY_VAL             (DQ12_TAP_DELAY_VAL),
    .DQ13_TAP_DELAY_VAL             (DQ13_TAP_DELAY_VAL),
    .DQ14_TAP_DELAY_VAL             (DQ14_TAP_DELAY_VAL),
    .DQ15_TAP_DELAY_VAL             (DQ15_TAP_DELAY_VAL),
    .C_P0_MASK_SIZE                 (P0_MASK_SIZE),
    .C_P0_DATA_PORT_SIZE            (P0_DATA_PORT_SIZE),
    .C_P1_MASK_SIZE                 (P1_MASK_SIZE),
    .C_P1_DATA_PORT_SIZE            (P1_DATA_PORT_SIZE)
)
memc_wrapper_inst
(
    .async_rst                      (async_rst),
    .calib_done                     (calib_done),

    .sysclk_2x                      (sysclk_2x),
    .sysclk_2x_180                  (sysclk_2x_180),
    .pll_ce_0                       (pll_ce_0),
    .pll_ce_90                      (pll_ce_90),
    .pll_lock                       (pll_lock),
    .mcb_drp_clk                    (mcb_drp_clk),

    .mcbx_dram_addr                 (mcbx_dram_a),
    .mcbx_dram_ba                   (mcbx_dram_ba),
    .mcbx_dram_ras_n                (mcbx_dram_ras_n),
    .mcbx_dram_cas_n                (mcbx_dram_cas_n),
    .mcbx_dram_we_n                 (mcbx_dram_we_n),
    .mcbx_dram_cke                  (mcbx_dram_cke),
    .mcbx_dram_clk                  (mcbx_dram_ck),
    .mcbx_dram_clk_n                (mcbx_dram_ck_n),
    .mcbx_dram_dq                   (mcbx_dram_dq),
    .mcbx_dram_dqs                  (mcbx_dram_dqs),
    .mcbx_dram_dqs_n                (mcbx_dram_dqs_n),
    .mcbx_dram_udqs                 (mcbx_dram_udqs),
    .mcbx_dram_udqs_n               (mcbx_dram_udqs_n),
    .mcbx_dram_udm                  (mcbx_dram_udm),
    .mcbx_dram_ldm                  (mcbx_dram_dm),
    .mcbx_dram_odt                  (mcbx_dram_odt),
    .mcbx_dram_ddr3_rst             ( ),
    .mcbx_rzq                       (mcbx_rzq),
    .mcbx_zio                       (mcbx_zio),

    // The following port map shows all the six logical user ports. However, all
    // of them may not be active in this design. A port should be enabled to
    // validate its port map. If it is not,the complete port is going to float
    // by getting disconnected from the lower level MCB modules. The port enable
    // information of a controller can be obtained from the corresponding local
    // parameter CX_PORT_ENABLE. In such a case, we can simply ignore its port map.
    // The following comments will explain when a port is going to be active.
    // Config-1: Two 32-bit bi-directional and four 32-bit unidirectional ports
    // Config-2: Four 32-bit bi-directional ports
    // Config-3: One 64-bit bi-directional and two 32-bit bi-directional ports
    // Config-4: Two 64-bit bi-directional ports
    // Config-5: One 128-bit bi-directional port

    // User Port-0 command interface will be active only when the port is enabled in
    // the port configurations Config-1, Config-2, Config-3, Config-4 and Config-5
    .p0_cmd_clk                     (p0_cmd_clk),
    .p0_cmd_en                      (p0_cmd_en),
    .p0_cmd_instr                   (p0_cmd_instr),
    .p0_cmd_bl                      (p0_cmd_bl),
    .p0_cmd_byte_addr               (p0_cmd_byte_addr),
    .p0_cmd_full                    (p0_cmd_full),
    .p0_cmd_empty                   (p0_cmd_empty),
    // User Port-0 data write interface will be active only when the port is enabled in
    // the port configurations Config-1, Config-2, Config-3, Config-4 and Config-5
    .p0_wr_clk                      (p0_wr_clk),
    .p0_wr_en                       (p0_wr_en),
    .p0_wr_mask                     (p0_wr_mask),
    .p0_wr_data                     (p0_wr_data),
    .p0_wr_full                     (p0_wr_full),
    .p0_wr_count                    (p0_wr_count),
    .p0_wr_empty                    (p0_wr_empty),
    .p0_wr_underrun                 (p0_wr_underrun),
    .p0_wr_error                    (p0_wr_error),
    // User Port-0 data read interface will be active only when the port is enabled in
    // the port configurations Config-1, Config-2, Config-3, Config-4 and Config-5
    .p0_rd_clk                      (p0_rd_clk),
    .p0_rd_en                       (p0_rd_en),
    .p0_rd_data                     (p0_rd_data),
    .p0_rd_empty                    (p0_rd_empty),
    .p0_rd_count                    (p0_rd_count),
    .p0_rd_full                     (p0_rd_full),
    .p0_rd_overflow                 (p0_rd_overflow),
    .p0_rd_error                    (p0_rd_error),

    // User Port-1 command interface will be active only when the port is enabled in
    // the port configurations Config-1, Config-2, Config-3 and Config-4
    .p1_cmd_clk                     (p1_cmd_clk),
    .p1_cmd_en                      (p1_cmd_en),
    .p1_cmd_instr                   (p1_cmd_instr),
    .p1_cmd_bl                      (p1_cmd_bl),
    .p1_cmd_byte_addr               (p1_cmd_byte_addr),
    .p1_cmd_full                    (p1_cmd_full),
    .p1_cmd_empty                   (p1_cmd_empty),
    // User Port-1 data write interface will be active only when the port is enabled in
    // the port configurations Config-1, Config-2, Config-3 and Config-4
    .p1_wr_clk                      (p1_wr_clk),
    .p1_wr_en                       (p1_wr_en),
    .p1_wr_mask                     (p1_wr_mask),
    .p1_wr_data                     (p1_wr_data),
    .p1_wr_full                     (p1_wr_full),
    .p1_wr_count                    (p1_wr_count),
    .p1_wr_empty                    (p1_wr_empty),
    .p1_wr_underrun                 (p1_wr_underrun),
    .p1_wr_error                    (p1_wr_error),
    // User Port-1 data read interface will be active only when the port is enabled in
    // the port configurations Config-1, Config-2, Config-3 and Config-4
    .p1_rd_clk                      (p1_rd_clk),
    .p1_rd_en                       (p1_rd_en),
    .p1_rd_data                     (p1_rd_data),
    .p1_rd_empty                    (p1_rd_empty),
    .p1_rd_count                    (p1_rd_count),
    .p1_rd_full                     (p1_rd_full),
    .p1_rd_overflow                 (p1_rd_overflow),
    .p1_rd_error                    (p1_rd_error),

    // User Port-2 command interface will be active only when the port is enabled in
    // the port configurations Config-1, Config-2 and Config-3
    .p2_cmd_clk                     (p2_cmd_clk),
    .p2_cmd_en                      (p2_cmd_en),
    .p2_cmd_instr                   (p2_cmd_instr),
    .p2_cmd_bl                      (p2_cmd_bl),
    .p2_cmd_byte_addr               (p2_cmd_byte_addr),
    .p2_cmd_full                    (p2_cmd_full),
    .p2_cmd_empty                   (p2_cmd_empty),
    // User Port-2 data write interface will be active only when the port is enabled in
    // the port configurations Config-1 write direction, Config-2 and Config-3
    .p2_wr_clk                      (p2_wr_clk),
    .p2_wr_en                       (p2_wr_en),
    .p2_wr_mask                     (p2_wr_mask),
    .p2_wr_data                     (p2_wr_data),
    .p2_wr_full                     (p2_wr_full),
    .p2_wr_count                    (p2_wr_count),
    .p2_wr_empty                    (p2_wr_empty),
    .p2_wr_underrun                 (p2_wr_underrun),
    .p2_wr_error                    (p2_wr_error),
    // User Port-2 data read interface will be active only when the port is enabled in
    // the port configurations Config-1 read direction, Config-2 and Config-3
    .p2_rd_clk                      (p2_rd_clk),
    .p2_rd_en                       (p2_rd_en),
    .p2_rd_data                     (p2_rd_data),
    .p2_rd_empty                    (p2_rd_empty),
    .p2_rd_count                    (p2_rd_count),
    .p2_rd_full                     (p2_rd_full),
    .p2_rd_overflow                 (p2_rd_overflow),
    .p2_rd_error                    (p2_rd_error),

    // User Port-3 command interface will be active only when the port is enabled in
    // the port configurations Config-1 and Config-2
    .p3_cmd_clk                     (p3_cmd_clk),
    .p3_cmd_en                      (p3_cmd_en),
    .p3_cmd_instr                   (p3_cmd_instr),
    .p3_cmd_bl                      (p3_cmd_bl),
    .p3_cmd_byte_addr               (p3_cmd_byte_addr),
    .p3_cmd_full                    (p3_cmd_full),
    .p3_cmd_empty                   (p3_cmd_empty),
    // User Port-3 data write interface will be active only when the port is enabled in
    // the port configurations Config-1 write direction and Config-2
    .p3_wr_clk                      (p3_wr_clk),
    .p3_wr_en                       (p3_wr_en),
    .p3_wr_mask                     (p3_wr_mask),
    .p3_wr_data                     (p3_wr_data),
    .p3_wr_full                     (p3_wr_full),
    .p3_wr_count                    (p3_wr_count),
    .p3_wr_empty                    (p3_wr_empty),
    .p3_wr_underrun                 (p3_wr_underrun),
    .p3_wr_error                    (p3_wr_error),
    // User Port-3 data read interface will be active only when the port is enabled in
    // the port configurations Config-1 read direction and Config-2
    .p3_rd_clk                      (p3_rd_clk),
    .p3_rd_en                       (p3_rd_en),
    .p3_rd_data                     (p3_rd_data),
    .p3_rd_empty                    (p3_rd_empty),
    .p3_rd_count                    (p3_rd_count),
    .p3_rd_full                     (p3_rd_full),
    .p3_rd_overflow                 (p3_rd_overflow),
    .p3_rd_error                    (p3_rd_error),

    // User Port-4 command interface will be active only when the port is enabled in
    // the port configuration Config-1
    .p4_cmd_clk                     (p4_cmd_clk),
    .p4_cmd_en                      (p4_cmd_en),
    .p4_cmd_instr                   (p4_cmd_instr),
    .p4_cmd_bl                      (p4_cmd_bl),
    .p4_cmd_byte_addr               (p4_cmd_byte_addr),
    .p4_cmd_full                    (p4_cmd_full),
    .p4_cmd_empty                   (p4_cmd_empty),
    // User Port-4 data write interface will be active only when the port is enabled in
    // the port configuration Config-1 write direction
    .p4_wr_clk                      (p4_wr_clk),
    .p4_wr_en                       (p4_wr_en),
    .p4_wr_mask                     (p4_wr_mask),
    .p4_wr_data                     (p4_wr_data),
    .p4_wr_full                     (p4_wr_full),
    .p4_wr_count                    (p4_wr_count),
    .p4_wr_empty                    (p4_wr_empty),
    .p4_wr_underrun                 (p4_wr_underrun),
    .p4_wr_error                    (p4_wr_error),
    // User Port-4 data read interface will be active only when the port is enabled in
    // the port configuration Config-1 read direction
    .p4_rd_clk                      (p4_rd_clk),
    .p4_rd_en                       (p4_rd_en),
    .p4_rd_data                     (p4_rd_data),
    .p4_rd_empty                    (p4_rd_empty),
    .p4_rd_count                    (p4_rd_count),
    .p4_rd_full                     (p4_rd_full),
    .p4_rd_overflow                 (p4_rd_overflow),
    .p4_rd_error                    (p4_rd_error),

    // User Port-5 command interface will be active only when the port is enabled in
    // the port configuration Config-1
    .p5_cmd_clk                     (p5_cmd_clk),
    .p5_cmd_en                      (p5_cmd_en),
    .p5_cmd_instr                   (p5_cmd_instr),
    .p5_cmd_bl                      (p5_cmd_bl),
    .p5_cmd_byte_addr               (p5_cmd_byte_addr),
    .p5_cmd_full                    (p5_cmd_full),
    .p5_cmd_empty                   (p5_cmd_empty),
    // User Port-5 data write interface will be active only when the port is enabled in
    // the port configuration Config-1 write direction
    .p5_wr_clk                      (p5_wr_clk),
    .p5_wr_en                       (p5_wr_en),
    .p5_wr_mask                     (p5_wr_mask),
    .p5_wr_data                     (p5_wr_data),
    .p5_wr_full                     (p5_wr_full),
    .p5_wr_count                    (p5_wr_count),
    .p5_wr_empty                    (p5_wr_empty),
    .p5_wr_underrun                 (p5_wr_underrun),
    .p5_wr_error                    (p5_wr_error),
    // User Port-5 data read interface will be active only when the port is enabled in
    // the port configuration Config-1 read direction
    .p5_rd_clk                      (p5_rd_clk),
    .p5_rd_en                       (p5_rd_en),
    .p5_rd_data                     (p5_rd_data),
    .p5_rd_empty                    (p5_rd_empty),
    .p5_rd_count                    (p5_rd_count),
    .p5_rd_full                     (p5_rd_full),
    .p5_rd_overflow                 (p5_rd_overflow),
    .p5_rd_error                    (p5_rd_error),

    .selfrefresh_enter              (1'b0),
    .selfrefresh_mode               (selfrefresh_mode)
);

endmodule
