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
module soc_interface_wb_32
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
     * Wishbone interface
     */
    output wire [35:0] wb_adr_o,   // ADR_O() address
    input  wire [31:0] wb_dat_i,   // DAT_I() data in
    output wire [31:0] wb_dat_o,   // DAT_O() data out
    output wire        wb_we_o,    // WE_O write enable output
    output wire [3:0]  wb_sel_o,   // SEL_O() select output
    output wire        wb_stb_o,   // STB_O strobe output
    input  wire        wb_ack_i,   // ACK_I acknowledge input
    input  wire        wb_err_i,   // ERR_I error input
    output wire        wb_cyc_o,   // CYC_O cycle output

    /*
     * Status
     */
    output wire        busy
);

// state register
localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_READ_ADDR = 3'd1,
    STATE_READ = 3'd2,
    STATE_WRITE = 3'd3,
    STATE_WAIT_LAST = 3'd4;

reg [2:0] state_reg = STATE_IDLE, state_next;

reg inc_addr_reg = 0, inc_addr_next;

reg [7:0] cmd_reg = 0, cmd_next;
reg [35:0] addr_reg = 0, addr_next;
reg [31:0] data_reg = 0, data_next;
reg data_valid_reg = 0, data_valid_next;
reg [1:0] byte_cnt_reg = 0, byte_cnt_next;

reg rd_data_valid_reg = 0, rd_data_valid_next;
reg [31:0] rd_data_reg = 0, rd_data_next;

reg [31:0] wr_data_reg = 0, wr_data_next;

reg input_axis_tready_reg = 0, input_axis_tready_next;

reg [7:0] output_axis_tdata_reg = 0, output_axis_tdata_next;
reg output_axis_tvalid_reg = 0, output_axis_tvalid_next;
reg output_axis_tlast_reg = 0, output_axis_tlast_next;

reg wb_we_reg = 0, wb_we_next;
reg [3:0] wb_sel_reg = 0, wb_sel_next;
reg wb_stb_reg = 0, wb_stb_next;
reg wb_cyc_reg = 0, wb_cyc_next;

reg busy_reg = 0;

assign input_axis_tready = input_axis_tready_reg;

assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast = output_axis_tlast_reg;

assign wb_adr_o = addr_reg;
assign wb_dat_o = wr_data_reg;
assign wb_we_o = wb_we_reg;
assign wb_sel_o = wb_sel_reg;
assign wb_stb_o = wb_stb_reg;
assign wb_cyc_o = wb_cyc_reg;

assign busy = busy_reg;

