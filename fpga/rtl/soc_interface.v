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
 * SoC Interface
 */
module soc_interface
(
    input  wire        clk,
    input  wire        rst,

    /*
     * AXI input
     */
    input  wire [7:0]  input_axis_tdata,
    input  wire        input_axis_tvalid,
    output wire        input_axis_tready,
    input  wire        input_axis_tlast,

    /*
     * AXI output
     */
    output wire [7:0]  output_axis_tdata,
    output wire        output_axis_tvalid,
    input  wire        output_axis_tready,
    output wire        output_axis_tlast,

    /*
     * MCB interface port 0
     */
    output wire        port0_cmd_clk,
    output wire        port0_cmd_en,
    output wire [2:0]  port0_cmd_instr,
    output wire [5:0]  port0_cmd_bl,
    output wire [31:0] port0_cmd_byte_addr,
    input  wire        port0_cmd_empty,
    input  wire        port0_cmd_full,
    output wire        port0_wr_clk,
    output wire        port0_wr_en,
    output wire [3:0]  port0_wr_mask,
    output wire [31:0] port0_wr_data,
    input  wire        port0_wr_empty,
    input  wire        port0_wr_full,
    input  wire        port0_wr_underrun,
    input  wire [6:0]  port0_wr_count,
    input  wire        port0_wr_error,
    output wire        port0_rd_clk,
    output wire        port0_rd_en,
    input  wire [31:0] port0_rd_data,
    input  wire        port0_rd_empty,
    input  wire        port0_rd_full,
    input  wire        port0_rd_overflow,
    input  wire [6:0]  port0_rd_count,
    input  wire        port0_rd_error,

    /*
     * MCB interface port 1
     */
    output wire        port1_cmd_clk,
    output wire        port1_cmd_en,
    output wire [2:0]  port1_cmd_instr,
    output wire [5:0]  port1_cmd_bl,
    output wire [31:0] port1_cmd_byte_addr,
    input  wire        port1_cmd_empty,
    input  wire        port1_cmd_full,
    output wire        port1_wr_clk,
    output wire        port1_wr_en,
    output wire [3:0]  port1_wr_mask,
    output wire [31:0] port1_wr_data,
    input  wire        port1_wr_empty,
    input  wire        port1_wr_full,
    input  wire        port1_wr_underrun,
    input  wire [6:0]  port1_wr_count,
    input  wire        port1_wr_error,
    output wire        port1_rd_clk,
    output wire        port1_rd_en,
    input  wire [31:0] port1_rd_data,
    input  wire        port1_rd_empty,
    input  wire        port1_rd_full,
    input  wire        port1_rd_overflow,
    input  wire [6:0]  port1_rd_count,
    input  wire        port1_rd_error,

    /*
     * Status
     */
    output wire        busy
);

// state register
localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_READ_ADDR = 3'd1,
    STATE_MCB_READ = 3'd2,
    STATE_MCB_WRITE = 3'd3,
    STATE_WAIT_LAST = 3'd4;

reg [2:0] state_reg = STATE_IDLE, state_next;

reg inc_addr_reg = 0, inc_addr_next;

reg rd_empty;
reg [31:0] rd_data;

reg cmd_en;
reg wr_en;
reg rd_en;

reg [7:0] cmd_reg = 0, cmd_next;
reg [31:0] addr_reg = 0, addr_next;
reg [31:0] data_reg = 0, data_next;
reg data_valid_reg = 0, data_valid_next;
reg [3:0] bank_reg = 0, bank_next;
reg [1:0] byte_cnt_reg = 0, byte_cnt_next;

reg input_axis_tready_reg = 0, input_axis_tready_next;

reg [7:0] output_axis_tdata_reg = 0, output_axis_tdata_next;
reg output_axis_tvalid_reg = 0, output_axis_tvalid_next;
reg output_axis_tlast_reg = 0, output_axis_tlast_next;

reg port0_cmd_en_reg = 0, port0_cmd_en_next;
reg port1_cmd_en_reg = 0, port1_cmd_en_next;
reg [2:0] port_cmd_instr_reg = 0, port_cmd_instr_next;
reg [5:0] port_cmd_bl_reg = 0, port_cmd_bl_next;
reg [31:0] port_cmd_byte_addr_reg = 0, port_cmd_byte_addr_next;
reg port0_wr_en_reg = 0, port0_wr_en_next;
reg port1_wr_en_reg = 0, port1_wr_en_next;
reg [3:0] port_wr_mask_reg = 0, port_wr_mask_next;
reg [31:0] port_wr_data_reg = 0, port_wr_data_next;
reg port0_rd_en_reg = 0, port0_rd_en_next;
reg port1_rd_en_reg = 0, port1_rd_en_next;

