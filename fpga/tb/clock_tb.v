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

module clock_tb;

// parameters 

// inputs
reg reset_in = 0;
reg clk_10mhz_int = 0;
reg clk_10mhz_ext = 0;

// outputs
wire clk_250mhz_int;
wire rst_250mhz_int;
wire clk_250mhz;
wire rst_250mhz;

wire ext_clock_selected;

reg clk_10mhz_ext_enable = 0;

always begin : clock10MHz
    clk_10mhz_int = 1'b1;
    #101;
    clk_10mhz_int = 1'b0;
    #101;
end

always begin : clock10MHz_ext
    clk_10mhz_ext = clk_10mhz_ext_enable;
    #100;
    clk_10mhz_ext = 1'b0;
    #100;
end

initial begin : stimulus
    #500; @(posedge clk_10mhz_int); // wait for GSR
    // reset pulse
    reset_in <= 1; @(posedge clk_10mhz_int);
    reset_in <= 0; @(posedge clk_10mhz_int);
    #500; @(posedge clk_10mhz_int);

    // wait for inernal clock to lock
    #20000;

    // enable external clock
    clk_10mhz_ext_enable <= 1;

    // wait for external clock to lock and clock switchover
    #500000;

    // disable external clock
    clk_10mhz_ext_enable <= 0;

    // wait for clock switchover
    #20000;

    $finish;
end

clock
UUT (
    .reset_in(reset_in),

    .clk_10mhz_int(clk_10mhz_int),
    .clk_10mhz_ext(clk_10mhz_ext),

    .clk_250mhz_int(clk_250mhz_int),
    .rst_250mhz_int(rst_250mhz_int),

    .clk_250mhz(clk_250mhz),
    .rst_250mhz(rst_250mhz),

    .ext_clock_selected(ext_clock_selected)
);

endmodule