always @* begin
    state_next = 0;

    inc_addr_next = 0;

    cmd_next = cmd_reg;

    addr_next = addr_reg;
    if (inc_addr_reg) begin
        //addr_next = {addr_reg[35:2], 2'b00} + 4;
        addr_next[31:0] = {addr_reg[31:2], 2'b00} + 4;
    end

    data_next = data_reg;
    data_valid_next = data_valid_reg;
    byte_cnt_next = byte_cnt_reg;

    rd_data_valid_next = rd_data_valid_reg;
    rd_data_next = rd_data_reg;

    wr_data_next = wr_data_reg;

    input_axis_tready_next = 0;

    output_axis_tdata_next = output_axis_tdata_reg;
    output_axis_tvalid_next = output_axis_tvalid_reg & ~output_axis_tready;
    output_axis_tlast_next = output_axis_tlast_reg;

    wb_we_next = wb_we_reg;
    wb_sel_next = wb_sel_reg;
    wb_stb_next = wb_stb_reg;
    wb_cyc_next = wb_cyc_reg;

    case (state_reg)
        STATE_IDLE: begin
            input_axis_tready_next = ~wb_cyc_reg;
            data_valid_next = 0;
            byte_cnt_next = 0;
            if (input_axis_tready & input_axis_tvalid) begin
                // get command
                cmd_next = input_axis_tdata;
                if (input_axis_tlast) begin
                    // early end of frame
                    state_next = STATE_IDLE;
                end else if (cmd_next[7:4] == 4'hA || cmd_next[7:4] == 4'hB) begin
                    // read or write command
                    addr_next[35:32] = cmd_next[3:0];
                    state_next = STATE_READ_ADDR;
                end else begin
                    state_next = STATE_WAIT_LAST;
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_READ_ADDR: begin
            input_axis_tready_next = 1;
            data_next = 0;
            data_valid_next = 0;
            rd_data_valid_next = 0;
            wb_we_next = 0;
            if (input_axis_tready & input_axis_tvalid) begin
                // read address byte (MSB first)
                byte_cnt_next = byte_cnt_reg + 1;
                case (byte_cnt_reg)
                    2'd0: addr_next[31:24] = input_axis_tdata;
                    2'd1: addr_next[23:16] = input_axis_tdata;
                    2'd2: addr_next[15: 8] = input_axis_tdata;
                    2'd3: begin
                        addr_next[ 7: 0] = {input_axis_tdata[7:2], 2'b00};
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
                        wb_cyc_next = 1;
                        wb_stb_next = 1;
                        state_next = STATE_READ;
                    end else if (cmd_reg[7:4] == 4'hB) begin
                        // write command
                        case (byte_cnt_next[1:0])
                            2'd0: wb_sel_next = 4'b1111;
                            2'd1: wb_sel_next = 4'b1110;
                            2'd2: wb_sel_next = 4'b1100;
                            2'd3: wb_sel_next = 4'b1000;
                        endcase
                        state_next = STATE_WRITE;
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
        STATE_READ: begin
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
                end
            end
            state_next = STATE_READ;

            if (input_axis_tvalid & input_axis_tlast) begin
                // send zero with last set on frame end
                output_axis_tdata_next = 0;
                output_axis_tvalid_next = 1;
                output_axis_tlast_next = 1;
                state_next = STATE_IDLE;
            end

            if (!data_valid_next & rd_data_valid_reg) begin
                // read data word into register
                data_next = rd_data_reg;
                data_valid_next = 1;
                rd_data_valid_next = 0;
                // initiate a new read
                wb_cyc_next = 1;
                wb_stb_next = 1;
                wb_we_next = 0;
            end
        end
        STATE_WRITE: begin
            input_axis_tready_next = ~wb_cyc_reg;
            if (input_axis_tready & input_axis_tvalid) begin
                // got data byte
                byte_cnt_next = byte_cnt_reg + 1;
                case (byte_cnt_reg)
                    2'd0: wr_data_next[ 7: 0] = input_axis_tdata;
                    2'd1: wr_data_next[15: 8] = input_axis_tdata;
                    2'd2: wr_data_next[23:16] = input_axis_tdata;
                    2'd3: wr_data_next[31:24] = input_axis_tdata;
                endcase
                if (input_axis_tlast || byte_cnt_reg == 3) begin
                    // end of frame or end of word
                    // calculate mask
                    case (byte_cnt_reg[1:0])
                        2'd0: wb_sel_next = wb_sel_reg & 4'b0001;
                        2'd1: wb_sel_next = wb_sel_reg & 4'b0011;
                        2'd2: wb_sel_next = wb_sel_reg & 4'b0111;
                        2'd3: wb_sel_next = wb_sel_reg & 4'b1111;
                    endcase
                    // write
                    wb_cyc_next = 1;
                    wb_stb_next = 1;
                    wb_we_next = 1;
                    input_axis_tready_next = 0;
                    if (input_axis_tlast) begin
                        state_next = STATE_IDLE;
                    end else begin
                        state_next = STATE_WRITE;
                    end
                end else begin
                    state_next = STATE_WRITE;
                end
            end else begin
                state_next = STATE_WRITE;
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

    if (wb_cyc_reg & wb_stb_reg) begin
        // WB cycle
        if (wb_ack_i | wb_err_i) begin
            // end of cycle
            wb_cyc_next = 0;
            wb_stb_next = 0;
            wb_we_next = 0;
            wb_sel_next = 4'b1111;
            inc_addr_next = 1;
            if (wb_we_reg) begin
                // write
            end else begin
                // read
                rd_data_next = wb_dat_i;
                rd_data_valid_next = 1;
            end
        end
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        inc_addr_reg <= 0;
        cmd_reg <= 0;
        addr_reg <= 0;
        data_reg <= 0;
        data_valid_reg <= 0;
        byte_cnt_reg <= 0;
        rd_data_valid_reg <= 0;
        rd_data_reg <= 0;
        wr_data_reg <= 0;
        input_axis_tready_reg <= 0;
        output_axis_tdata_reg <= 0;
        output_axis_tvalid_reg <= 0;
        output_axis_tlast_reg <= 0;
        wb_we_reg <= 0;
        wb_sel_reg <= 0;
        wb_stb_reg <= 0;
        wb_cyc_reg <= 0;
        busy_reg <= 0;
    end else begin
        state_reg <= state_next;

        inc_addr_reg <= inc_addr_next;

        cmd_reg <= cmd_next;
        addr_reg <= addr_next;
        data_reg <= data_next;
        data_valid_reg <= data_valid_next;
        byte_cnt_reg <= byte_cnt_next;

        rd_data_valid_reg <= rd_data_valid_next;
        rd_data_reg <= rd_data_next;

        wr_data_reg <= wr_data_next;

        input_axis_tready_reg <= input_axis_tready_next;

        output_axis_tdata_reg <= output_axis_tdata_next;
        output_axis_tvalid_reg <= output_axis_tvalid_next;
        output_axis_tlast_reg <= output_axis_tlast_next;

        wb_we_reg <= wb_we_next;
        wb_sel_reg <= wb_sel_next;
        wb_stb_reg <= wb_stb_next;
        wb_cyc_reg <= wb_cyc_next;
        
        busy_reg <= state_next != STATE_IDLE;
    end
end

endmodule
