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
 * AXI4-Stream SPI Slave
 */
module axis_spi_slave #
(
    parameter DATA_WIDTH = 8
)
(
    input  wire                   clk,
    input  wire                   rst,

    /*
     * AXI input
     */
    input  wire [DATA_WIDTH-1:0]  input_axis_tdata,
    input  wire                   input_axis_tvalid,
    output wire                   input_axis_tready,
    input  wire                   input_axis_tlast,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]  output_axis_tdata,
    output wire                   output_axis_tvalid,
    input  wire                   output_axis_tready,
    output wire                   output_axis_tlast,

    /*
     * SPI interface
     */
    input  wire                   cs,
    input  wire                   sck,
    input  wire                   mosi,
    output wire                   miso,

    /*
     * Status
     */
    output wire                   busy
);

// state register
localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_TRANSFER = 2'd1,
    STATE_WAIT = 2'd2;

reg [1:0] state_reg = STATE_IDLE, state_next;

reg [DATA_WIDTH-1:0] tx_data_reg = 0, tx_data_next;
reg [DATA_WIDTH-1:0] rx_data_reg = 0, rx_data_next;
reg [4:0] bit_cnt_reg = 0, bit_cnt_next;

reg input_axis_tready_reg = 0, input_axis_tready_next;

reg [DATA_WIDTH-1:0] output_axis_tdata_reg = 0, output_axis_tdata_next;
reg output_axis_tvalid_reg = 0, output_axis_tvalid_next;
reg output_axis_tlast_reg = 0, output_axis_tlast_next;

reg miso_reg = 0, miso_next;

reg busy_reg = 0;

assign input_axis_tready = input_axis_tready_reg;

assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast = output_axis_tlast_reg;

assign miso = miso_reg;

assign busy = busy_reg;

reg sck_last = 0;
wire sck_posedge = sck & !sck_last;
wire sck_negedge = !sck & sck_last;

always @* begin
    state_next = 0;

    tx_data_next = tx_data_reg;
    rx_data_next = rx_data_reg;

    bit_cnt_next = bit_cnt_reg;

    input_axis_tready_next = 0;

    output_axis_tdata_next = output_axis_tdata_reg;
    output_axis_tvalid_next = output_axis_tvalid_reg & ~output_axis_tready;
    output_axis_tlast_next = output_axis_tlast_reg;

    miso_next = miso_reg;

    case (state_reg)
        STATE_IDLE: begin
            if (cs) begin
                // cs deasserted
                miso_next = 0;
                state_next = STATE_IDLE;
            end else begin
                // cs asserted - start of frame
                if (input_axis_tvalid) begin
                    // input data valid, read it in
                    {miso_next, tx_data_next[DATA_WIDTH-1:1]} = input_axis_tdata;
                    input_axis_tready_next = 1;
                end else begin
                    // input data not valid, send filler
                    miso_next = 0;
                    tx_data_next = 0;
                end
                rx_data_next = 0;
                bit_cnt_next = DATA_WIDTH-1;
                state_next = STATE_TRANSFER;
            end
        end
        STATE_TRANSFER: begin
            if (sck_posedge) begin
                // rising sck edge, read mosi
                rx_data_next = {rx_data_reg[DATA_WIDTH-2:0], mosi};
                state_next = STATE_TRANSFER;
            end else if (sck_negedge) begin
                // falling sck edge, write miso
                if (bit_cnt_reg > 0) begin
                    // not last edge, pull from buffer
                    {miso_next, tx_data_next[DATA_WIDTH-1:1]} = tx_data_reg;
                    bit_cnt_next = bit_cnt_reg - 1;
                    state_next = STATE_TRANSFER;
                end else begin
                    // last falling edge, look ahead
                    if (input_axis_tvalid) begin
                        // grab next bit from buffer if available
                        {miso_next, tx_data_next[DATA_WIDTH-1:1]} = input_axis_tdata;
                    end else begin
                        // otherwise send filler
                        miso_next = 0;
                        tx_data_next = 0;
                    end
                    // wait for next event (don't know if end of frame yet)
                    state_next = STATE_WAIT;
                end
            end else if (cs) begin
                // premature end of frame
                output_axis_tdata_next = 0;
                output_axis_tvalid_next = 1;
                output_axis_tlast_next = 1;
                state_next = STATE_IDLE;
            end else begin
                state_next = STATE_TRANSFER;
            end
        end
        STATE_WAIT: begin
            if (cs) begin
                // end of frame, transfer out
                output_axis_tdata_next = rx_data_reg;
                output_axis_tvalid_next = 1;
                output_axis_tlast_next = 1;
                state_next = STATE_IDLE;
            end else if (sck_posedge) begin
                // continuing frame, transfer out
                output_axis_tdata_next = rx_data_reg;
                output_axis_tvalid_next = 1;
                output_axis_tlast_next = 0;
                // read in new byte
                if (input_axis_tvalid) begin
                    {miso_next, tx_data_next[DATA_WIDTH-1:1]} = input_axis_tdata;
                    input_axis_tready_next = 1;
                end else begin
                    miso_next = 0;
                    tx_data_next = 0;
                end
                rx_data_next = mosi;
                bit_cnt_next = DATA_WIDTH-1;
                state_next = STATE_TRANSFER;
            end else begin
                state_next = STATE_WAIT;
            end
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        tx_data_reg <= 0;
        rx_data_reg <= 0;
        bit_cnt_reg <= 0;
        sck_last <= 0;
        input_axis_tready_reg <= 0;
        output_axis_tdata_reg <= 0;
        output_axis_tvalid_reg <= 0;
        output_axis_tlast_reg <= 0;
        miso_reg <= 0;
        busy_reg <= 0;
    end else begin
        state_reg <= state_next;

        tx_data_reg <= tx_data_next;
        rx_data_reg <= rx_data_next;

        bit_cnt_reg <= bit_cnt_next;

        sck_last <= sck;

        input_axis_tready_reg <= input_axis_tready_next;

        output_axis_tdata_reg <= output_axis_tdata_next;
        output_axis_tvalid_reg <= output_axis_tvalid_next;
        output_axis_tlast_reg <= output_axis_tlast_next;

        miso_reg <= miso_next;
        
        busy_reg <= state_next != STATE_IDLE;
    end
end

endmodule