reg busy_reg = 0;

assign input_axis_tready = input_axis_tready_reg;

assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast = output_axis_tlast_reg;

assign port0_cmd_clk = clk;
assign port0_cmd_en = port0_cmd_en_reg;
assign port0_cmd_instr = port_cmd_instr_reg;
assign port0_cmd_bl = port_cmd_bl_reg;
assign port0_cmd_byte_addr = port_cmd_byte_addr_reg;
assign port0_wr_clk = clk;
assign port0_wr_en = port0_wr_en_reg;
assign port0_wr_mask = port_wr_mask_reg;
assign port0_wr_data = port_wr_data_reg;
assign port0_rd_clk = clk;
assign port0_rd_en = port0_rd_en_reg;

assign port1_cmd_clk = clk;
assign port1_cmd_en = port1_cmd_en_reg;
assign port1_cmd_instr = port_cmd_instr_reg;
assign port1_cmd_bl = port_cmd_bl_reg;
assign port1_cmd_byte_addr = port_cmd_byte_addr_reg;
assign port1_wr_clk = clk;
assign port1_wr_en = port1_wr_en_reg;
assign port1_wr_mask = port_wr_mask_reg;
assign port1_wr_data = port_wr_data_reg;
assign port1_rd_clk = clk;
assign port1_rd_en = port1_rd_en_reg;

assign busy = busy_reg;

// registers for timing
reg port0_rd_empty_reg = 0;
reg [31:0] port0_rd_data_reg = 0;
reg port1_rd_empty_reg = 0;
reg [31:0] port1_rd_data_reg = 0;
always @(posedge clk) begin
    port0_rd_empty_reg <= port0_rd_empty;
    port0_rd_data_reg <= port0_rd_data;
    port1_rd_empty_reg <= port1_rd_empty;
    port1_rd_data_reg <= port1_rd_data;
end

// read data mux
always @(posedge clk) begin
    case (bank_reg)
        4'd0: begin
            rd_empty <= port0_rd_empty_reg;
            rd_data <= port0_rd_data_reg;
        end
        4'd1: begin
            rd_empty <= port1_rd_empty_reg;
            rd_data <= port1_rd_data_reg;
        end
        default: begin
            rd_empty <= 0;
            rd_data <= 0;
        end
    endcase
end

