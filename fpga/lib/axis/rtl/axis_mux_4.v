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
 * AXI4-Stream 4 port multiplexer
 */
module axis_mux_4 #
(
    parameter DATA_WIDTH = 8
)
(
    input  wire                   clk,
    input  wire                   rst,
    
    /*
     * AXI inputs
     */
    input  wire [DATA_WIDTH-1:0]  input_0_axis_tdata,
    input  wire                   input_0_axis_tvalid,
    output wire                   input_0_axis_tready,
    input  wire                   input_0_axis_tlast,
    input  wire                   input_0_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_1_axis_tdata,
    input  wire                   input_1_axis_tvalid,
    output wire                   input_1_axis_tready,
    input  wire                   input_1_axis_tlast,
    input  wire                   input_1_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_2_axis_tdata,
    input  wire                   input_2_axis_tvalid,
    output wire                   input_2_axis_tready,
    input  wire                   input_2_axis_tlast,
    input  wire                   input_2_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_3_axis_tdata,
    input  wire                   input_3_axis_tvalid,
    output wire                   input_3_axis_tready,
    input  wire                   input_3_axis_tlast,
    input  wire                   input_3_axis_tuser,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]  output_axis_tdata,
    output wire                   output_axis_tvalid,
    input  wire                   output_axis_tready,
    output wire                   output_axis_tlast,
    output wire                   output_axis_tuser,

    /*
     * Control
     */
    input  wire                   enable,
    input  wire [1:0]             select
);

reg [1:0] select_reg = 0, select_next;
reg frame_reg = 0, frame_next;

reg input_0_axis_tready_reg = 0, input_0_axis_tready_next;
reg input_1_axis_tready_reg = 0, input_1_axis_tready_next;
reg input_2_axis_tready_reg = 0, input_2_axis_tready_next;
reg input_3_axis_tready_reg = 0, input_3_axis_tready_next;

// internal datapath
reg [DATA_WIDTH-1:0] output_axis_tdata_int;
reg                  output_axis_tvalid_int;
reg                  output_axis_tready_int = 0;
reg                  output_axis_tlast_int;
reg                  output_axis_tuser_int;
wire                 output_axis_tready_int_early;

assign input_0_axis_tready = input_0_axis_tready_reg;
assign input_1_axis_tready = input_1_axis_tready_reg;
assign input_2_axis_tready = input_2_axis_tready_reg;
assign input_3_axis_tready = input_3_axis_tready_reg;

// mux for start of packet detection
reg selected_input_tvalid;
always @* begin
    case (select)
        2'd0: selected_input_tvalid = input_0_axis_tvalid;
        2'd1: selected_input_tvalid = input_1_axis_tvalid;
        2'd2: selected_input_tvalid = input_2_axis_tvalid;
        2'd3: selected_input_tvalid = input_3_axis_tvalid;
    endcase
end

// mux for incoming packet
reg [DATA_WIDTH-1:0] current_input_tdata;
reg current_input_tvalid;
reg current_input_tready;
reg current_input_tlast;
reg current_input_tuser;
always @* begin
    case (select_reg)
        2'd0: begin
            current_input_tdata = input_0_axis_tdata;
            current_input_tvalid = input_0_axis_tvalid;
            current_input_tready = input_0_axis_tready;
            current_input_tlast = input_0_axis_tlast;
            current_input_tuser = input_0_axis_tuser;
        end
        2'd1: begin
            current_input_tdata = input_1_axis_tdata;
            current_input_tvalid = input_1_axis_tvalid;
            current_input_tready = input_1_axis_tready;
            current_input_tlast = input_1_axis_tlast;
            current_input_tuser = input_1_axis_tuser;
        end
        2'd2: begin
            current_input_tdata = input_2_axis_tdata;
            current_input_tvalid = input_2_axis_tvalid;
            current_input_tready = input_2_axis_tready;
            current_input_tlast = input_2_axis_tlast;
            current_input_tuser = input_2_axis_tuser;
        end
        2'd3: begin
            current_input_tdata = input_3_axis_tdata;
            current_input_tvalid = input_3_axis_tvalid;
            current_input_tready = input_3_axis_tready;
            current_input_tlast = input_3_axis_tlast;
            current_input_tuser = input_3_axis_tuser;
        end
    endcase
end

