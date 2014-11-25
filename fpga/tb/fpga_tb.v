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

//`timescale 1 ns / 1 ps
`timescale 1ps/1ps

module fpga_tb;

reg [7:0] current_test = 0;

// clocks
reg clk_10mhz_int = 0;
reg clk_10mhz_ext = 0;
wire clk_10mhz_out;

// SoC interface
reg cntrl_cs = 1;
reg cntrl_sck = 0;
reg cntrl_mosi = 0;
wire cntrl_miso;

// Trigger
reg ext_trig = 0;

// Frequency counter
reg ext_prescale = 0;

// Front end relay control
wire ferc_dat;
wire ferc_clk;
wire ferc_lat;

// Analog mux
wire [2:0] mux_s;

// ADC
wire adc_sclk;
reg adc_sdo = 0;
wire adc_sdi;
wire adc_cs;
reg adc_eoc = 0;
wire adc_convst;

// digital output
wire [15:0] dout;

// Sync DAC
wire [7:0] sync_dac;

// Main DAC
wire dac_clk_p;
wire dac_clk_n;
wire [15:0] dac_p1_d;
wire [15:0] dac_p2_d;
reg dac_sdo = 0;
wire dac_sdio;
wire dac_sclk;
wire dac_csb;
wire dac_reset;

// ram 1 MCB (U8)
wire ram1_cke;
wire ram1_ck_p;
wire ram1_ck_n;
wire ram1_cs_n;
wire ram1_ras_n;
wire ram1_cas_n;
wire ram1_we_n;
wire [12:0] ram1_a;
wire [2:0]  ram1_ba;
wire [15:0] ram1_dq;
wire ram1_ldqs_p;
wire ram1_ldqs_n;
wire ram1_ldm;
wire ram1_udqs_p;
wire ram1_udqs_n;
wire ram1_udm;
wire ram1_odt;
wire ram1_rzq;
wire ram1_zio;

// ram 2 MCB (U12)
wire ram2_cke;
wire ram2_ck_p;
wire ram2_ck_n;
wire ram2_cs_n;
wire ram2_ras_n;
wire ram2_cas_n;
wire ram2_we_n;
wire [12:0] ram2_a;
wire [2:0]  ram2_ba;
wire [15:0] ram2_dq;
wire ram2_ldqs_p;
wire ram2_ldqs_n;
wire ram2_ldm;
wire ram2_udqs_p;
wire ram2_udqs_n;
wire ram2_udm;
wire ram2_odt;
wire ram2_rzq;
wire ram2_zio;

reg clk_10mhz_ext_enable = 0;

always begin : clock10MHz
    clk_10mhz_int = 1'b1;
    #(50*1000);
    clk_10mhz_int = 1'b0;
    #(50*1000);
end

always begin : clock10MHz_ext
    clk_10mhz_ext = clk_10mhz_ext_enable;
    #(50*1000);
    clk_10mhz_ext = 1'b0;
    #(50*1000);
end

task spi_transfer;
    input [7:0] data_in;
    output [7:0] data_out;
    integer i;

    begin
        @(negedge clk_10mhz_int);
        cntrl_sck <= 0;
        for (i = 7; i >= 0; i = i - 1) begin
            cntrl_mosi <= data_in[i];
            @(posedge clk_10mhz_int);
            cntrl_sck <= 1;
            data_out[i] <= cntrl_miso;
            @(negedge clk_10mhz_int);
            cntrl_sck <= 0;
        end
    end
endtask

reg [7:0] temp;

initial begin : stimulus
    #500; @(posedge clk_10mhz_int); // wait for GSR

    #(50*1000*1000);

    // test ram 1 MCB write
    @(posedge clk_10mhz_int);
    cntrl_cs <= 0;
    @(posedge clk_10mhz_int);
    spi_transfer(8'hB0, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h20, temp);
    spi_transfer(8'h11, temp);
    spi_transfer(8'h22, temp);
    spi_transfer(8'h33, temp);
    spi_transfer(8'h44, temp);
    spi_transfer(8'h55, temp);
    spi_transfer(8'h66, temp);
    spi_transfer(8'h77, temp);
    @(posedge clk_10mhz_int);
    cntrl_cs <= 1;

    #(1*1000*1000);

    // test ram 1 MCB read
    @(posedge clk_10mhz_int);
    cntrl_cs <= 0;
    @(posedge clk_10mhz_int);
    spi_transfer(8'hA0, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h20, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    @(posedge clk_10mhz_int);
    cntrl_cs <= 1;

    #(1*1000*1000);

    // test ram 2 MCB write
    @(posedge clk_10mhz_int);
    cntrl_cs <= 0;
    @(posedge clk_10mhz_int);
    spi_transfer(8'hB1, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h20, temp);
    spi_transfer(8'h11, temp);
    spi_transfer(8'h22, temp);
    spi_transfer(8'h33, temp);
    spi_transfer(8'h44, temp);
    spi_transfer(8'h55, temp);
    spi_transfer(8'h66, temp);
    spi_transfer(8'h77, temp);
    @(posedge clk_10mhz_int);
    cntrl_cs <= 1;

    #(1*1000*1000);

    // test ram 2 MCB read
    @(posedge clk_10mhz_int);
    cntrl_cs <= 0;
    @(posedge clk_10mhz_int);
    spi_transfer(8'hA1, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h20, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    spi_transfer(8'h00, temp);
    @(posedge clk_10mhz_int);
    cntrl_cs <= 1;

    #(1*1000*1000);

    $finish;
end

fpga #(
    .SIMULATION("TRUE")
)
UUT (
    // clocks
    .clk_10mhz_int(clk_10mhz_int),
    .clk_10mhz_ext(clk_10mhz_ext),
    .clk_10mhz_out(clk_10mhz_out),

    // SoC interface
    .cntrl_cs(cntrl_cs),
    .cntrl_sck(cntrl_sck),
    .cntrl_mosi(cntrl_mosi),
    .cntrl_miso(cntrl_miso),

    // Trigger
    .ext_trig(ext_trig),

    // Frequency counter
    .ext_prescale(ext_prescale),

    // Front end relay control
    .ferc_dat(ferc_dat),
    .ferc_clk(ferc_clk),
    .ferc_lat(ferc_lat),

    // Analog mux
    .mux_s(mux_s),

    // ADC
    .adc_sclk(adc_sclk),
    .adc_sdo(adc_sdo),
    .adc_sdi(adc_sdi),
    .adc_cs(adc_cs),
    .adc_eoc(adc_eoc),
    .adc_convst(adc_convst),

    // digital output
    .dout(dout),

    // Sync DAC
    .sync_dac(sync_dac),

    // Main DAC
    .dac_clk_p(dac_clk_p),
    .dac_clk_n(dac_clk_n),
    .dac_p1_d(dac_p1_d),
    .dac_p2_d(dac_p2_d),
    .dac_sdo(dac_sdo),
    .dac_sdio(dac_sdio),
    .dac_sclk(dac_sclk),
    .dac_csb(dac_csb),
    .dac_reset(dac_reset),

    // ram 1 MCB (U8)
    .ram1_cke(ram1_cke),
    .ram1_ck_p(ram1_ck_p),
    .ram1_ck_n(ram1_ck_n),
    .ram1_cs_n(ram1_cs_n),
    .ram1_ras_n(ram1_ras_n),
    .ram1_cas_n(ram1_cas_n),
    .ram1_we_n(ram1_we_n),
    .ram1_a(ram1_a),
    .ram1_ba(ram1_ba),
    .ram1_dq(ram1_dq),
    .ram1_ldqs_p(ram1_ldqs_p),
    .ram1_ldqs_n(ram1_ldqs_n),
    .ram1_ldm(ram1_ldm),
    .ram1_udqs_p(ram1_udqs_p),
    .ram1_udqs_n(ram1_udqs_n),
    .ram1_udm(ram1_udm),
    .ram1_odt(ram1_odt),
    .ram1_rzq(ram1_rzq),
    .ram1_zio(ram1_zio),

    // ram 2 MCB (U12)
    .ram2_cke(ram2_cke),
    .ram2_ck_p(ram2_ck_p),
    .ram2_ck_n(ram2_ck_n),
    .ram2_cs_n(ram2_cs_n),
    .ram2_ras_n(ram2_ras_n),
    .ram2_cas_n(ram2_cas_n),
    .ram2_we_n(ram2_we_n),
    .ram2_a(ram2_a),
    .ram2_ba(ram2_ba),
    .ram2_dq(ram2_dq),
    .ram2_ldqs_p(ram2_ldqs_p),
    .ram2_ldqs_n(ram2_ldqs_n),
    .ram2_ldm(ram2_ldm),
    .ram2_udqs_p(ram2_udqs_p),
    .ram2_udqs_n(ram2_udqs_n),
    .ram2_udm(ram2_udm),
    .ram2_odt(ram2_odt),
    .ram2_rzq(ram2_rzq),
    .ram2_zio(ram2_zio)
);

PULLDOWN ram1_zio_pd (.O(ram1_zio));
PULLDOWN ram1_rzq_pd (.O(ram1_rzq));

ddr2_model_c3
ram1_inst (
    .ck         (ram1_ck_p),
    .ck_n       (ram1_ck_n),
    .cke        (ram1_cke),
    .cs_n       (1'b0),
    .ras_n      (ram1_ras_n),
    .cas_n      (ram1_cas_n),
    .we_n       (ram1_we_n),
    .dm_rdqs    ({ram1_udm,ram1_ldm}),
    .ba         (ram1_ba),
    .addr       (ram1_a),
    .dq         (ram1_dq),
    .dqs        ({ram1_udqs_p,ram1_ldqs_p}),
    .dqs_n      ({ram1_udqs_n,ram1_ldqs_n}),
    .rdqs_n     (),
    .odt        (ram1_odt)
);

PULLDOWN ram2_zio_pd (.O(ram2_zio));
PULLDOWN ram2_rzq_pd (.O(ram2_rzq));

ddr2_model_c3
ram2_inst (
    .ck         (ram2_ck_p),
    .ck_n       (ram2_ck_n),
    .cke        (ram2_cke),
    .cs_n       (1'b0),
    .ras_n      (ram2_ras_n),
    .cas_n      (ram2_cas_n),
    .we_n       (ram2_we_n),
    .dm_rdqs    ({ram2_udm,ram2_ldm}),
    .ba         (ram2_ba),
    .addr       (ram2_a),
    .dq         (ram2_dq),
    .dqs        ({ram2_udqs_p,ram2_ldqs_p}),
    .dqs_n      ({ram2_udqs_n,ram2_ldqs_n}),
    .rdqs_n     (),
    .odt        (ram2_odt)
);

endmodule
