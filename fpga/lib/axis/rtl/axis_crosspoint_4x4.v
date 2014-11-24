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
 * AXI4-Stream 4x4 crosspoint
 */
module axis_crosspoint_4x4 #
(
    parameter DATA_WIDTH = 8
)
(
    input  wire        clk,
    input  wire        rst,

    /*
     * AXI Stream inputs
     */
    input  wire [DATA_WIDTH-1:0]  input_0_axis_tdata,
    input  wire                   input_0_axis_tvalid,
    input  wire                   input_0_axis_tlast,
    input  wire                   input_0_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_1_axis_tdata,
    input  wire                   input_1_axis_tvalid,
    input  wire                   input_1_axis_tlast,
    input  wire                   input_1_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_2_axis_tdata,
    input  wire                   input_2_axis_tvalid,
    input  wire                   input_2_axis_tlast,
    input  wire                   input_2_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_3_axis_tdata,
    input  wire                   input_3_axis_tvalid,
    input  wire                   input_3_axis_tlast,
    input  wire                   input_3_axis_tuser,

    /*
     * AXI Stream outputs
     */
    output wire [DATA_WIDTH-1:0]  output_0_axis_tdata,
    output wire                   output_0_axis_tvalid,
    output wire                   output_0_axis_tlast,
    output wire                   output_0_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_1_axis_tdata,
    output wire                   output_1_axis_tvalid,
    output wire                   output_1_axis_tlast,
    output wire                   output_1_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_2_axis_tdata,
    output wire                   output_2_axis_tvalid,
    output wire                   output_2_axis_tlast,
    output wire                   output_2_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_3_axis_tdata,
    output wire                   output_3_axis_tvalid,
    output wire                   output_3_axis_tlast,
    output wire                   output_3_axis_tuser,

    /*
     * Control
     */
    input  wire [1:0]             output_0_select,
    input  wire [1:0]             output_1_select,
    input  wire [1:0]             output_2_select,
    input  wire [1:0]             output_3_select
);

reg [DATA_WIDTH-1:0]  input_0_axis_tdata_reg = 0;
reg                   input_0_axis_tvalid_reg = 0;
reg                   input_0_axis_tlast_reg = 0;
reg                   input_0_axis_tuser_reg = 0;

reg [DATA_WIDTH-1:0]  input_1_axis_tdata_reg = 0;
reg                   input_1_axis_tvalid_reg = 0;
reg                   input_1_axis_tlast_reg = 0;
reg                   input_1_axis_tuser_reg = 0;

reg [DATA_WIDTH-1:0]  input_2_axis_tdata_reg = 0;
reg                   input_2_axis_tvalid_reg = 0;
reg                   input_2_axis_tlast_reg = 0;
reg                   input_2_axis_tuser_reg = 0;

reg [DATA_WIDTH-1:0]  input_3_axis_tdata_reg = 0;
reg                   input_3_axis_tvalid_reg = 0;
reg                   input_3_axis_tlast_reg = 0;
reg                   input_3_axis_tuser_reg = 0;

reg [DATA_WIDTH-1:0]  output_0_axis_tdata_reg = 0;
reg                   output_0_axis_tvalid_reg = 0;
reg                   output_0_axis_tlast_reg = 0;
reg                   output_0_axis_tuser_reg = 0;

reg [DATA_WIDTH-1:0]  output_1_axis_tdata_reg = 0;
reg                   output_1_axis_tvalid_reg = 0;
reg                   output_1_axis_tlast_reg = 0;
reg                   output_1_axis_tuser_reg = 0;

reg [DATA_WIDTH-1:0]  output_2_axis_tdata_reg = 0;
reg                   output_2_axis_tvalid_reg = 0;
reg                   output_2_axis_tlast_reg = 0;
reg                   output_2_axis_tuser_reg = 0;

reg [DATA_WIDTH-1:0]  output_3_axis_tdata_reg = 0;
reg                   output_3_axis_tvalid_reg = 0;
reg                   output_3_axis_tlast_reg = 0;
reg                   output_3_axis_tuser_reg = 0;

reg [1:0]             output_0_select_reg = 0;
reg [1:0]             output_1_select_reg = 0;
reg [1:0]             output_2_select_reg = 0;
reg [1:0]             output_3_select_reg = 0;

assign output_0_axis_tdata = output_0_axis_tdata_reg;
assign output_0_axis_tvalid = output_0_axis_tvalid_reg;
assign output_0_axis_tlast = output_0_axis_tlast_reg;
assign output_0_axis_tuser = output_0_axis_tuser_reg;

assign output_1_axis_tdata = output_1_axis_tdata_reg;
assign output_1_axis_tvalid = output_1_axis_tvalid_reg;
assign output_1_axis_tlast = output_1_axis_tlast_reg;
assign output_1_axis_tuser = output_1_axis_tuser_reg;