always @* begin
    select_next = select_reg;
    frame_next = frame_reg;

    input_0_axis_tready_next = 0;
    input_1_axis_tready_next = 0;
    input_2_axis_tready_next = 0;
    input_3_axis_tready_next = 0;

    if (frame_reg) begin
        if (current_input_tvalid & current_input_tready) begin
            // end of frame detection
            frame_next = ~current_input_tlast;
        end
    end else if (enable & selected_input_tvalid) begin
        // start of frame, grab select value
        frame_next = 1;
        select_next = select;
    end

    // generate ready signal on selected port
    case (select_next)
        2'd0: input_0_axis_tready_next = output_axis_tready_int_early & frame_next;
        2'd1: input_1_axis_tready_next = output_axis_tready_int_early & frame_next;
        2'd2: input_2_axis_tready_next = output_axis_tready_int_early & frame_next;
        2'd3: input_3_axis_tready_next = output_axis_tready_int_early & frame_next;
    endcase

    // pass through selected packet data
    output_axis_tdata_int = current_input_tdata;
    output_axis_tvalid_int = current_input_tvalid & current_input_tready & frame_reg;
    output_axis_tlast_int = current_input_tlast;
    output_axis_tuser_int = current_input_tuser;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        select_reg <= 0;
        frame_reg <= 0;
        input_0_axis_tready_reg <= 0;
        input_1_axis_tready_reg <= 0;
        input_2_axis_tready_reg <= 0;
        input_3_axis_tready_reg <= 0;
    end else begin
        select_reg <= select_next;
        frame_reg <= frame_next;
        input_0_axis_tready_reg <= input_0_axis_tready_next;
        input_1_axis_tready_reg <= input_1_axis_tready_next;
        input_2_axis_tready_reg <= input_2_axis_tready_next;
        input_3_axis_tready_reg <= input_3_axis_tready_next;
    end
end

// output datapath logic
reg [DATA_WIDTH-1:0] output_axis_tdata_reg = 0;
reg                  output_axis_tvalid_reg = 0;
reg                  output_axis_tlast_reg = 0;
reg                  output_axis_tuser_reg = 0;

reg [DATA_WIDTH-1:0] temp_axis_tdata_reg = 0;
reg                  temp_axis_tvalid_reg = 0;
reg                  temp_axis_tlast_reg = 0;
reg                  temp_axis_tuser_reg = 0;

assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast = output_axis_tlast_reg;
assign output_axis_tuser = output_axis_tuser_reg;

// enable ready input next cycle if output is ready or if there is space in both output registers or if there is space in the temp register that will not be filled next cycle
assign output_axis_tready_int_early = output_axis_tready | (~temp_axis_tvalid_reg & ~output_axis_tvalid_reg) | (~temp_axis_tvalid_reg & ~output_axis_tvalid_int);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        output_axis_tdata_reg <= 0;
        output_axis_tvalid_reg <= 0;
        output_axis_tlast_reg <= 0;
        output_axis_tuser_reg <= 0;
        output_axis_tready_int <= 0;
        temp_axis_tdata_reg <= 0;
        temp_axis_tvalid_reg <= 0;
        temp_axis_tlast_reg <= 0;
        temp_axis_tuser_reg <= 0;
    end else begin
        // transfer sink ready state to source
        output_axis_tready_int <= output_axis_tready_int_early;

        if (output_axis_tready_int) begin
            // input is ready
            if (output_axis_tready | ~output_axis_tvalid_reg) begin
                // output is ready or currently not valid, transfer data to output
                output_axis_tdata_reg <= output_axis_tdata_int;
                output_axis_tvalid_reg <= output_axis_tvalid_int;
                output_axis_tlast_reg <= output_axis_tlast_int;
                output_axis_tuser_reg <= output_axis_tuser_int;
            end else begin
                // output is not ready, store input in temp
                temp_axis_tdata_reg <= output_axis_tdata_int;
                temp_axis_tvalid_reg <= output_axis_tvalid_int;
                temp_axis_tlast_reg <= output_axis_tlast_int;
                temp_axis_tuser_reg <= output_axis_tuser_int;
            end
        end else if (output_axis_tready) begin
            // input is not ready, but output is ready
            output_axis_tdata_reg <= temp_axis_tdata_reg;
            output_axis_tvalid_reg <= temp_axis_tvalid_reg;
            output_axis_tlast_reg <= temp_axis_tlast_reg;
            output_axis_tuser_reg <= temp_axis_tuser_reg;
            temp_axis_tdata_reg <= 0;
            temp_axis_tvalid_reg <= 0;
            temp_axis_tlast_reg <= 0;
            temp_axis_tuser_reg <= 0;
        end
    end
end

endmodule
