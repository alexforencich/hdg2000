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
 * SRL-based FIFO register (Tds ~ 100 ps)
 */
module srl_fifo_reg #
(
    parameter WIDTH = 8
)
(
    input  wire                       clk,
    input  wire                       rst,

    input  wire                       write_en, // input valid
    input  wire [WIDTH-1:0]           write_data,
    input  wire                       read_en, // output ready
    output wire [WIDTH-1:0]           read_data,
    output wire                       full, // input not ready
    output wire                       empty // output not valid
);

reg [WIDTH-1:0] data_reg[1:0];
reg valid_reg[1:0];
reg ptr_reg = 0;
reg full_reg = 0;

assign read_data = data_reg[ptr_reg];
assign full = full_reg;
assign empty = ~valid_reg[ptr_reg];

wire [WIDTH-1:0] data_reg_0 = data_reg[0];
wire [WIDTH-1:0] data_reg_1 = data_reg[1];
wire valid_reg_0 = valid_reg[0];
wire valid_reg_1 = valid_reg[1];

reg shift;

integer i;

initial begin
    for (i = 0; i < 2; i = i + 1) begin
        data_reg[i] <= 0;
        valid_reg[i] <= 0;
    end
end

always @(posedge clk) begin
    if (rst) begin
        ptr_reg <= 0;
    end else begin
        // transfer empty to full
        full_reg <= ~read_en & ~empty;

        // transfer in if not full
        if (~full_reg) begin
            data_reg[0] <= write_data;
            valid_reg[0] <= write_en;
            for (i = 0; i < 1; i = i + 1) begin
                data_reg[i+1] <= data_reg[i];
                valid_reg[i+1] <= valid_reg[i];
            end
            ptr_reg <= valid_reg[0];
        end

        if (read_en) begin
            ptr_reg <= 0;
        end
    end
end

endmodule
