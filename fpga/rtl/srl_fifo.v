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
 * SRL-based FIFO (Tds ~ 100 ps)
 */
module srl_fifo #
(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)
(
    input  wire                       clk,
    input  wire                       rst,

    input  wire                       write_en,
    input  wire [WIDTH-1:0]           write_data,
    input  wire                       read_en,
    output wire [WIDTH-1:0]           read_data,
    output wire                       full,
    output wire                       empty,
    output wire [$clog2(DEPTH+1)-1:0] count
);

reg [WIDTH-1:0] data_reg[DEPTH-1:0];
reg [$clog2(DEPTH+1)-1:0] ptr_reg = 0, ptr_next;
reg full_reg = 0, full_next;
reg empty_reg = 1, empty_next;

assign read_data = data_reg[ptr_reg-1];
assign full = full_reg;
assign empty = empty_reg;
assign count = ptr_reg;

wire [WIDTH-1:0] data_reg_0 = data_reg[0];
wire [WIDTH-1:0] data_reg_1 = data_reg[1];
//wire [WIDTH-1:0] data_reg_2 = data_reg[2];
//wire [WIDTH-1:0] data_reg_3 = data_reg[3];

wire ptr_empty = ptr_reg == 0;
wire ptr_empty1 = ptr_reg == 1;
wire ptr_full = ptr_reg == DEPTH;
wire ptr_full1 = ptr_reg == DEPTH-1;

reg shift;
reg inc;
reg dec;

integer i;

initial begin
    for (i = 0; i < DEPTH; i = i + 1) begin
        data_reg[i] <= 0;
    end
end

always @* begin
    shift = 0;
    inc = 0;
    dec = 0;
    ptr_next = ptr_reg;
    full_next = full_reg;
    empty_next = empty_reg;

    if (read_en & write_en) begin
        shift = 1;
    end else if (read_en & ~empty) begin
        dec = 1;
        full_next = 0;
        empty_next = ptr_empty1;
    end else if (write_en & ~full) begin
        shift = 1;
        inc = 1;
        full_next = ptr_full1;
        empty_next = 0;
    end
end

always @(posedge clk) begin
    if (rst) begin
        ptr_reg <= 0;
    end else begin
        if (shift) begin
            data_reg[0] <= write_data;
            for (i = 0; i < DEPTH-1; i = i + 1) begin
                data_reg[i+1] <= data_reg[i];
            end
        end

        if (inc) begin
            ptr_reg <= ptr_reg + 1;
        end else if (dec) begin
            ptr_reg <= ptr_reg - 1;
        end else begin
            ptr_reg <= ptr_reg;
        end

        //full_reg <= ptr_next == DEPTH;
        //empty_reg <= ptr_next == 0;

        //full_reg <= (ptr_reg == DEPTH && ~(~write_en & read_en)) || (ptr_reg == (DEPTH-1) && (write_en & ~read_en));
        //empty_reg <= (ptr_reg == 0 && ~(~read_en & write_en)) || (ptr_reg == 1 && (read_en & ~write_en));

        //full_reg <= (ptr_full && ~(~write_en & read_en)) || (ptr_full1 && (write_en & ~read_en));
        //empty_reg <= (ptr_empty && ~(~read_en & write_en)) || (ptr_empty1 && (read_en & ~write_en));

        full_reg <= full_next;
        empty_reg <= empty_next;
    end
end

endmodule
