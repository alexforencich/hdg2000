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

`timescale 1 ns / 1 ps

module test_arbiter_rr;

// parameters
localparam PORTS = 32;
localparam TYPE = "ROUND_ROBIN";
localparam BLOCK = "REQUEST";

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [PORTS-1:0] request = 0;
reg [PORTS-1:0] acknowledge = 0;

// Outputs
wire [PORTS-1:0] grant;
wire grant_valid;
wire [$clog2(PORTS)-1:0] grant_encoded;

initial begin
    // myhdl integration
    $from_myhdl(clk,
                rst,
                current_test,
                request,
                acknowledge);
    $to_myhdl(grant,
              grant_valid,
              grant_encoded);

    // dump file
    $dumpfile("test_arbiter_rr.lxt");
    $dumpvars(0, test_arbiter_rr);
end

arbiter #(
    .PORTS(PORTS),
    .TYPE(TYPE),
    .BLOCK(BLOCK)
)
UUT (
    .clk(clk),
    .rst(rst),
    .request(request),
    .acknowledge(acknowledge),
    .grant(grant),
    .grant_valid(grant_valid),
    .grant_encoded(grant_encoded)
);

endmodule
