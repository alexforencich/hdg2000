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
 * AXI4-Stream 4 port frame joiner
 */
module axis_frame_join_4 #
(
    parameter ENABLE_TAG = 1
)
(
    input  wire        clk,
    input  wire        rst,

    /*
     * AXI inputs
     */
    input  wire [7:0]  input_0_axis_tdata,
    input  wire        input_0_axis_tvalid,
    output wire        input_0_axis_tready,
    input  wire        input_0_axis_tlast,
    input  wire        input_0_axis_tuser,

    input  wire [7:0]  input_1_axis_tdata,
    input  wire        input_1_axis_tvalid,
    output wire        input_1_axis_tready,
    input  wire        input_1_axis_tlast,
    input  wire        input_1_axis_tuser,

    input  wire [7:0]  input_2_axis_tdata,
    input  wire        input_2_axis_tvalid,
    output wire        input_2_axis_tready,
    input  wire        input_2_axis_tlast,
    input  wire        input_2_axis_tuser,

    input  wire [7:0]  input_3_axis_tdata,
    input  wire        input_3_axis_tvalid,
    output wire        input_3_axis_tready,
    input  wire        input_3_axis_tlast,
    input  wire        input_3_axis_tuser,

    /*
     * AXI output
     */
    output wire [7:0]  output_axis_tdata,
    output wire        output_axis_tvalid,
    input  wire        output_axis_tready,
    output wire        output_axis_tlast,
    output wire        output_axis_tuser,

    /*
     * Configuration
     */
    input  wire [15:0] tag,

    /*
     * Status signals
     */
    output wire        busy
);

// state register
localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_WRITE_TAG = 2'd1,
    STATE_TRANSFER = 2'd2;

reg [1:0] state_reg = STATE_IDLE, state_next;

reg [2:0] frame_ptr_reg = 0, frame_ptr_next;
reg [1:0] port_sel_reg = 0, port_sel_next;

reg busy_reg = 0, busy_next;

reg [7:0] input_tdata;
reg input_tvalid;
reg input_tlast;
reg input_tuser;

reg output_tuser_reg = 0, output_tuser_next;

reg input_0_axis_tready_reg = 0, input_0_axis_tready_next;
reg input_1_axis_tready_reg = 0, input_1_axis_tready_next;
reg input_2_axis_tready_reg = 0, input_2_axis_tready_next;
reg input_3_axis_tready_reg = 0, input_3_axis_tready_next;

// internal datapath
reg [7:0] output_axis_tdata_int;
reg       output_axis_tvalid_int;
reg       output_axis_tready_int = 0;
reg       output_axis_tlast_int;
reg       output_axis_tuser_int;
wire      output_axis_tready_int_early;

assign input_0_axis_tready = input_0_axis_tready_reg;
assign input_1_axis_tready = input_1_axis_tready_reg;
assign input_2_axis_tready = input_2_axis_tready_reg;
assign input_3_axis_tready = input_3_axis_tready_reg;

assign busy = busy_reg;

always @* begin
    // input port mux
    case (port_sel_reg)
        2'd0: begin
            input_tdata = input_0_axis_tdata;
            input_tvalid = input_0_axis_tvalid;
            input_tlast = input_0_axis_tlast;
            input_tuser = input_0_axis_tuser;
        end
        2'd1: begin
            input_tdata = input_1_axis_tdata;
            input_tvalid = input_1_axis_tvalid;
            input_tlast = input_1_axis_tlast;
            input_tuser = input_1_axis_tuser;
        end
        2'd2: begin
            input_tdata = input_2_axis_tdata;
            input_tvalid = input_2_axis_tvalid;
            input_tlast = input_2_axis_tlast;
            input_tuser = input_2_axis_tuser;
        end
        2'd3: begin
            input_tdata = input_3_axis_tdata;
            input_tvalid = input_3_axis_tvalid;
            input_tlast = input_3_axis_tlast;
            input_tuser = input_3_axis_tuser;
        end
    endcase
end

