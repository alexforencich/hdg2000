#!/usr/bin/env python2
"""

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

"""

from myhdl import *
import os
from Queue import Queue

import spi_ep
import mcb

module = 'fpga_core'

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/axis_spi_slave.v")
srcs.append("../rtl/soc_interface_wb_32.v")
srcs.append("../rtl/wb_mcb.v")
srcs.append("../rtl/srl_fifo_reg.v")
srcs.append("../lib/wb/rtl/wb_mux_3.v")
srcs.append("../lib/wb/rtl/wb_async_reg.v")
srcs.append("../lib/wb/rtl/wb_ram.v")
srcs.append("test_%s.v" % module)

src = ' '.join(srcs)

build_cmd = "iverilog -o test_%s.vvp %s" % (module, src)

def dut_fpga_core(current_test,

                clk_250mhz_int,
                rst_250mhz_int,

                clk_250mhz,
                rst_250mhz,

                clk_10mhz,
                rst_10mhz,

                ext_clock_selected,

                cntrl_cs,
                cntrl_sck,
                cntrl_mosi,
                cntrl_miso,

                ext_trig,

                ext_prescale,

                ferc_dat,
                ferc_clk,
                ferc_lat,

                mux_s,

                adc_sclk,
                adc_sdo,
                adc_sdi,
                adc_cs,
                adc_eoc,
                adc_convst,

                dout,

                sync_dac,

                dac_clk,
                dac_p1_d,
                dac_p2_d,
                dac_sdo,
                dac_sdio,
                dac_sclk,
                dac_csb,
                dac_reset,

                ram1_calib_done,

                ram1_p0_cmd_clk,
                ram1_p0_cmd_en,
                ram1_p0_cmd_instr,
                ram1_p0_cmd_bl,
                ram1_p0_cmd_byte_addr,
                ram1_p0_cmd_empty,
                ram1_p0_cmd_full,
                ram1_p0_wr_clk,
                ram1_p0_wr_en,
                ram1_p0_wr_mask,
                ram1_p0_wr_data,
                ram1_p0_wr_empty,
                ram1_p0_wr_full,
                ram1_p0_wr_underrun,
                ram1_p0_wr_count,
                ram1_p0_wr_error,
                ram1_p0_rd_clk,
                ram1_p0_rd_en,
                ram1_p0_rd_data,
                ram1_p0_rd_empty,
                ram1_p0_rd_full,
                ram1_p0_rd_overflow,
                ram1_p0_rd_count,
                ram1_p0_rd_error,

                ram1_p1_cmd_clk,
                ram1_p1_cmd_en,
                ram1_p1_cmd_instr,
                ram1_p1_cmd_bl,
                ram1_p1_cmd_byte_addr,
                ram1_p1_cmd_empty,
                ram1_p1_cmd_full,
                ram1_p1_wr_clk,
                ram1_p1_wr_en,
                ram1_p1_wr_mask,
                ram1_p1_wr_data,
                ram1_p1_wr_empty,
                ram1_p1_wr_full,
                ram1_p1_wr_underrun,
                ram1_p1_wr_count,
                ram1_p1_wr_error,
                ram1_p1_rd_clk,
                ram1_p1_rd_en,
                ram1_p1_rd_data,
                ram1_p1_rd_empty,
                ram1_p1_rd_full,
                ram1_p1_rd_overflow,
                ram1_p1_rd_count,
                ram1_p1_rd_error,

                ram1_p2_cmd_clk,
                ram1_p2_cmd_en,
                ram1_p2_cmd_instr,
                ram1_p2_cmd_bl,
                ram1_p2_cmd_byte_addr,
                ram1_p2_cmd_empty,
                ram1_p2_cmd_full,
                ram1_p2_rd_clk,
                ram1_p2_rd_en,
                ram1_p2_rd_data,
                ram1_p2_rd_empty,
                ram1_p2_rd_full,
                ram1_p2_rd_overflow,
                ram1_p2_rd_count,
                ram1_p2_rd_error,

                ram1_p3_cmd_clk,
                ram1_p3_cmd_en,
                ram1_p3_cmd_instr,
                ram1_p3_cmd_bl,
                ram1_p3_cmd_byte_addr,
                ram1_p3_cmd_empty,
                ram1_p3_cmd_full,
                ram1_p3_rd_clk,
                ram1_p3_rd_en,
                ram1_p3_rd_data,
                ram1_p3_rd_empty,
                ram1_p3_rd_full,
                ram1_p3_rd_overflow,
                ram1_p3_rd_count,
                ram1_p3_rd_error,

                ram1_p4_cmd_clk,
                ram1_p4_cmd_en,
                ram1_p4_cmd_instr,
                ram1_p4_cmd_bl,
                ram1_p4_cmd_byte_addr,
                ram1_p4_cmd_empty,
                ram1_p4_cmd_full,
                ram1_p4_rd_clk,
                ram1_p4_rd_en,
                ram1_p4_rd_data,
                ram1_p4_rd_empty,
                ram1_p4_rd_full,
                ram1_p4_rd_overflow,
                ram1_p4_rd_count,
                ram1_p4_rd_error,

                ram1_p5_cmd_clk,
                ram1_p5_cmd_en,
                ram1_p5_cmd_instr,
                ram1_p5_cmd_bl,
                ram1_p5_cmd_byte_addr,
                ram1_p5_cmd_empty,
                ram1_p5_cmd_full,
                ram1_p5_rd_clk,
                ram1_p5_rd_en,
                ram1_p5_rd_data,
                ram1_p5_rd_empty,
                ram1_p5_rd_full,
                ram1_p5_rd_overflow,
                ram1_p5_rd_count,
                ram1_p5_rd_error,

                ram2_calib_done,

                ram2_p0_cmd_clk,
                ram2_p0_cmd_en,
                ram2_p0_cmd_instr,
                ram2_p0_cmd_bl,
                ram2_p0_cmd_byte_addr,
                ram2_p0_cmd_empty,
                ram2_p0_cmd_full,
                ram2_p0_wr_clk,
                ram2_p0_wr_en,
                ram2_p0_wr_mask,
                ram2_p0_wr_data,
                ram2_p0_wr_empty,
                ram2_p0_wr_full,
                ram2_p0_wr_underrun,
                ram2_p0_wr_count,
                ram2_p0_wr_error,
                ram2_p0_rd_clk,
                ram2_p0_rd_en,
                ram2_p0_rd_data,
                ram2_p0_rd_empty,
                ram2_p0_rd_full,
                ram2_p0_rd_overflow,
                ram2_p0_rd_count,
                ram2_p0_rd_error,

                ram2_p1_cmd_clk,
                ram2_p1_cmd_en,
                ram2_p1_cmd_instr,
                ram2_p1_cmd_bl,
                ram2_p1_cmd_byte_addr,
                ram2_p1_cmd_empty,
                ram2_p1_cmd_full,
                ram2_p1_wr_clk,
                ram2_p1_wr_en,
                ram2_p1_wr_mask,
                ram2_p1_wr_data,
                ram2_p1_wr_empty,
                ram2_p1_wr_full,
                ram2_p1_wr_underrun,
                ram2_p1_wr_count,
                ram2_p1_wr_error,
                ram2_p1_rd_clk,
                ram2_p1_rd_en,
                ram2_p1_rd_data,
                ram2_p1_rd_empty,
                ram2_p1_rd_full,
                ram2_p1_rd_overflow,
                ram2_p1_rd_count,
                ram2_p1_rd_error,

                ram2_p2_cmd_clk,
                ram2_p2_cmd_en,
                ram2_p2_cmd_instr,
                ram2_p2_cmd_bl,
                ram2_p2_cmd_byte_addr,
                ram2_p2_cmd_empty,
                ram2_p2_cmd_full,
                ram2_p2_rd_clk,
                ram2_p2_rd_en,
                ram2_p2_rd_data,
                ram2_p2_rd_empty,
                ram2_p2_rd_full,
                ram2_p2_rd_overflow,
                ram2_p2_rd_count,
                ram2_p2_rd_error,

                ram2_p3_cmd_clk,
                ram2_p3_cmd_en,
                ram2_p3_cmd_instr,
                ram2_p3_cmd_bl,
                ram2_p3_cmd_byte_addr,
                ram2_p3_cmd_empty,
                ram2_p3_cmd_full,
                ram2_p3_rd_clk,
                ram2_p3_rd_en,
                ram2_p3_rd_data,
                ram2_p3_rd_empty,
                ram2_p3_rd_full,
                ram2_p3_rd_overflow,
                ram2_p3_rd_count,
                ram2_p3_rd_error,

                ram2_p4_cmd_clk,
                ram2_p4_cmd_en,
                ram2_p4_cmd_instr,
                ram2_p4_cmd_bl,
                ram2_p4_cmd_byte_addr,
                ram2_p4_cmd_empty,
                ram2_p4_cmd_full,
                ram2_p4_rd_clk,
                ram2_p4_rd_en,
                ram2_p4_rd_data,
                ram2_p4_rd_empty,
                ram2_p4_rd_full,
                ram2_p4_rd_overflow,
                ram2_p4_rd_count,
                ram2_p4_rd_error,

                ram2_p5_cmd_clk,
                ram2_p5_cmd_en,
                ram2_p5_cmd_instr,
                ram2_p5_cmd_bl,
                ram2_p5_cmd_byte_addr,
                ram2_p5_cmd_empty,
                ram2_p5_cmd_full,
                ram2_p5_rd_clk,
                ram2_p5_rd_en,
                ram2_p5_rd_data,
                ram2_p5_rd_empty,
                ram2_p5_rd_full,
                ram2_p5_rd_overflow,
                ram2_p5_rd_count,
                ram2_p5_rd_error):

    if os.system(build_cmd):
        raise Exception("Error running build command")
    return Cosimulation("vvp -m myhdl test_%s.vvp -lxt2" % module,
                current_test=current_test,

                clk_250mhz_int=clk_250mhz_int,
                rst_250mhz_int=rst_250mhz_int,

                clk_250mhz=clk_250mhz,
                rst_250mhz=rst_250mhz,

                clk_10mhz=clk_10mhz,
                rst_10mhz=rst_10mhz,

                ext_clock_selected=ext_clock_selected,

                cntrl_cs=cntrl_cs,
                cntrl_sck=cntrl_sck,
                cntrl_mosi=cntrl_mosi,
                cntrl_miso=cntrl_miso,

                ext_trig=ext_trig,

                ext_prescale=ext_prescale,

                ferc_dat=ferc_dat,
                ferc_clk=ferc_clk,
                ferc_lat=ferc_lat,

                mux_s=mux_s,

                adc_sclk=adc_sclk,
                adc_sdo=adc_sdo,
                adc_sdi=adc_sdi,
                adc_cs=adc_cs,
                adc_eoc=adc_eoc,
                adc_convst=adc_convst,

                dout=dout,

                sync_dac=sync_dac,

                dac_clk=dac_clk,
                dac_p1_d=dac_p1_d,
                dac_p2_d=dac_p2_d,
                dac_sdo=dac_sdo,
                dac_sdio=dac_sdio,
                dac_sclk=dac_sclk,
                dac_csb=dac_csb,
                dac_reset=dac_reset,

                ram1_calib_done=ram1_calib_done,

                ram1_p0_cmd_clk=ram1_p0_cmd_clk,
                ram1_p0_cmd_en=ram1_p0_cmd_en,
                ram1_p0_cmd_instr=ram1_p0_cmd_instr,
                ram1_p0_cmd_bl=ram1_p0_cmd_bl,
                ram1_p0_cmd_byte_addr=ram1_p0_cmd_byte_addr,
                ram1_p0_cmd_empty=ram1_p0_cmd_empty,
                ram1_p0_cmd_full=ram1_p0_cmd_full,
                ram1_p0_wr_clk=ram1_p0_wr_clk,
                ram1_p0_wr_en=ram1_p0_wr_en,
                ram1_p0_wr_mask=ram1_p0_wr_mask,
                ram1_p0_wr_data=ram1_p0_wr_data,
                ram1_p0_wr_empty=ram1_p0_wr_empty,
                ram1_p0_wr_full=ram1_p0_wr_full,
                ram1_p0_wr_underrun=ram1_p0_wr_underrun,
                ram1_p0_wr_count=ram1_p0_wr_count,
                ram1_p0_wr_error=ram1_p0_wr_error,
                ram1_p0_rd_clk=ram1_p0_rd_clk,
                ram1_p0_rd_en=ram1_p0_rd_en,
                ram1_p0_rd_data=ram1_p0_rd_data,
                ram1_p0_rd_empty=ram1_p0_rd_empty,
                ram1_p0_rd_full=ram1_p0_rd_full,
                ram1_p0_rd_overflow=ram1_p0_rd_overflow,
                ram1_p0_rd_count=ram1_p0_rd_count,
                ram1_p0_rd_error=ram1_p0_rd_error,

                ram1_p1_cmd_clk=ram1_p1_cmd_clk,
                ram1_p1_cmd_en=ram1_p1_cmd_en,
                ram1_p1_cmd_instr=ram1_p1_cmd_instr,
                ram1_p1_cmd_bl=ram1_p1_cmd_bl,
                ram1_p1_cmd_byte_addr=ram1_p1_cmd_byte_addr,
                ram1_p1_cmd_empty=ram1_p1_cmd_empty,
                ram1_p1_cmd_full=ram1_p1_cmd_full,
                ram1_p1_wr_clk=ram1_p1_wr_clk,
                ram1_p1_wr_en=ram1_p1_wr_en,
                ram1_p1_wr_mask=ram1_p1_wr_mask,
                ram1_p1_wr_data=ram1_p1_wr_data,
                ram1_p1_wr_empty=ram1_p1_wr_empty,
                ram1_p1_wr_full=ram1_p1_wr_full,
                ram1_p1_wr_underrun=ram1_p1_wr_underrun,
                ram1_p1_wr_count=ram1_p1_wr_count,
                ram1_p1_wr_error=ram1_p1_wr_error,
                ram1_p1_rd_clk=ram1_p1_rd_clk,
                ram1_p1_rd_en=ram1_p1_rd_en,
                ram1_p1_rd_data=ram1_p1_rd_data,
                ram1_p1_rd_empty=ram1_p1_rd_empty,
                ram1_p1_rd_full=ram1_p1_rd_full,
                ram1_p1_rd_overflow=ram1_p1_rd_overflow,
                ram1_p1_rd_count=ram1_p1_rd_count,
                ram1_p1_rd_error=ram1_p1_rd_error,

                ram1_p2_cmd_clk=ram1_p2_cmd_clk,
                ram1_p2_cmd_en=ram1_p2_cmd_en,
                ram1_p2_cmd_instr=ram1_p2_cmd_instr,
                ram1_p2_cmd_bl=ram1_p2_cmd_bl,
                ram1_p2_cmd_byte_addr=ram1_p2_cmd_byte_addr,
                ram1_p2_cmd_empty=ram1_p2_cmd_empty,
                ram1_p2_cmd_full=ram1_p2_cmd_full,
                ram1_p2_rd_clk=ram1_p2_rd_clk,
                ram1_p2_rd_en=ram1_p2_rd_en,
                ram1_p2_rd_data=ram1_p2_rd_data,
                ram1_p2_rd_empty=ram1_p2_rd_empty,
                ram1_p2_rd_full=ram1_p2_rd_full,
                ram1_p2_rd_overflow=ram1_p2_rd_overflow,
                ram1_p2_rd_count=ram1_p2_rd_count,
                ram1_p2_rd_error=ram1_p2_rd_error,

                ram1_p3_cmd_clk=ram1_p3_cmd_clk,
                ram1_p3_cmd_en=ram1_p3_cmd_en,
                ram1_p3_cmd_instr=ram1_p3_cmd_instr,
                ram1_p3_cmd_bl=ram1_p3_cmd_bl,
                ram1_p3_cmd_byte_addr=ram1_p3_cmd_byte_addr,
                ram1_p3_cmd_empty=ram1_p3_cmd_empty,
                ram1_p3_cmd_full=ram1_p3_cmd_full,
                ram1_p3_rd_clk=ram1_p3_rd_clk,
                ram1_p3_rd_en=ram1_p3_rd_en,
                ram1_p3_rd_data=ram1_p3_rd_data,
                ram1_p3_rd_empty=ram1_p3_rd_empty,
                ram1_p3_rd_full=ram1_p3_rd_full,
                ram1_p3_rd_overflow=ram1_p3_rd_overflow,
                ram1_p3_rd_count=ram1_p3_rd_count,
                ram1_p3_rd_error=ram1_p3_rd_error,

                ram1_p4_cmd_clk=ram1_p4_cmd_clk,
                ram1_p4_cmd_en=ram1_p4_cmd_en,
                ram1_p4_cmd_instr=ram1_p4_cmd_instr,
                ram1_p4_cmd_bl=ram1_p4_cmd_bl,
                ram1_p4_cmd_byte_addr=ram1_p4_cmd_byte_addr,
                ram1_p4_cmd_empty=ram1_p4_cmd_empty,
                ram1_p4_cmd_full=ram1_p4_cmd_full,
                ram1_p4_rd_clk=ram1_p4_rd_clk,
                ram1_p4_rd_en=ram1_p4_rd_en,
                ram1_p4_rd_data=ram1_p4_rd_data,
                ram1_p4_rd_empty=ram1_p4_rd_empty,
                ram1_p4_rd_full=ram1_p4_rd_full,
                ram1_p4_rd_overflow=ram1_p4_rd_overflow,
                ram1_p4_rd_count=ram1_p4_rd_count,
                ram1_p4_rd_error=ram1_p4_rd_error,

                ram1_p5_cmd_clk=ram1_p5_cmd_clk,
                ram1_p5_cmd_en=ram1_p5_cmd_en,
                ram1_p5_cmd_instr=ram1_p5_cmd_instr,
                ram1_p5_cmd_bl=ram1_p5_cmd_bl,
                ram1_p5_cmd_byte_addr=ram1_p5_cmd_byte_addr,
                ram1_p5_cmd_empty=ram1_p5_cmd_empty,
                ram1_p5_cmd_full=ram1_p5_cmd_full,
                ram1_p5_rd_clk=ram1_p5_rd_clk,
                ram1_p5_rd_en=ram1_p5_rd_en,
                ram1_p5_rd_data=ram1_p5_rd_data,
                ram1_p5_rd_empty=ram1_p5_rd_empty,
                ram1_p5_rd_full=ram1_p5_rd_full,
                ram1_p5_rd_overflow=ram1_p5_rd_overflow,
                ram1_p5_rd_count=ram1_p5_rd_count,
                ram1_p5_rd_error=ram1_p5_rd_error,

                ram2_calib_done=ram2_calib_done,

                ram2_p0_cmd_clk=ram2_p0_cmd_clk,
                ram2_p0_cmd_en=ram2_p0_cmd_en,
                ram2_p0_cmd_instr=ram2_p0_cmd_instr,
                ram2_p0_cmd_bl=ram2_p0_cmd_bl,
                ram2_p0_cmd_byte_addr=ram2_p0_cmd_byte_addr,
                ram2_p0_cmd_empty=ram2_p0_cmd_empty,
                ram2_p0_cmd_full=ram2_p0_cmd_full,
                ram2_p0_wr_clk=ram2_p0_wr_clk,
                ram2_p0_wr_en=ram2_p0_wr_en,
                ram2_p0_wr_mask=ram2_p0_wr_mask,
                ram2_p0_wr_data=ram2_p0_wr_data,
                ram2_p0_wr_empty=ram2_p0_wr_empty,
                ram2_p0_wr_full=ram2_p0_wr_full,
                ram2_p0_wr_underrun=ram2_p0_wr_underrun,
                ram2_p0_wr_count=ram2_p0_wr_count,
                ram2_p0_wr_error=ram2_p0_wr_error,
                ram2_p0_rd_clk=ram2_p0_rd_clk,
                ram2_p0_rd_en=ram2_p0_rd_en,
                ram2_p0_rd_data=ram2_p0_rd_data,
                ram2_p0_rd_empty=ram2_p0_rd_empty,
                ram2_p0_rd_full=ram2_p0_rd_full,
                ram2_p0_rd_overflow=ram2_p0_rd_overflow,
                ram2_p0_rd_count=ram2_p0_rd_count,
                ram2_p0_rd_error=ram2_p0_rd_error,

                ram2_p1_cmd_clk=ram2_p1_cmd_clk,
                ram2_p1_cmd_en=ram2_p1_cmd_en,
                ram2_p1_cmd_instr=ram2_p1_cmd_instr,
                ram2_p1_cmd_bl=ram2_p1_cmd_bl,
                ram2_p1_cmd_byte_addr=ram2_p1_cmd_byte_addr,
                ram2_p1_cmd_empty=ram2_p1_cmd_empty,
                ram2_p1_cmd_full=ram2_p1_cmd_full,
                ram2_p1_wr_clk=ram2_p1_wr_clk,
                ram2_p1_wr_en=ram2_p1_wr_en,
                ram2_p1_wr_mask=ram2_p1_wr_mask,
                ram2_p1_wr_data=ram2_p1_wr_data,
                ram2_p1_wr_empty=ram2_p1_wr_empty,
                ram2_p1_wr_full=ram2_p1_wr_full,
                ram2_p1_wr_underrun=ram2_p1_wr_underrun,
                ram2_p1_wr_count=ram2_p1_wr_count,
                ram2_p1_wr_error=ram2_p1_wr_error,
                ram2_p1_rd_clk=ram2_p1_rd_clk,
                ram2_p1_rd_en=ram2_p1_rd_en,
                ram2_p1_rd_data=ram2_p1_rd_data,
                ram2_p1_rd_empty=ram2_p1_rd_empty,
                ram2_p1_rd_full=ram2_p1_rd_full,
                ram2_p1_rd_overflow=ram2_p1_rd_overflow,
                ram2_p1_rd_count=ram2_p1_rd_count,
                ram2_p1_rd_error=ram2_p1_rd_error,

                ram2_p2_cmd_clk=ram2_p2_cmd_clk,
                ram2_p2_cmd_en=ram2_p2_cmd_en,
                ram2_p2_cmd_instr=ram2_p2_cmd_instr,
                ram2_p2_cmd_bl=ram2_p2_cmd_bl,
                ram2_p2_cmd_byte_addr=ram2_p2_cmd_byte_addr,
                ram2_p2_cmd_empty=ram2_p2_cmd_empty,
                ram2_p2_cmd_full=ram2_p2_cmd_full,
                ram2_p2_rd_clk=ram2_p2_rd_clk,
                ram2_p2_rd_en=ram2_p2_rd_en,
                ram2_p2_rd_data=ram2_p2_rd_data,
                ram2_p2_rd_empty=ram2_p2_rd_empty,
                ram2_p2_rd_full=ram2_p2_rd_full,
                ram2_p2_rd_overflow=ram2_p2_rd_overflow,
                ram2_p2_rd_count=ram2_p2_rd_count,
                ram2_p2_rd_error=ram2_p2_rd_error,

                ram2_p3_cmd_clk=ram2_p3_cmd_clk,
                ram2_p3_cmd_en=ram2_p3_cmd_en,
                ram2_p3_cmd_instr=ram2_p3_cmd_instr,
                ram2_p3_cmd_bl=ram2_p3_cmd_bl,
                ram2_p3_cmd_byte_addr=ram2_p3_cmd_byte_addr,
                ram2_p3_cmd_empty=ram2_p3_cmd_empty,
                ram2_p3_cmd_full=ram2_p3_cmd_full,
                ram2_p3_rd_clk=ram2_p3_rd_clk,
                ram2_p3_rd_en=ram2_p3_rd_en,
                ram2_p3_rd_data=ram2_p3_rd_data,
                ram2_p3_rd_empty=ram2_p3_rd_empty,
                ram2_p3_rd_full=ram2_p3_rd_full,
                ram2_p3_rd_overflow=ram2_p3_rd_overflow,
                ram2_p3_rd_count=ram2_p3_rd_count,
                ram2_p3_rd_error=ram2_p3_rd_error,

                ram2_p4_cmd_clk=ram2_p4_cmd_clk,
                ram2_p4_cmd_en=ram2_p4_cmd_en,
                ram2_p4_cmd_instr=ram2_p4_cmd_instr,
                ram2_p4_cmd_bl=ram2_p4_cmd_bl,
                ram2_p4_cmd_byte_addr=ram2_p4_cmd_byte_addr,
                ram2_p4_cmd_empty=ram2_p4_cmd_empty,
                ram2_p4_cmd_full=ram2_p4_cmd_full,
                ram2_p4_rd_clk=ram2_p4_rd_clk,
                ram2_p4_rd_en=ram2_p4_rd_en,
                ram2_p4_rd_data=ram2_p4_rd_data,
                ram2_p4_rd_empty=ram2_p4_rd_empty,
                ram2_p4_rd_full=ram2_p4_rd_full,
                ram2_p4_rd_overflow=ram2_p4_rd_overflow,
                ram2_p4_rd_count=ram2_p4_rd_count,
                ram2_p4_rd_error=ram2_p4_rd_error,

                ram2_p5_cmd_clk=ram2_p5_cmd_clk,
                ram2_p5_cmd_en=ram2_p5_cmd_en,
                ram2_p5_cmd_instr=ram2_p5_cmd_instr,
                ram2_p5_cmd_bl=ram2_p5_cmd_bl,
                ram2_p5_cmd_byte_addr=ram2_p5_cmd_byte_addr,
                ram2_p5_cmd_empty=ram2_p5_cmd_empty,
                ram2_p5_cmd_full=ram2_p5_cmd_full,
                ram2_p5_rd_clk=ram2_p5_rd_clk,
                ram2_p5_rd_en=ram2_p5_rd_en,
                ram2_p5_rd_data=ram2_p5_rd_data,
                ram2_p5_rd_empty=ram2_p5_rd_empty,
                ram2_p5_rd_full=ram2_p5_rd_full,
                ram2_p5_rd_overflow=ram2_p5_rd_overflow,
                ram2_p5_rd_count=ram2_p5_rd_count,
                ram2_p5_rd_error=ram2_p5_rd_error)