assign output_2_axis_tdata = output_2_axis_tdata_reg;
assign output_2_axis_tvalid = output_2_axis_tvalid_reg;
assign output_2_axis_tlast = output_2_axis_tlast_reg;
assign output_2_axis_tuser = output_2_axis_tuser_reg;

assign output_3_axis_tdata = output_3_axis_tdata_reg;
assign output_3_axis_tvalid = output_3_axis_tvalid_reg;
assign output_3_axis_tlast = output_3_axis_tlast_reg;
assign output_3_axis_tuser = output_3_axis_tuser_reg;


always @(posedge clk or posedge rst) begin
    if (rst) begin
        output_0_select_reg <= 0;
        output_1_select_reg <= 0;
        output_2_select_reg <= 0;
        output_3_select_reg <= 0;

        input_0_axis_tdata_reg <= 0;
        input_0_axis_tvalid_reg <= 0;
        input_0_axis_tlast_reg <= 0;
        input_0_axis_tuser_reg <= 0;
        input_1_axis_tdata_reg <= 0;
        input_1_axis_tvalid_reg <= 0;
        input_1_axis_tlast_reg <= 0;
        input_1_axis_tuser_reg <= 0;
        input_2_axis_tdata_reg <= 0;
        input_2_axis_tvalid_reg <= 0;
        input_2_axis_tlast_reg <= 0;
        input_2_axis_tuser_reg <= 0;
        input_3_axis_tdata_reg <= 0;
        input_3_axis_tvalid_reg <= 0;
        input_3_axis_tlast_reg <= 0;
        input_3_axis_tuser_reg <= 0;

        output_0_axis_tdata_reg <= 0;
        output_0_axis_tvalid_reg <= 0;
        output_0_axis_tlast_reg <= 0;
        output_0_axis_tuser_reg <= 0;
        output_1_axis_tdata_reg <= 0;
        output_1_axis_tvalid_reg <= 0;
        output_1_axis_tlast_reg <= 0;
        output_1_axis_tuser_reg <= 0;
        output_2_axis_tdata_reg <= 0;
        output_2_axis_tvalid_reg <= 0;
        output_2_axis_tlast_reg <= 0;
        output_2_axis_tuser_reg <= 0;
        output_3_axis_tdata_reg <= 0;
        output_3_axis_tvalid_reg <= 0;
        output_3_axis_tlast_reg <= 0;
        output_3_axis_tuser_reg <= 0;
    end else begin
        input_0_axis_tdata_reg <= input_0_axis_tdata;
        input_0_axis_tvalid_reg <= input_0_axis_tvalid;
        input_0_axis_tlast_reg <= input_0_axis_tlast;
        input_0_axis_tuser_reg <= input_0_axis_tuser;

        input_1_axis_tdata_reg <= input_1_axis_tdata;
        input_1_axis_tvalid_reg <= input_1_axis_tvalid;
        input_1_axis_tlast_reg <= input_1_axis_tlast;
        input_1_axis_tuser_reg <= input_1_axis_tuser;

        input_2_axis_tdata_reg <= input_2_axis_tdata;
        input_2_axis_tvalid_reg <= input_2_axis_tvalid;
        input_2_axis_tlast_reg <= input_2_axis_tlast;
        input_2_axis_tuser_reg <= input_2_axis_tuser;

        input_3_axis_tdata_reg <= input_3_axis_tdata;
        input_3_axis_tvalid_reg <= input_3_axis_tvalid;
        input_3_axis_tlast_reg <= input_3_axis_tlast;
        input_3_axis_tuser_reg <= input_3_axis_tuser;

        output_0_select_reg <= output_0_select;
        output_1_select_reg <= output_1_select;
        output_2_select_reg <= output_2_select;
        output_3_select_reg <= output_3_select;

        case (output_0_select_reg)
            2'd0: begin
                output_0_axis_tdata_reg <= input_0_axis_tdata_reg;
                output_0_axis_tvalid_reg <= input_0_axis_tvalid_reg;
                output_0_axis_tlast_reg <= input_0_axis_tlast_reg;
                output_0_axis_tuser_reg <= input_0_axis_tuser_reg;
            end
            2'd1: begin
                output_0_axis_tdata_reg <= input_1_axis_tdata_reg;
                output_0_axis_tvalid_reg <= input_1_axis_tvalid_reg;
                output_0_axis_tlast_reg <= input_1_axis_tlast_reg;
                output_0_axis_tuser_reg <= input_1_axis_tuser_reg;
            end
            2'd2: begin
                output_0_axis_tdata_reg <= input_2_axis_tdata_reg;
                output_0_axis_tvalid_reg <= input_2_axis_tvalid_reg;
                output_0_axis_tlast_reg <= input_2_axis_tlast_reg;
                output_0_axis_tuser_reg <= input_2_axis_tuser_reg;
            end
            2'd3: begin
                output_0_axis_tdata_reg <= input_3_axis_tdata_reg;
                output_0_axis_tvalid_reg <= input_3_axis_tvalid_reg;
                output_0_axis_tlast_reg <= input_3_axis_tlast_reg;
                output_0_axis_tuser_reg <= input_3_axis_tuser_reg;
            end
        endcase

        case (output_1_select_reg)
            2'd0: begin
                output_1_axis_tdata_reg <= input_0_axis_tdata_reg;
                output_1_axis_tvalid_reg <= input_0_axis_tvalid_reg;
                output_1_axis_tlast_reg <= input_0_axis_tlast_reg;
                output_1_axis_tuser_reg <= input_0_axis_tuser_reg;
            end
            2'd1: begin
                output_1_axis_tdata_reg <= input_1_axis_tdata_reg;
                output_1_axis_tvalid_reg <= input_1_axis_tvalid_reg;
                output_1_axis_tlast_reg <= input_1_axis_tlast_reg;
                output_1_axis_tuser_reg <= input_1_axis_tuser_reg;
            end
            2'd2: begin
                output_1_axis_tdata_reg <= input_2_axis_tdata_reg;
                output_1_axis_tvalid_reg <= input_2_axis_tvalid_reg;
                output_1_axis_tlast_reg <= input_2_axis_tlast_reg;
                output_1_axis_tuser_reg <= input_2_axis_tuser_reg;
            end
            2'd3: begin
                output_1_axis_tdata_reg <= input_3_axis_tdata_reg;
                output_1_axis_tvalid_reg <= input_3_axis_tvalid_reg;
                output_1_axis_tlast_reg <= input_3_axis_tlast_reg;
                output_1_axis_tuser_reg <= input_3_axis_tuser_reg;
            end
        endcase

        case (output_2_select_reg)
            2'd0: begin
                output_2_axis_tdata_reg <= input_0_axis_tdata_reg;
                output_2_axis_tvalid_reg <= input_0_axis_tvalid_reg;
                output_2_axis_tlast_reg <= input_0_axis_tlast_reg;
                output_2_axis_tuser_reg <= input_0_axis_tuser_reg;
            end
            2'd1: begin
                output_2_axis_tdata_reg <= input_1_axis_tdata_reg;
                output_2_axis_tvalid_reg <= input_1_axis_tvalid_reg;
                output_2_axis_tlast_reg <= input_1_axis_tlast_reg;
                output_2_axis_tuser_reg <= input_1_axis_tuser_reg;
            end
            2'd2: begin
                output_2_axis_tdata_reg <= input_2_axis_tdata_reg;
                output_2_axis_tvalid_reg <= input_2_axis_tvalid_reg;
                output_2_axis_tlast_reg <= input_2_axis_tlast_reg;
                output_2_axis_tuser_reg <= input_2_axis_tuser_reg;
            end
            2'd3: begin
                output_2_axis_tdata_reg <= input_3_axis_tdata_reg;
                output_2_axis_tvalid_reg <= input_3_axis_tvalid_reg;
                output_2_axis_tlast_reg <= input_3_axis_tlast_reg;
                output_2_axis_tuser_reg <= input_3_axis_tuser_reg;
            end
        endcase

        case (output_3_select_reg)
            2'd0: begin
                output_3_axis_tdata_reg <= input_0_axis_tdata_reg;
                output_3_axis_tvalid_reg <= input_0_axis_tvalid_reg;
                output_3_axis_tlast_reg <= input_0_axis_tlast_reg;
                output_3_axis_tuser_reg <= input_0_axis_tuser_reg;
            end
            2'd1: begin
                output_3_axis_tdata_reg <= input_1_axis_tdata_reg;
                output_3_axis_tvalid_reg <= input_1_axis_tvalid_reg;
                output_3_axis_tlast_reg <= input_1_axis_tlast_reg;
                output_3_axis_tuser_reg <= input_1_axis_tuser_reg;
            end
            2'd2: begin
                output_3_axis_tdata_reg <= input_2_axis_tdata_reg;
                output_3_axis_tvalid_reg <= input_2_axis_tvalid_reg;
                output_3_axis_tlast_reg <= input_2_axis_tlast_reg;
                output_3_axis_tuser_reg <= input_2_axis_tuser_reg;
            end
            2'd3: begin
                output_3_axis_tdata_reg <= input_3_axis_tdata_reg;
                output_3_axis_tvalid_reg <= input_3_axis_tvalid_reg;
                output_3_axis_tlast_reg <= input_3_axis_tlast_reg;
                output_3_axis_tuser_reg <= input_3_axis_tuser_reg;
            end
        endcase
    end
end

endmodule