always @* begin
    state_next = 0;

    inc_addr_next = 0;

    cmd_en = 0;
    wr_en = 0;
    rd_en = 0;

    cmd_next = cmd_reg;
    if (inc_addr_reg) begin
        port_cmd_byte_addr_next = {port_cmd_byte_addr_reg[31:2], 2'b00} + 4;
    end else begin
        port_cmd_byte_addr_next = port_cmd_byte_addr_reg;
    end
    data_next = data_reg;
    data_valid_next = data_valid_reg;
    bank_next = bank_reg;
    byte_cnt_next = byte_cnt_reg;

    input_axis_tready_next = 0;

    output_axis_tdata_next = output_axis_tdata_reg;
    output_axis_tvalid_next = output_axis_tvalid_reg & ~output_axis_tready;
    output_axis_tlast_next = output_axis_tlast_reg;

    port0_cmd_en_next = 0;
    port1_cmd_en_next = 0;
    port_cmd_instr_next = port_cmd_instr_reg;
    port_cmd_bl_next = port_cmd_bl_reg;
    port0_wr_en_next = 0;
    port1_wr_en_next = 0;
    port_wr_mask_next = port_wr_mask_reg;
    port_wr_data_next = port_wr_data_reg;
    port0_rd_en_next = 0;
    port1_rd_en_next = 0;

    case (state_reg)
        STATE_IDLE: begin
            input_axis_tready_next = 1;
            rd_en = 1;
            data_valid_next = 0;
            if (input_axis_tready & input_axis_tvalid) begin
                // get command
                cmd_next = input_axis_tdata;
                if (cmd_next[7:4] == 4'hA) begin
                    // read command
                    bank_next = cmd_next[3:0];
                    byte_cnt_next = 0;
                    state_next = STATE_READ_ADDR;
                    if (bank_next == 0 || bank_next == 1 || bank_next == 15) begin
                        state_next = STATE_READ_ADDR;
                    end else begin
                        // invalid bank
                        state_next = STATE_WAIT_LAST;
                    end
                end else if (cmd_next[7:4] == 4'hB) begin
                    // write command
                    bank_next = cmd_next[3:0];
                    byte_cnt_next = 0;
                    state_next = STATE_READ_ADDR;
                    if (bank_next == 0 || bank_next == 1 || bank_next == 15) begin
                        state_next = STATE_READ_ADDR;
                    end else begin
                        // invalid bank
                        state_next = STATE_WAIT_LAST;
                    end
                end else begin
                    state_next = STATE_WAIT_LAST;
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_READ_ADDR: begin
            input_axis_tready_next = 1;
            if (input_axis_tready & input_axis_tvalid) begin
                // read address byte (MSB first)
                byte_cnt_next = byte_cnt_reg + 1;
                case (byte_cnt_reg)
                    2'd0: port_cmd_byte_addr_next[31:24] = input_axis_tdata;
                    2'd1: port_cmd_byte_addr_next[23:16] = input_axis_tdata;
                    2'd2: port_cmd_byte_addr_next[15: 8] = input_axis_tdata;
                    2'd3: begin
                        port_cmd_byte_addr_next[ 7: 0] = {input_axis_tdata[7:2], 2'b00};
                        byte_cnt_next = input_axis_tdata[1:0];
                    end
                endcase
                if (input_axis_tlast) begin
                    // early end of frame
                    state_next = STATE_IDLE;
                end else if (byte_cnt_reg == 3) begin
                    // last address byte, process command
                    if (cmd_reg[7:4] == 4'hA) begin
                        // read command
                        // initiate read, length 1
                        port_cmd_instr_next = 3'b001;
                        port_cmd_bl_next = 5'd0;
                        cmd_en = 1;
                        inc_addr_next = 1;
                        state_next = STATE_MCB_READ;
                    end else if (cmd_reg[7:4] == 4'hB) begin
                        // write command
                        case (byte_cnt_next[1:0])
                            2'd0: port_wr_mask_next = 4'b1111;
                            2'd1: port_wr_mask_next = 4'b1110;
                            2'd2: port_wr_mask_next = 4'b1100;
                            2'd3: port_wr_mask_next = 4'b1000;
                        endcase
                        data_next = 0;
                        state_next = STATE_MCB_WRITE;
                    end else begin
                        state_next = STATE_WAIT_LAST;
                    end
                end else begin
                    state_next = STATE_READ_ADDR;
                end
            end else begin
                state_next = STATE_READ_ADDR;
            end
        end
        STATE_MCB_READ: begin
            input_axis_tready_next = 1;
            if (!output_axis_tvalid & data_valid_reg) begin
                // send start flag
                output_axis_tdata_next = 1;
                output_axis_tvalid_next = 1;
                output_axis_tlast_next = 0;
            end else if (output_axis_tready & data_valid_reg) begin
                // send read data
                byte_cnt_next = byte_cnt_reg + 1;
                output_axis_tvalid_next = 1;
                case (byte_cnt_reg)
                    2'd0: output_axis_tdata_next = data_reg[ 7: 0];
                    2'd1: output_axis_tdata_next = data_reg[15: 8];
                    2'd2: output_axis_tdata_next = data_reg[23:16];
                    2'd3: output_axis_tdata_next = data_reg[31:24];
                endcase
                // invalidate data reg on byte count rollover
                if (byte_cnt_reg == 3) begin
                    data_valid_next = 0;
                    byte_cnt_next = 0;
                end
            end
            state_next = STATE_MCB_READ;

            if (input_axis_tvalid & input_axis_tlast) begin
                // send zero with last set on frame end
                output_axis_tvalid_next = 1;
                output_axis_tlast_next = 1;
                output_axis_tdata_next = 0;
                state_next = STATE_IDLE;
            end 

            if (!data_valid_next & !rd_empty) begin
                // read data word into register
                data_next = rd_data;
                data_valid_next = 1;
                // initiate a new read
                port_cmd_instr_next = 3'b001;
                port_cmd_bl_next = 5'd0;
                cmd_en = 1;
                rd_en = 1;
                inc_addr_next = 1;
            end
        end
        STATE_MCB_WRITE: begin
            input_axis_tready_next = 1;
            if (input_axis_tready & input_axis_tvalid) begin
                // got data byte
                byte_cnt_next = byte_cnt_reg + 1;
                case (byte_cnt_reg)
                    2'd0: port_wr_data_next[ 7: 0] = input_axis_tdata;
                    2'd1: port_wr_data_next[15: 8] = input_axis_tdata;
                    2'd2: port_wr_data_next[23:16] = input_axis_tdata;
                    2'd3: port_wr_data_next[31:24] = input_axis_tdata;
                endcase
                if (input_axis_tlast || byte_cnt_reg == 3) begin
                    // end of frame or end of word
                    // calculate mask
                    case (byte_cnt_reg[1:0])
                        2'd0: port_wr_mask_next = port_wr_mask_next & 4'b0001;
                        2'd1: port_wr_mask_next = port_wr_mask_next & 4'b0011;
                        2'd2: port_wr_mask_next = port_wr_mask_next & 4'b0111;
                        2'd3: port_wr_mask_next = port_wr_mask_next & 4'b1111;
                    endcase
                    // write, burst length 1
                    port_cmd_instr_next = 3'b000;
                    port_cmd_bl_next = 5'd0;
                    cmd_en = 1;
                    wr_en = 1;
                    // increment address
                    inc_addr_next = 1;
                    if (input_axis_tlast) begin
                        state_next = STATE_IDLE;
                    end else begin
                        state_next = STATE_MCB_WRITE;
                    end
                end else begin
                    state_next = STATE_MCB_WRITE;
                end
            end else begin
                state_next = STATE_MCB_WRITE;
            end
        end
        STATE_WAIT_LAST: begin
            input_axis_tready_next = 1;
            if (input_axis_tready & input_axis_tvalid & input_axis_tlast) begin
                state_next = STATE_IDLE;
            end else begin
                state_next = STATE_WAIT_LAST;
            end
        end
    endcase

    // command demux
    case (bank_reg)
        4'd0: begin
            port0_cmd_en_next = cmd_en;
            port0_wr_en_next = wr_en;
            port0_rd_en_next = rd_en;
        end
        4'd1: begin
            port1_cmd_en_next = cmd_en;
            port1_wr_en_next = wr_en;
            port1_rd_en_next = rd_en;
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        inc_addr_reg <= 0;
        cmd_reg <= 0;
        addr_reg <= 0;
        data_reg <= 0;
        data_valid_reg <= 0;
        bank_reg <= 0;
        byte_cnt_reg <= 0;
        input_axis_tready_reg <= 0;
        output_axis_tdata_reg <= 0;
        output_axis_tvalid_reg <= 0;
        output_axis_tlast_reg <= 0;
        port0_cmd_en_reg <= 0;
        port1_cmd_en_reg <= 0;
        port_cmd_instr_reg <= 0;
        port_cmd_bl_reg <= 0;
        port_cmd_byte_addr_reg <= 0;
        port0_wr_en_reg <= 0;
        port1_wr_en_reg <= 0;
        port_wr_mask_reg <= 0;
        port_wr_data_reg <= 0;
        port0_rd_en_reg <= 0;
        port1_rd_en_reg <= 0;
        busy_reg <= 0;
    end else begin
        state_reg <= state_next;

        inc_addr_reg <= inc_addr_next;

        cmd_reg <= cmd_next;
        addr_reg <= addr_next;
        data_reg <= data_next;
        data_valid_reg <= data_valid_next;
        bank_reg <= bank_next;
        byte_cnt_reg <= byte_cnt_next;

        input_axis_tready_reg <= input_axis_tready_next;

        output_axis_tdata_reg <= output_axis_tdata_next;
        output_axis_tvalid_reg <= output_axis_tvalid_next;
        output_axis_tlast_reg <= output_axis_tlast_next;

        port0_cmd_en_reg <= port0_cmd_en_next;
        port1_cmd_en_reg <= port1_cmd_en_next;
        port_cmd_instr_reg <= port_cmd_instr_next;
        port_cmd_bl_reg <= port_cmd_bl_next;
        port_cmd_byte_addr_reg <= port_cmd_byte_addr_next;
        port0_wr_en_reg <= port0_wr_en_next;
        port1_wr_en_reg <= port1_wr_en_next;
        port_wr_mask_reg <= port_wr_mask_next;
        port_wr_data_reg <= port_wr_data_next;
        port0_rd_en_reg <= port0_rd_en_next;
        port1_rd_en_reg <= port1_rd_en_next;
        
        busy_reg <= state_next != STATE_IDLE;
    end
end

endmodule