def bench():

    current_test = Signal(intbv(0)[8:])

    # clocks
    clk_250mhz_int = Signal(bool(0))
    rst_250mhz_int = Signal(bool(0))

    clk_250mhz = Signal(bool(0))
    rst_250mhz = Signal(bool(0))

    clk_10mhz = Signal(bool(0))
    rst_10mhz = Signal(bool(0))

    ext_clock_selected = Signal(bool(0))

    # SoC interface
    cntrl_cs = Signal(bool(0))
    cntrl_sck = Signal(bool(0))
    cntrl_mosi = Signal(bool(0))
    cntrl_miso = Signal(bool(0))

    # Trigger
    ext_trig = Signal(bool(0))

    # Frequency counter
    ext_prescale = Signal(bool(0))

    # Front end relay control
    ferc_dat = Signal(bool(0))
    ferc_clk = Signal(bool(0))
    ferc_lat = Signal(bool(0))

    # Analog mux
    mux_s = Signal(intbv(0)[3:])

    # ADC
    adc_sclk = Signal(bool(0))
    adc_sdo = Signal(bool(0))
    adc_sdi = Signal(bool(0))
    adc_cs = Signal(bool(0))
    adc_eoc = Signal(bool(0))
    adc_convst = Signal(bool(0))

    # digital output
    dout = Signal(intbv(0)[16:])

    # Sync DAC
    sync_dac = Signal(intbv(0)[8:])

    # Main DAC
    dac_clk = Signal(bool(0))
    dac_p1_d = Signal(intbv(0)[16:])
    dac_p2_d = Signal(intbv(0)[16:])
    dac_sdo = Signal(bool(0))
    dac_sdio = Signal(bool(0))
    dac_sclk = Signal(bool(0))
    dac_csb = Signal(bool(0))
    dac_reset = Signal(bool(0))

    # ram 1 MCB (U8)
    ram1_calib_done = Signal(bool(0))

    ram1_p0_cmd_clk = Signal(bool(0))
    ram1_p0_cmd_en = Signal(bool(0))
    ram1_p0_cmd_instr = Signal(intbv(0)[3:])
    ram1_p0_cmd_bl = Signal(intbv(0)[6:])
    ram1_p0_cmd_byte_addr = Signal(intbv(0)[32:])
    ram1_p0_cmd_empty = Signal(bool(0))
    ram1_p0_cmd_full = Signal(bool(0))
    ram1_p0_wr_clk = Signal(bool(0))
    ram1_p0_wr_en = Signal(bool(0))
    ram1_p0_wr_mask = Signal(intbv(0)[4:])
    ram1_p0_wr_data = Signal(intbv(0)[32:])
    ram1_p0_wr_empty = Signal(bool(0))
    ram1_p0_wr_full = Signal(bool(0))
    ram1_p0_wr_underrun = Signal(bool(0))
    ram1_p0_wr_count = Signal(intbv(0)[7:])
    ram1_p0_wr_error = Signal(bool(0))
    ram1_p0_rd_clk = Signal(bool(0))
    ram1_p0_rd_en = Signal(bool(0))
    ram1_p0_rd_data = Signal(intbv(0)[32:])
    ram1_p0_rd_empty = Signal(bool(0))
    ram1_p0_rd_full = Signal(bool(0))
    ram1_p0_rd_overflow = Signal(bool(0))
    ram1_p0_rd_count = Signal(intbv(0)[7:])
    ram1_p0_rd_error = Signal(bool(0))

    ram1_p1_cmd_clk = Signal(bool(0))
    ram1_p1_cmd_en = Signal(bool(0))
    ram1_p1_cmd_instr = Signal(intbv(0)[3:])
    ram1_p1_cmd_bl = Signal(intbv(0)[6:])
    ram1_p1_cmd_byte_addr = Signal(intbv(0)[32:])
    ram1_p1_cmd_empty = Signal(bool(0))
    ram1_p1_cmd_full = Signal(bool(0))
    ram1_p1_wr_clk = Signal(bool(0))
    ram1_p1_wr_en = Signal(bool(0))
    ram1_p1_wr_mask = Signal(intbv(0)[4:])
    ram1_p1_wr_data = Signal(intbv(0)[32:])
    ram1_p1_wr_empty = Signal(bool(0))
    ram1_p1_wr_full = Signal(bool(0))
    ram1_p1_wr_underrun = Signal(bool(0))
    ram1_p1_wr_count = Signal(intbv(0)[7:])
    ram1_p1_wr_error = Signal(bool(0))
    ram1_p1_rd_clk = Signal(bool(0))
    ram1_p1_rd_en = Signal(bool(0))
    ram1_p1_rd_data = Signal(intbv(0)[32:])
    ram1_p1_rd_empty = Signal(bool(0))
    ram1_p1_rd_full = Signal(bool(0))
    ram1_p1_rd_overflow = Signal(bool(0))
    ram1_p1_rd_count = Signal(intbv(0)[7:])
    ram1_p1_rd_error = Signal(bool(0))

    ram1_p2_cmd_clk = Signal(bool(0))
    ram1_p2_cmd_en = Signal(bool(0))
    ram1_p2_cmd_instr = Signal(intbv(0)[3:])
    ram1_p2_cmd_bl = Signal(intbv(0)[6:])
    ram1_p2_cmd_byte_addr = Signal(intbv(0)[32:])
    ram1_p2_cmd_empty = Signal(bool(0))
    ram1_p2_cmd_full = Signal(bool(0))
    ram1_p2_rd_clk = Signal(bool(0))
    ram1_p2_rd_en = Signal(bool(0))
    ram1_p2_rd_data = Signal(intbv(0)[32:])
    ram1_p2_rd_empty = Signal(bool(0))
    ram1_p2_rd_full = Signal(bool(0))
    ram1_p2_rd_overflow = Signal(bool(0))
    ram1_p2_rd_count = Signal(intbv(0)[7:])
    ram1_p2_rd_error = Signal(bool(0))

    ram1_p3_cmd_clk = Signal(bool(0))
    ram1_p3_cmd_en = Signal(bool(0))
    ram1_p3_cmd_instr = Signal(intbv(0)[3:])
    ram1_p3_cmd_bl = Signal(intbv(0)[6:])
    ram1_p3_cmd_byte_addr = Signal(intbv(0)[32:])
    ram1_p3_cmd_empty = Signal(bool(0))
    ram1_p3_cmd_full = Signal(bool(0))
    ram1_p3_rd_clk = Signal(bool(0))
    ram1_p3_rd_en = Signal(bool(0))
    ram1_p3_rd_data = Signal(intbv(0)[32:])
    ram1_p3_rd_empty = Signal(bool(0))
    ram1_p3_rd_full = Signal(bool(0))
    ram1_p3_rd_overflow = Signal(bool(0))
    ram1_p3_rd_count = Signal(intbv(0)[7:])
    ram1_p3_rd_error = Signal(bool(0))

    ram1_p4_cmd_clk = Signal(bool(0))
    ram1_p4_cmd_en = Signal(bool(0))
    ram1_p4_cmd_instr = Signal(intbv(0)[3:])
    ram1_p4_cmd_bl = Signal(intbv(0)[6:])
    ram1_p4_cmd_byte_addr = Signal(intbv(0)[32:])
    ram1_p4_cmd_empty = Signal(bool(0))
    ram1_p4_cmd_full = Signal(bool(0))
    ram1_p4_rd_clk = Signal(bool(0))
    ram1_p4_rd_en = Signal(bool(0))
    ram1_p4_rd_data = Signal(intbv(0)[32:])
    ram1_p4_rd_empty = Signal(bool(0))
    ram1_p4_rd_full = Signal(bool(0))
    ram1_p4_rd_overflow = Signal(bool(0))
    ram1_p4_rd_count = Signal(intbv(0)[7:])
    ram1_p4_rd_error = Signal(bool(0))

    ram1_p5_cmd_clk = Signal(bool(0))
    ram1_p5_cmd_en = Signal(bool(0))
    ram1_p5_cmd_instr = Signal(intbv(0)[3:])
    ram1_p5_cmd_bl = Signal(intbv(0)[6:])
    ram1_p5_cmd_byte_addr = Signal(intbv(0)[32:])
    ram1_p5_cmd_empty = Signal(bool(0))
    ram1_p5_cmd_full = Signal(bool(0))
    ram1_p5_rd_clk = Signal(bool(0))
    ram1_p5_rd_en = Signal(bool(0))
    ram1_p5_rd_data = Signal(intbv(0)[32:])
    ram1_p5_rd_empty = Signal(bool(0))
    ram1_p5_rd_full = Signal(bool(0))
    ram1_p5_rd_overflow = Signal(bool(0))
    ram1_p5_rd_count = Signal(intbv(0)[7:])
    ram1_p5_rd_error = Signal(bool(0))

    # ram 2 MCB (U12)
    ram2_calib_done = Signal(bool(0))

    ram2_p0_cmd_clk = Signal(bool(0))
    ram2_p0_cmd_en = Signal(bool(0))
    ram2_p0_cmd_instr = Signal(intbv(0)[3:])
    ram2_p0_cmd_bl = Signal(intbv(0)[6:])
    ram2_p0_cmd_byte_addr = Signal(intbv(0)[32:])
    ram2_p0_cmd_empty = Signal(bool(0))
    ram2_p0_cmd_full = Signal(bool(0))
    ram2_p0_wr_clk = Signal(bool(0))
    ram2_p0_wr_en = Signal(bool(0))
    ram2_p0_wr_mask = Signal(intbv(0)[4:])
    ram2_p0_wr_data = Signal(intbv(0)[32:])
    ram2_p0_wr_empty = Signal(bool(0))
    ram2_p0_wr_full = Signal(bool(0))
    ram2_p0_wr_underrun = Signal(bool(0))
    ram2_p0_wr_count = Signal(intbv(0)[7:])
    ram2_p0_wr_error = Signal(bool(0))
    ram2_p0_rd_clk = Signal(bool(0))
    ram2_p0_rd_en = Signal(bool(0))
    ram2_p0_rd_data = Signal(intbv(0)[32:])
    ram2_p0_rd_empty = Signal(bool(0))
    ram2_p0_rd_full = Signal(bool(0))
    ram2_p0_rd_overflow = Signal(bool(0))
    ram2_p0_rd_count = Signal(intbv(0)[7:])
    ram2_p0_rd_error = Signal(bool(0))

    ram2_p1_cmd_clk = Signal(bool(0))
    ram2_p1_cmd_en = Signal(bool(0))
    ram2_p1_cmd_instr = Signal(intbv(0)[3:])
    ram2_p1_cmd_bl = Signal(intbv(0)[6:])
    ram2_p1_cmd_byte_addr = Signal(intbv(0)[32:])
    ram2_p1_cmd_empty = Signal(bool(0))
    ram2_p1_cmd_full = Signal(bool(0))
    ram2_p1_wr_clk = Signal(bool(0))
    ram2_p1_wr_en = Signal(bool(0))
    ram2_p1_wr_mask = Signal(intbv(0)[4:])
    ram2_p1_wr_data = Signal(intbv(0)[32:])
    ram2_p1_wr_empty = Signal(bool(0))
    ram2_p1_wr_full = Signal(bool(0))
    ram2_p1_wr_underrun = Signal(bool(0))
    ram2_p1_wr_count = Signal(intbv(0)[7:])
    ram2_p1_wr_error = Signal(bool(0))
    ram2_p1_rd_clk = Signal(bool(0))
    ram2_p1_rd_en = Signal(bool(0))
    ram2_p1_rd_data = Signal(intbv(0)[32:])
    ram2_p1_rd_empty = Signal(bool(0))
    ram2_p1_rd_full = Signal(bool(0))
    ram2_p1_rd_overflow = Signal(bool(0))
    ram2_p1_rd_count = Signal(intbv(0)[7:])
    ram2_p1_rd_error = Signal(bool(0))

    ram2_p2_cmd_clk = Signal(bool(0))
    ram2_p2_cmd_en = Signal(bool(0))
    ram2_p2_cmd_instr = Signal(intbv(0)[3:])
    ram2_p2_cmd_bl = Signal(intbv(0)[6:])
    ram2_p2_cmd_byte_addr = Signal(intbv(0)[32:])
    ram2_p2_cmd_empty = Signal(bool(0))
    ram2_p2_cmd_full = Signal(bool(0))
    ram2_p2_rd_clk = Signal(bool(0))
    ram2_p2_rd_en = Signal(bool(0))
    ram2_p2_rd_data = Signal(intbv(0)[32:])
    ram2_p2_rd_empty = Signal(bool(0))
    ram2_p2_rd_full = Signal(bool(0))
    ram2_p2_rd_overflow = Signal(bool(0))
    ram2_p2_rd_count = Signal(intbv(0)[7:])
    ram2_p2_rd_error = Signal(bool(0))

    ram2_p3_cmd_clk = Signal(bool(0))
    ram2_p3_cmd_en = Signal(bool(0))
    ram2_p3_cmd_instr = Signal(intbv(0)[3:])
    ram2_p3_cmd_bl = Signal(intbv(0)[6:])
    ram2_p3_cmd_byte_addr = Signal(intbv(0)[32:])
    ram2_p3_cmd_empty = Signal(bool(0))
    ram2_p3_cmd_full = Signal(bool(0))
    ram2_p3_rd_clk = Signal(bool(0))
    ram2_p3_rd_en = Signal(bool(0))
    ram2_p3_rd_data = Signal(intbv(0)[32:])
    ram2_p3_rd_empty = Signal(bool(0))
    ram2_p3_rd_full = Signal(bool(0))
    ram2_p3_rd_overflow = Signal(bool(0))
    ram2_p3_rd_count = Signal(intbv(0)[7:])
    ram2_p3_rd_error = Signal(bool(0))

    ram2_p4_cmd_clk = Signal(bool(0))
    ram2_p4_cmd_en = Signal(bool(0))
    ram2_p4_cmd_instr = Signal(intbv(0)[3:])
    ram2_p4_cmd_bl = Signal(intbv(0)[6:])
    ram2_p4_cmd_byte_addr = Signal(intbv(0)[32:])
    ram2_p4_cmd_empty = Signal(bool(0))
    ram2_p4_cmd_full = Signal(bool(0))
    ram2_p4_rd_clk = Signal(bool(0))
    ram2_p4_rd_en = Signal(bool(0))
    ram2_p4_rd_data = Signal(intbv(0)[32:])
    ram2_p4_rd_empty = Signal(bool(0))
    ram2_p4_rd_full = Signal(bool(0))
    ram2_p4_rd_overflow = Signal(bool(0))
    ram2_p4_rd_count = Signal(intbv(0)[7:])
    ram2_p4_rd_error = Signal(bool(0))

    ram2_p5_cmd_clk = Signal(bool(0))
    ram2_p5_cmd_en = Signal(bool(0))
    ram2_p5_cmd_instr = Signal(intbv(0)[3:])
    ram2_p5_cmd_bl = Signal(intbv(0)[6:])
    ram2_p5_cmd_byte_addr = Signal(intbv(0)[32:])
    ram2_p5_cmd_empty = Signal(bool(0))
    ram2_p5_cmd_full = Signal(bool(0))
    ram2_p5_rd_clk = Signal(bool(0))
    ram2_p5_rd_en = Signal(bool(0))
    ram2_p5_rd_data = Signal(intbv(0)[32:])
    ram2_p5_rd_empty = Signal(bool(0))
    ram2_p5_rd_full = Signal(bool(0))
    ram2_p5_rd_overflow = Signal(bool(0))
    ram2_p5_rd_count = Signal(intbv(0)[7:])
    ram2_p5_rd_error = Signal(bool(0))

    # SPI master
    master_tx_queue = Queue()
    master_rx_queue = Queue()

    master = spi_ep.SPIMaster(clk_250mhz_int,
                              rst_250mhz_int,
                              cs=cntrl_cs,
                              sck=cntrl_sck,
                              mosi=cntrl_mosi,
                              miso=cntrl_miso,
                              width=8,
                              prescale=4,
                              cpol=0,
                              cpha=0,
                              tx_fifo=master_tx_queue,
                              rx_fifo=master_rx_queue,
                              name='spi')

    # MCB model
    ram1_mcb = mcb.MCB(10240)
    ram2_mcb = mcb.MCB(10240)

    ram1_controller = ram1_mcb.create_controller(clk_250mhz_int, rst_250mhz_int)

    ram1_p0 = ram1_mcb.create_readwrite_port(cmd_clk=ram1_p0_cmd_clk,
                                    cmd_en=ram1_p0_cmd_en,
                                    cmd_instr=ram1_p0_cmd_instr,
                                    cmd_bl=ram1_p0_cmd_bl,
                                    cmd_byte_addr=ram1_p0_cmd_byte_addr,
                                    cmd_empty=ram1_p0_cmd_empty,
                                    cmd_full=ram1_p0_cmd_full,
                                    wr_clk=ram1_p0_wr_clk,
                                    wr_en=ram1_p0_wr_en,
                                    wr_mask=ram1_p0_wr_mask,
                                    wr_data=ram1_p0_wr_data,
                                    wr_empty=ram1_p0_wr_empty,
                                    wr_full=ram1_p0_wr_full,
                                    wr_underrun=ram1_p0_wr_underrun,
                                    wr_count=ram1_p0_wr_count,
                                    wr_error=ram1_p0_wr_error,
                                    rd_clk=ram1_p0_rd_clk,
                                    rd_en=ram1_p0_rd_en,
                                    rd_data=ram1_p0_rd_data,
                                    rd_empty=ram1_p0_rd_empty,
                                    rd_full=ram1_p0_rd_full,
                                    rd_overflow=ram1_p0_rd_overflow,
                                    rd_count=ram1_p0_rd_count,
                                    rd_error=ram1_p0_rd_error,
                                    name='ram1_p0')

    ram1_p1 = ram1_mcb.create_readwrite_port(cmd_clk=ram1_p1_cmd_clk,
                                    cmd_en=ram1_p1_cmd_en,
                                    cmd_instr=ram1_p1_cmd_instr,
                                    cmd_bl=ram1_p1_cmd_bl,
                                    cmd_byte_addr=ram1_p1_cmd_byte_addr,
                                    cmd_empty=ram1_p1_cmd_empty,
                                    cmd_full=ram1_p1_cmd_full,
                                    wr_clk=ram1_p1_wr_clk,
                                    wr_en=ram1_p1_wr_en,
                                    wr_mask=ram1_p1_wr_mask,
                                    wr_data=ram1_p1_wr_data,
                                    wr_empty=ram1_p1_wr_empty,
                                    wr_full=ram1_p1_wr_full,
                                    wr_underrun=ram1_p1_wr_underrun,
                                    wr_count=ram1_p1_wr_count,
                                    wr_error=ram1_p1_wr_error,
                                    rd_clk=ram1_p1_rd_clk,
                                    rd_en=ram1_p1_rd_en,
                                    rd_data=ram1_p1_rd_data,
                                    rd_empty=ram1_p1_rd_empty,
                                    rd_full=ram1_p1_rd_full,
                                    rd_overflow=ram1_p1_rd_overflow,
                                    rd_count=ram1_p1_rd_count,
                                    rd_error=ram1_p1_rd_error,
                                    name='ram1_p1')

    ram1_p2 = ram1_mcb.create_read_port(cmd_clk=ram1_p2_cmd_clk,
                                    cmd_en=ram1_p2_cmd_en,
                                    cmd_instr=ram1_p2_cmd_instr,
                                    cmd_bl=ram1_p2_cmd_bl,
                                    cmd_byte_addr=ram1_p2_cmd_byte_addr,
                                    cmd_empty=ram1_p2_cmd_empty,
                                    cmd_full=ram1_p2_cmd_full,
                                    rd_clk=ram1_p2_rd_clk,
                                    rd_en=ram1_p2_rd_en,
                                    rd_data=ram1_p2_rd_data,
                                    rd_empty=ram1_p2_rd_empty,
                                    rd_full=ram1_p2_rd_full,
                                    rd_overflow=ram1_p2_rd_overflow,
                                    rd_count=ram1_p2_rd_count,
                                    rd_error=ram1_p2_rd_error,
                                    name='ram1_p2')

    ram1_p3 = ram1_mcb.create_read_port(cmd_clk=ram1_p3_cmd_clk,
                                    cmd_en=ram1_p3_cmd_en,
                                    cmd_instr=ram1_p3_cmd_instr,
                                    cmd_bl=ram1_p3_cmd_bl,
                                    cmd_byte_addr=ram1_p3_cmd_byte_addr,
                                    cmd_empty=ram1_p3_cmd_empty,
                                    cmd_full=ram1_p3_cmd_full,
                                    rd_clk=ram1_p3_rd_clk,
                                    rd_en=ram1_p3_rd_en,
                                    rd_data=ram1_p3_rd_data,
                                    rd_empty=ram1_p3_rd_empty,
                                    rd_full=ram1_p3_rd_full,
                                    rd_overflow=ram1_p3_rd_overflow,
                                    rd_count=ram1_p3_rd_count,
                                    rd_error=ram1_p3_rd_error,
                                    name='ram1_p3')

    ram1_p4 = ram1_mcb.create_read_port(cmd_clk=ram1_p4_cmd_clk,
                                    cmd_en=ram1_p4_cmd_en,
                                    cmd_instr=ram1_p4_cmd_instr,
                                    cmd_bl=ram1_p4_cmd_bl,
                                    cmd_byte_addr=ram1_p4_cmd_byte_addr,
                                    cmd_empty=ram1_p4_cmd_empty,
                                    cmd_full=ram1_p4_cmd_full,
                                    rd_clk=ram1_p4_rd_clk,
                                    rd_en=ram1_p4_rd_en,
                                    rd_data=ram1_p4_rd_data,
                                    rd_empty=ram1_p4_rd_empty,
                                    rd_full=ram1_p4_rd_full,
                                    rd_overflow=ram1_p4_rd_overflow,
                                    rd_count=ram1_p4_rd_count,
                                    rd_error=ram1_p4_rd_error,
                                    name='ram1_p4')

    ram1_p5 = ram1_mcb.create_read_port(cmd_clk=ram1_p5_cmd_clk,
                                    cmd_en=ram1_p5_cmd_en,
                                    cmd_instr=ram1_p5_cmd_instr,
                                    cmd_bl=ram1_p5_cmd_bl,
                                    cmd_byte_addr=ram1_p5_cmd_byte_addr,
                                    cmd_empty=ram1_p5_cmd_empty,
                                    cmd_full=ram1_p5_cmd_full,
                                    rd_clk=ram1_p5_rd_clk,
                                    rd_en=ram1_p5_rd_en,
                                    rd_data=ram1_p5_rd_data,
                                    rd_empty=ram1_p5_rd_empty,
                                    rd_full=ram1_p5_rd_full,
                                    rd_overflow=ram1_p5_rd_overflow,
                                    rd_count=ram1_p5_rd_count,
                                    rd_error=ram1_p5_rd_error,
                                    name='ram1_p5')

    ram2_controller = ram2_mcb.create_controller(clk_250mhz_int, rst_250mhz_int)

    ram2_p0 = ram2_mcb.create_readwrite_port(cmd_clk=ram2_p0_cmd_clk,
                                    cmd_en=ram2_p0_cmd_en,
                                    cmd_instr=ram2_p0_cmd_instr,
                                    cmd_bl=ram2_p0_cmd_bl,
                                    cmd_byte_addr=ram2_p0_cmd_byte_addr,
                                    cmd_empty=ram2_p0_cmd_empty,
                                    cmd_full=ram2_p0_cmd_full,
                                    wr_clk=ram2_p0_wr_clk,
                                    wr_en=ram2_p0_wr_en,
                                    wr_mask=ram2_p0_wr_mask,
                                    wr_data=ram2_p0_wr_data,
                                    wr_empty=ram2_p0_wr_empty,
                                    wr_full=ram2_p0_wr_full,
                                    wr_underrun=ram2_p0_wr_underrun,
                                    wr_count=ram2_p0_wr_count,
                                    wr_error=ram2_p0_wr_error,
                                    rd_clk=ram2_p0_rd_clk,
                                    rd_en=ram2_p0_rd_en,
                                    rd_data=ram2_p0_rd_data,
                                    rd_empty=ram2_p0_rd_empty,
                                    rd_full=ram2_p0_rd_full,
                                    rd_overflow=ram2_p0_rd_overflow,
                                    rd_count=ram2_p0_rd_count,
                                    rd_error=ram2_p0_rd_error,
                                    name='ram2_p0')

    ram2_p1 = ram2_mcb.create_readwrite_port(cmd_clk=ram2_p1_cmd_clk,
                                    cmd_en=ram2_p1_cmd_en,
                                    cmd_instr=ram2_p1_cmd_instr,
                                    cmd_bl=ram2_p1_cmd_bl,
                                    cmd_byte_addr=ram2_p1_cmd_byte_addr,
                                    cmd_empty=ram2_p1_cmd_empty,
                                    cmd_full=ram2_p1_cmd_full,
                                    wr_clk=ram2_p1_wr_clk,
                                    wr_en=ram2_p1_wr_en,
                                    wr_mask=ram2_p1_wr_mask,
                                    wr_data=ram2_p1_wr_data,
                                    wr_empty=ram2_p1_wr_empty,
                                    wr_full=ram2_p1_wr_full,
                                    wr_underrun=ram2_p1_wr_underrun,
                                    wr_count=ram2_p1_wr_count,
                                    wr_error=ram2_p1_wr_error,
                                    rd_clk=ram2_p1_rd_clk,
                                    rd_en=ram2_p1_rd_en,
                                    rd_data=ram2_p1_rd_data,
                                    rd_empty=ram2_p1_rd_empty,
                                    rd_full=ram2_p1_rd_full,
                                    rd_overflow=ram2_p1_rd_overflow,
                                    rd_count=ram2_p1_rd_count,
                                    rd_error=ram2_p1_rd_error,
                                    name='ram2_p1')

    ram2_p2 = ram2_mcb.create_read_port(cmd_clk=ram2_p2_cmd_clk,
                                    cmd_en=ram2_p2_cmd_en,
                                    cmd_instr=ram2_p2_cmd_instr,
                                    cmd_bl=ram2_p2_cmd_bl,
                                    cmd_byte_addr=ram2_p2_cmd_byte_addr,
                                    cmd_empty=ram2_p2_cmd_empty,
                                    cmd_full=ram2_p2_cmd_full,
                                    rd_clk=ram2_p2_rd_clk,
                                    rd_en=ram2_p2_rd_en,
                                    rd_data=ram2_p2_rd_data,
                                    rd_empty=ram2_p2_rd_empty,
                                    rd_full=ram2_p2_rd_full,
                                    rd_overflow=ram2_p2_rd_overflow,
                                    rd_count=ram2_p2_rd_count,
                                    rd_error=ram2_p2_rd_error,
                                    name='ram2_p2')

    ram2_p3 = ram2_mcb.create_read_port(cmd_clk=ram2_p3_cmd_clk,
                                    cmd_en=ram2_p3_cmd_en,
                                    cmd_instr=ram2_p3_cmd_instr,
                                    cmd_bl=ram2_p3_cmd_bl,
                                    cmd_byte_addr=ram2_p3_cmd_byte_addr,
                                    cmd_empty=ram2_p3_cmd_empty,
                                    cmd_full=ram2_p3_cmd_full,
                                    rd_clk=ram2_p3_rd_clk,
                                    rd_en=ram2_p3_rd_en,
                                    rd_data=ram2_p3_rd_data,
                                    rd_empty=ram2_p3_rd_empty,
                                    rd_full=ram2_p3_rd_full,
                                    rd_overflow=ram2_p3_rd_overflow,
                                    rd_count=ram2_p3_rd_count,
                                    rd_error=ram2_p3_rd_error,
                                    name='ram2_p3')

    ram2_p4 = ram2_mcb.create_read_port(cmd_clk=ram2_p4_cmd_clk,
                                    cmd_en=ram2_p4_cmd_en,
                                    cmd_instr=ram2_p4_cmd_instr,
                                    cmd_bl=ram2_p4_cmd_bl,
                                    cmd_byte_addr=ram2_p4_cmd_byte_addr,
                                    cmd_empty=ram2_p4_cmd_empty,
                                    cmd_full=ram2_p4_cmd_full,
                                    rd_clk=ram2_p4_rd_clk,
                                    rd_en=ram2_p4_rd_en,
                                    rd_data=ram2_p4_rd_data,
                                    rd_empty=ram2_p4_rd_empty,
                                    rd_full=ram2_p4_rd_full,
                                    rd_overflow=ram2_p4_rd_overflow,
                                    rd_count=ram2_p4_rd_count,
                                    rd_error=ram2_p4_rd_error,
                                    name='ram2_p4')

    ram2_p5 = ram2_mcb.create_read_port(cmd_clk=ram2_p5_cmd_clk,
                                    cmd_en=ram2_p5_cmd_en,
                                    cmd_instr=ram2_p5_cmd_instr,
                                    cmd_bl=ram2_p5_cmd_bl,
                                    cmd_byte_addr=ram2_p5_cmd_byte_addr,
                                    cmd_empty=ram2_p5_cmd_empty,
                                    cmd_full=ram2_p5_cmd_full,
                                    rd_clk=ram2_p5_rd_clk,
                                    rd_en=ram2_p5_rd_en,
                                    rd_data=ram2_p5_rd_data,
                                    rd_empty=ram2_p5_rd_empty,
                                    rd_full=ram2_p5_rd_full,
                                    rd_overflow=ram2_p5_rd_overflow,
                                    rd_count=ram2_p5_rd_count,
                                    rd_error=ram2_p5_rd_error,
                                    name='ram2_p5')


    # DUT
    dut = dut_fpga_core(current_test,

                        clk_250mhz_int,
                        rst_250mhz_int,

                        clk_250mhz,
                        rst_250mhz,

                        clk_10mhz,
                        rst_10mhz,

                        ext_clock_selected,

                        cntrl_cs,
                        cntrl_sck,
                        cntrl_mosi,
                        cntrl_miso,

                        ext_trig,

                        ext_prescale,

                        ferc_dat,
                        ferc_clk,
                        ferc_lat,

                        mux_s,

                        adc_sclk,
                        adc_sdo,
                        adc_sdi,
                        adc_cs,
                        adc_eoc,
                        adc_convst,

                        dout,

                        sync_dac,

                        dac_clk,
                        dac_p1_d,
                        dac_p2_d,
                        dac_sdo,
                        dac_sdio,
                        dac_sclk,
                        dac_csb,
                        dac_reset,

                        ram1_calib_done,

                        ram1_p0_cmd_clk,
                        ram1_p0_cmd_en,
                        ram1_p0_cmd_instr,
                        ram1_p0_cmd_bl,
                        ram1_p0_cmd_byte_addr,
                        ram1_p0_cmd_empty,
                        ram1_p0_cmd_full,
                        ram1_p0_wr_clk,
                        ram1_p0_wr_en,
                        ram1_p0_wr_mask,
                        ram1_p0_wr_data,
                        ram1_p0_wr_empty,
                        ram1_p0_wr_full,
                        ram1_p0_wr_underrun,
                        ram1_p0_wr_count,
                        ram1_p0_wr_error,
                        ram1_p0_rd_clk,
                        ram1_p0_rd_en,
                        ram1_p0_rd_data,
                        ram1_p0_rd_empty,
                        ram1_p0_rd_full,
                        ram1_p0_rd_overflow,
                        ram1_p0_rd_count,
                        ram1_p0_rd_error,

                        ram1_p1_cmd_clk,
                        ram1_p1_cmd_en,
                        ram1_p1_cmd_instr,
                        ram1_p1_cmd_bl,
                        ram1_p1_cmd_byte_addr,
                        ram1_p1_cmd_empty,
                        ram1_p1_cmd_full,
                        ram1_p1_wr_clk,
                        ram1_p1_wr_en,
                        ram1_p1_wr_mask,
                        ram1_p1_wr_data,
                        ram1_p1_wr_empty,
                        ram1_p1_wr_full,
                        ram1_p1_wr_underrun,
                        ram1_p1_wr_count,
                        ram1_p1_wr_error,
                        ram1_p1_rd_clk,
                        ram1_p1_rd_en,
                        ram1_p1_rd_data,
                        ram1_p1_rd_empty,
                        ram1_p1_rd_full,
                        ram1_p1_rd_overflow,
                        ram1_p1_rd_count,
                        ram1_p1_rd_error,

                        ram1_p2_cmd_clk,
                        ram1_p2_cmd_en,
                        ram1_p2_cmd_instr,
                        ram1_p2_cmd_bl,
                        ram1_p2_cmd_byte_addr,
                        ram1_p2_cmd_empty,
                        ram1_p2_cmd_full,
                        ram1_p2_rd_clk,
                        ram1_p2_rd_en,
                        ram1_p2_rd_data,
                        ram1_p2_rd_empty,
                        ram1_p2_rd_full,
                        ram1_p2_rd_overflow,
                        ram1_p2_rd_count,
                        ram1_p2_rd_error,

                        ram1_p3_cmd_clk,
                        ram1_p3_cmd_en,
                        ram1_p3_cmd_instr,
                        ram1_p3_cmd_bl,
                        ram1_p3_cmd_byte_addr,
                        ram1_p3_cmd_empty,
                        ram1_p3_cmd_full,
                        ram1_p3_rd_clk,
                        ram1_p3_rd_en,
                        ram1_p3_rd_data,
                        ram1_p3_rd_empty,
                        ram1_p3_rd_full,
                        ram1_p3_rd_overflow,
                        ram1_p3_rd_count,
                        ram1_p3_rd_error,

                        ram1_p4_cmd_clk,
                        ram1_p4_cmd_en,
                        ram1_p4_cmd_instr,
                        ram1_p4_cmd_bl,
                        ram1_p4_cmd_byte_addr,
                        ram1_p4_cmd_empty,
                        ram1_p4_cmd_full,
                        ram1_p4_rd_clk,
                        ram1_p4_rd_en,
                        ram1_p4_rd_data,
                        ram1_p4_rd_empty,
                        ram1_p4_rd_full,
                        ram1_p4_rd_overflow,
                        ram1_p4_rd_count,
                        ram1_p4_rd_error,

                        ram1_p5_cmd_clk,
                        ram1_p5_cmd_en,
                        ram1_p5_cmd_instr,
                        ram1_p5_cmd_bl,
                        ram1_p5_cmd_byte_addr,
                        ram1_p5_cmd_empty,
                        ram1_p5_cmd_full,
                        ram1_p5_rd_clk,
                        ram1_p5_rd_en,
                        ram1_p5_rd_data,
                        ram1_p5_rd_empty,
                        ram1_p5_rd_full,
                        ram1_p5_rd_overflow,
                        ram1_p5_rd_count,
                        ram1_p5_rd_error,

                        ram2_calib_done,

                        ram2_p0_cmd_clk,
                        ram2_p0_cmd_en,
                        ram2_p0_cmd_instr,
                        ram2_p0_cmd_bl,
                        ram2_p0_cmd_byte_addr,
                        ram2_p0_cmd_empty,
                        ram2_p0_cmd_full,
                        ram2_p0_wr_clk,
                        ram2_p0_wr_en,
                        ram2_p0_wr_mask,
                        ram2_p0_wr_data,
                        ram2_p0_wr_empty,
                        ram2_p0_wr_full,
                        ram2_p0_wr_underrun,
                        ram2_p0_wr_count,
                        ram2_p0_wr_error,
                        ram2_p0_rd_clk,
                        ram2_p0_rd_en,
                        ram2_p0_rd_data,
                        ram2_p0_rd_empty,
                        ram2_p0_rd_full,
                        ram2_p0_rd_overflow,
                        ram2_p0_rd_count,
                        ram2_p0_rd_error,

                        ram2_p1_cmd_clk,
                        ram2_p1_cmd_en,
                        ram2_p1_cmd_instr,
                        ram2_p1_cmd_bl,
                        ram2_p1_cmd_byte_addr,
                        ram2_p1_cmd_empty,
                        ram2_p1_cmd_full,
                        ram2_p1_wr_clk,
                        ram2_p1_wr_en,
                        ram2_p1_wr_mask,
                        ram2_p1_wr_data,
                        ram2_p1_wr_empty,
                        ram2_p1_wr_full,
                        ram2_p1_wr_underrun,
                        ram2_p1_wr_count,
                        ram2_p1_wr_error,
                        ram2_p1_rd_clk,
                        ram2_p1_rd_en,
                        ram2_p1_rd_data,
                        ram2_p1_rd_empty,
                        ram2_p1_rd_full,
                        ram2_p1_rd_overflow,
                        ram2_p1_rd_count,
                        ram2_p1_rd_error,

                        ram2_p2_cmd_clk,
                        ram2_p2_cmd_en,
                        ram2_p2_cmd_instr,
                        ram2_p2_cmd_bl,
                        ram2_p2_cmd_byte_addr,
                        ram2_p2_cmd_empty,
                        ram2_p2_cmd_full,
                        ram2_p2_rd_clk,
                        ram2_p2_rd_en,
                        ram2_p2_rd_data,
                        ram2_p2_rd_empty,
                        ram2_p2_rd_full,
                        ram2_p2_rd_overflow,
                        ram2_p2_rd_count,
                        ram2_p2_rd_error,

                        ram2_p3_cmd_clk,
                        ram2_p3_cmd_en,
                        ram2_p3_cmd_instr,
                        ram2_p3_cmd_bl,
                        ram2_p3_cmd_byte_addr,
                        ram2_p3_cmd_empty,
                        ram2_p3_cmd_full,
                        ram2_p3_rd_clk,
                        ram2_p3_rd_en,
                        ram2_p3_rd_data,
                        ram2_p3_rd_empty,
                        ram2_p3_rd_full,
                        ram2_p3_rd_overflow,
                        ram2_p3_rd_count,
                        ram2_p3_rd_error,

                        ram2_p4_cmd_clk,
                        ram2_p4_cmd_en,
                        ram2_p4_cmd_instr,
                        ram2_p4_cmd_bl,
                        ram2_p4_cmd_byte_addr,
                        ram2_p4_cmd_empty,
                        ram2_p4_cmd_full,
                        ram2_p4_rd_clk,
                        ram2_p4_rd_en,
                        ram2_p4_rd_data,
                        ram2_p4_rd_empty,
                        ram2_p4_rd_full,
                        ram2_p4_rd_overflow,
                        ram2_p4_rd_count,
                        ram2_p4_rd_error,

                        ram2_p5_cmd_clk,
                        ram2_p5_cmd_en,
                        ram2_p5_cmd_instr,
                        ram2_p5_cmd_bl,
                        ram2_p5_cmd_byte_addr,
                        ram2_p5_cmd_empty,
                        ram2_p5_cmd_full,
                        ram2_p5_rd_clk,
                        ram2_p5_rd_en,
                        ram2_p5_rd_data,
                        ram2_p5_rd_empty,
                        ram2_p5_rd_full,
                        ram2_p5_rd_overflow,
                        ram2_p5_rd_count,
                        ram2_p5_rd_error)

    @always(delay(2))
    def clkgen_250mhz_int():
        clk_250mhz_int.next = not clk_250mhz_int

    @always(delay(2))
    def clkgen_250mhz():
        clk_250mhz.next = not clk_250mhz

    @always(delay(50))
    def clkgen_10mhz():
        clk_10mhz.next = not clk_10mhz

    @instance
    def check():
        yield delay(100)
        yield clk_250mhz_int.posedge
        rst_250mhz_int.next = 1
        rst_250mhz.next = 1
        rst_10mhz.next = 1
        yield clk_250mhz_int.posedge
        yield clk_250mhz_int.posedge
        yield clk_250mhz_int.posedge
        yield clk_250mhz_int.posedge
        rst_250mhz_int.next = 0
        rst_250mhz.next = 0
        rst_10mhz.next = 0
        yield clk_250mhz_int.posedge
        yield delay(100)
        yield clk_250mhz_int.posedge

        yield delay(1000)
        yield clk_250mhz_int.posedge
        ram1_calib_done.next = True
        ram2_calib_done.next = True

        yield delay(100)
        yield clk_250mhz_int.posedge

        yield clk_250mhz_int.posedge

        while not master_rx_queue.empty():
            master_rx_queue.get()

        yield clk_250mhz_int.posedge
        print("test 1: Bank 0 MCB")
        current_test.next = 1

        # write data
        test_frame = bytearray('\xB0\x00\x00\x00\x20\x11\x22\x33\x44\x55\x66\x77')
        master_tx_queue.put(test_frame)
        yield clk_250mhz_int.posedge

        # wait for end of transaction
        yield cntrl_cs.posedge
        yield delay(100)
        yield clk_250mhz_int.posedge

        # check memory contents
        data = ram1_mcb.read_mem(32, 7)
        assert data == '\x11\x22\x33\x44\x55\x66\x77'

        # drop RX frame
        master_rx_queue.get(False)

        yield delay(100)

        # read data
        test_frame = bytearray('\xA0\x00\x00\x00\x20'+'\x00'*10)
        master_tx_queue.put(test_frame)
        yield clk_250mhz_int.posedge

        # wait for end of transaction
        yield cntrl_cs.posedge
        yield delay(100)
        yield clk_250mhz_int.posedge

        rx_frame = bytearray(master_rx_queue.get(False))
        print(repr(rx_frame))
        assert rx_frame.find('\x01\x11\x22\x33\x44\x55\x66\x77') >= 0

        yield delay(100)

        yield clk_250mhz_int.posedge
        print("test 2: Bank 1 MCB")
        current_test.next = 2

        # write data
        test_frame = bytearray('\xB1\x00\x00\x00\x20\x11\x22\x33\x44\x55\x66\x77')
        master_tx_queue.put(test_frame)
        yield clk_250mhz_int.posedge

        # wait for end of transaction
        yield cntrl_cs.posedge
        yield delay(100)
        yield clk_250mhz_int.posedge

        # check memory contents
        data = ram2_mcb.read_mem(32, 7)
        assert data == '\x11\x22\x33\x44\x55\x66\x77'

        # drop RX frame
        master_rx_queue.get(False)

        yield delay(100)

        # read data
        test_frame = bytearray('\xA1\x00\x00\x00\x20'+'\x00'*10)
        master_tx_queue.put(test_frame)
        yield clk_250mhz_int.posedge

        # wait for end of transaction
        yield cntrl_cs.posedge
        yield delay(100)
        yield clk_250mhz_int.posedge

        rx_frame = bytearray(master_rx_queue.get(False))
        print(repr(rx_frame))
        assert rx_frame.find('\x01\x11\x22\x33\x44\x55\x66\x77') >= 0

        yield delay(100)

        yield clk_250mhz_int.posedge
        print("test 2: Control registers")
        current_test.next = 2

        # write data
        test_frame = bytearray('\xBF\x00\x00\x00\x00\x11\x22\x33\x44\x55\x66\x77')
        master_tx_queue.put(test_frame)
        yield clk_250mhz_int.posedge

        # wait for end of transaction
        yield cntrl_cs.posedge
        yield delay(100)
        yield clk_250mhz_int.posedge

        # drop RX frame
        master_rx_queue.get(False)

        yield delay(100)

        # read data
        test_frame = bytearray('\xAF\x00\x00\x00\x00'+'\x00'*10)
        master_tx_queue.put(test_frame)
        yield clk_250mhz_int.posedge

        # wait for end of transaction
        yield cntrl_cs.posedge
        yield delay(100)
        yield clk_250mhz_int.posedge

        rx_frame = bytearray(master_rx_queue.get(False))
        print(repr(rx_frame))
        assert rx_frame.find('\x01\x11\x22\x33\x44\x55\x66\x77') >= 0

        yield delay(100)

        raise StopSimulation

    return dut, master, ram1_controller, ram1_p0, ram1_p1, ram1_p2, ram1_p3, ram1_p4, ram1_p5, ram2_controller, ram2_p0, ram2_p1, ram2_p2, ram2_p3, ram2_p4, ram2_p5, clkgen_250mhz_int, clkgen_250mhz, clkgen_10mhz, check

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