always @* begin
    state_next = 2'bz;

    frame_ptr_next = frame_ptr_reg;
    port_sel_next = port_sel_reg;

    input_0_axis_tready_next = 0;
    input_1_axis_tready_next = 0;
    input_2_axis_tready_next = 0;
    input_3_axis_tready_next = 0;

    output_axis_tdata_int = 0;
    output_axis_tvalid_int = 0;
    output_axis_tlast_int = 0;
    output_axis_tuser_int = 0;

    output_tuser_next = output_tuser_reg;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_ptr_next = 0;
            port_sel_next = 0;
            output_tuser_next = 0;

            if (ENABLE_TAG) begin
                // next cycle if started will send tag, so do not enable input
                input_0_axis_tready_next = 0;
            end else begin
                // next cycle if started will send data, so enable input
                input_0_axis_tready_next = output_axis_tready_int_early;
            end
            
            if (input_0_axis_tvalid) begin
                // input 0 valid; start transferring data
                if (ENABLE_TAG) begin
                    // tag enabled, so transmit it
                    if (output_axis_tready_int) begin
                        // output is ready, so short-circuit first tag byte
                        frame_ptr_next = 1;
                        output_axis_tdata_int = tag[15:8];
                        output_axis_tvalid_int = 1;
                    end
                    
                    state_next = STATE_WRITE_TAG;
                end else begin
                    // tag disabled, so transmit data
                    if (output_axis_tready_int) begin
                        // output is ready, so short-circuit first data byte
                        output_axis_tdata_int = input_0_axis_tdata;
                        output_axis_tvalid_int = 1;
                    end
                    state_next = STATE_TRANSFER;
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_WRITE_TAG: begin
            // write tag data
            if (output_axis_tready_int) begin
                // output ready, so send tag byte
                state_next = STATE_WRITE_TAG;
                frame_ptr_next = frame_ptr_reg + 1;
                output_axis_tvalid_int = 1;
                case (frame_ptr_reg)
                    2'd0: output_axis_tdata_int = tag[15:8];
                    2'd1: begin
                        // last tag byte - get ready to send data, enable input if ready
                        output_axis_tdata_int = tag[7:0];
                        input_0_axis_tready_next = output_axis_tready_int_early;
                        state_next = STATE_TRANSFER;
                    end
                endcase
            end else begin
                state_next = STATE_WRITE_TAG;
            end
        end
        STATE_TRANSFER: begin
            // transfer input data

            // set ready for current input
            case (port_sel_reg)
                2'd0: input_0_axis_tready_next = output_axis_tready_int_early;
                2'd1: input_1_axis_tready_next = output_axis_tready_int_early;
                2'd2: input_2_axis_tready_next = output_axis_tready_int_early;
                2'd3: input_3_axis_tready_next = output_axis_tready_int_early;
            endcase

            if (input_tvalid & output_axis_tready_int) begin
                // output ready, transfer byte
                state_next = STATE_TRANSFER;
                output_axis_tdata_int = input_tdata;
                output_axis_tvalid_int = input_tvalid;

                if (input_tlast) begin
                    // last flag received, switch to next port
                    port_sel_next = port_sel_reg + 1;
                    // save tuser - assert tuser out if ANY tuser asserts received
                    output_tuser_next = output_tuser_next | input_tuser;
                    // disable input
                    input_0_axis_tready_next = 0;
                    input_1_axis_tready_next = 0;
                    input_2_axis_tready_next = 0;
                    input_3_axis_tready_next = 0;

                    if (port_sel_reg == 3) begin
                        // last port - send tlast and tuser and revert to idle
                        output_axis_tlast_int = 1;
                        output_axis_tuser_int = output_tuser_next;
                        state_next = STATE_IDLE;
                    end else begin
                        // otherwise, disable enable next port
                        case (port_sel_next)
                            2'd0: input_0_axis_tready_next = output_axis_tready_int_early;
                            2'd1: input_1_axis_tready_next = output_axis_tready_int_early;
                            2'd2: input_2_axis_tready_next = output_axis_tready_int_early;
                            2'd3: input_3_axis_tready_next = output_axis_tready_int_early;
                        endcase
                    end
                end
            end else begin
                state_next = STATE_TRANSFER;
            end 
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        frame_ptr_reg <= 0;
        port_sel_reg <= 0;
        input_0_axis_tready_reg <= 0;
        input_1_axis_tready_reg <= 0;
        input_2_axis_tready_reg <= 0;
        input_3_axis_tready_reg <= 0;
        output_tuser_reg <= 0;
        busy_reg <= 0;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        port_sel_reg <= port_sel_next;

        input_0_axis_tready_reg <= input_0_axis_tready_next;
        input_1_axis_tready_reg <= input_1_axis_tready_next;
        input_2_axis_tready_reg <= input_2_axis_tready_next;
        input_3_axis_tready_reg <= input_3_axis_tready_next;

        output_tuser_reg <= output_tuser_next;

        busy_reg <= state_next != STATE_IDLE;
    end
end

// output datapath logic
reg [7:0] output_axis_tdata_reg = 0;
reg       output_axis_tvalid_reg = 0;
reg       output_axis_tlast_reg = 0;
reg       output_axis_tuser_reg = 0;

reg [7:0] temp_axis_tdata_reg = 0;
reg       temp_axis_tvalid_reg = 0;
reg       temp_axis_tlast_reg = 0;
reg       temp_axis_tuser_reg = 0;

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
