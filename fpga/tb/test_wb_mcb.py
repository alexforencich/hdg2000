#!/usr/bin/env python2
"""

Copyright (c) 2015 Alex Forencich

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

import wb
import mcb

module = 'wb_mcb'

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("test_%s.v" % module)

src = ' '.join(srcs)

build_cmd = "iverilog -o test_%s.vvp %s" % (module, src)

def dut_wb_mcb(clk,
               rst,
               current_test,
               wb_adr_i,
               wb_dat_i,
               wb_dat_o,
               wb_we_i,
               wb_sel_i,
               wb_stb_i,
               wb_ack_o,
               wb_cyc_i,
               mcb_cmd_clk,
               mcb_cmd_en,
               mcb_cmd_instr,
               mcb_cmd_bl,
               mcb_cmd_byte_addr,
               mcb_cmd_empty,
               mcb_cmd_full,
               mcb_wr_clk,
               mcb_wr_en,
               mcb_wr_mask,
               mcb_wr_data,
               mcb_wr_empty,
               mcb_wr_full,
               mcb_wr_underrun,
               mcb_wr_count,
               mcb_wr_error,
               mcb_rd_clk,
               mcb_rd_en,
               mcb_rd_data,
               mcb_rd_empty,
               mcb_rd_full,
               mcb_rd_overflow,
               mcb_rd_count,
               mcb_rd_error):

    if os.system(build_cmd):
        raise Exception("Error running build command")
    return Cosimulation("vvp -m myhdl test_%s.vvp -lxt2" % module,
                clk=clk,
                rst=rst,
                current_test=current_test,
                wb_adr_i=wb_adr_i,
                wb_dat_i=wb_dat_i,
                wb_dat_o=wb_dat_o,
                wb_we_i=wb_we_i,
                wb_sel_i=wb_sel_i,
                wb_stb_i=wb_stb_i,
                wb_ack_o=wb_ack_o,
                wb_cyc_i=wb_cyc_i,
                mcb_cmd_clk=mcb_cmd_clk,
                mcb_cmd_en=mcb_cmd_en,
                mcb_cmd_instr=mcb_cmd_instr,
                mcb_cmd_bl=mcb_cmd_bl,
                mcb_cmd_byte_addr=mcb_cmd_byte_addr,
                mcb_cmd_empty=mcb_cmd_empty,
                mcb_cmd_full=mcb_cmd_full,
                mcb_wr_clk=mcb_wr_clk,
                mcb_wr_en=mcb_wr_en,
                mcb_wr_mask=mcb_wr_mask,
                mcb_wr_data=mcb_wr_data,
                mcb_wr_empty=mcb_wr_empty,
                mcb_wr_full=mcb_wr_full,
                mcb_wr_underrun=mcb_wr_underrun,
                mcb_wr_count=mcb_wr_count,
                mcb_wr_error=mcb_wr_error,
                mcb_rd_clk=mcb_rd_clk,
                mcb_rd_en=mcb_rd_en,
                mcb_rd_data=mcb_rd_data,
                mcb_rd_empty=mcb_rd_empty,
                mcb_rd_full=mcb_rd_full,
                mcb_rd_overflow=mcb_rd_overflow,
                mcb_rd_count=mcb_rd_count,
                mcb_rd_error=mcb_rd_error)

def bench():

    # Parameters


    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    wb_adr_i = Signal(intbv(0)[32:])
    wb_dat_i = Signal(intbv(0)[32:])
    wb_we_i = Signal(bool(0))
    wb_sel_i = Signal(intbv(0)[4:])
    wb_stb_i = Signal(bool(0))
    wb_cyc_i = Signal(bool(0))
    mcb_cmd_empty = Signal(bool(0))
    mcb_cmd_full = Signal(bool(0))
    mcb_wr_empty = Signal(bool(0))
    mcb_wr_full = Signal(bool(0))
    mcb_wr_underrun = Signal(bool(0))
    mcb_wr_count = Signal(intbv(0)[7:])
    mcb_wr_error = Signal(bool(0))
    mcb_rd_data = Signal(intbv(0)[32:])
    mcb_rd_empty = Signal(bool(0))
    mcb_rd_full = Signal(bool(0))
    mcb_rd_overflow = Signal(bool(0))
    mcb_rd_count = Signal(intbv(0)[7:])
    mcb_rd_error = Signal(bool(0))

    # Outputs
    wb_dat_o = Signal(intbv(0)[32:])
    wb_ack_o = Signal(bool(0))
    mcb_cmd_clk = Signal(bool(0))
    mcb_cmd_en = Signal(bool(0))
    mcb_cmd_instr = Signal(intbv(0)[3:])
    mcb_cmd_bl = Signal(intbv(0)[6:])
    mcb_cmd_byte_addr = Signal(intbv(0)[32:])
    mcb_wr_clk = Signal(bool(0))
    mcb_wr_en = Signal(bool(0))
    mcb_wr_mask = Signal(intbv(0)[4:])
    mcb_wr_data = Signal(intbv(0)[32:])
    mcb_rd_clk = Signal(bool(0))
    mcb_rd_en = Signal(bool(1))

    # WB master
    wbm_inst = wb.WBMaster()

    wbm_logic = wbm_inst.create_logic(clk,
                                      adr_o=wb_adr_i,
                                      dat_i=wb_dat_o,
                                      dat_o=wb_dat_i,
                                      we_o=wb_we_i,
                                      sel_o=wb_sel_i,
                                      stb_o=wb_stb_i,
                                      ack_i=wb_ack_o,
                                      cyc_o=wb_cyc_i,
                                      name='master')

    # MCB model
    mcb_inst = mcb.MCB(2**16)

    mcb_controller = mcb_inst.create_controller(clk, rst)

    mcb_port0 = mcb_inst.create_readwrite_port(cmd_clk=mcb_cmd_clk,
                                    cmd_en=mcb_cmd_en,
                                    cmd_instr=mcb_cmd_instr,
                                    cmd_bl=mcb_cmd_bl,
                                    cmd_byte_addr=mcb_cmd_byte_addr,
                                    cmd_empty=mcb_cmd_empty,
                                    cmd_full=mcb_cmd_full,
                                    wr_clk=mcb_wr_clk,
                                    wr_en=mcb_wr_en,
                                    wr_mask=mcb_wr_mask,
                                    wr_data=mcb_wr_data,
                                    wr_empty=mcb_wr_empty,
                                    wr_full=mcb_wr_full,
                                    wr_underrun=mcb_wr_underrun,
                                    wr_count=mcb_wr_count,
                                    wr_error=mcb_wr_error,
                                    rd_clk=mcb_rd_clk,
                                    rd_en=mcb_rd_en,
                                    rd_data=mcb_rd_data,
                                    rd_empty=mcb_rd_empty,
                                    rd_full=mcb_rd_full,
                                    rd_overflow=mcb_rd_overflow,
                                    rd_count=mcb_rd_count,
                                    rd_error=mcb_rd_error,
                                    name='port0')

    # DUT
    dut = dut_wb_mcb(clk,
                     rst,
                     current_test,
                     wb_adr_i,
                     wb_dat_i,
                     wb_dat_o,
                     wb_we_i,
                     wb_sel_i,
                     wb_stb_i,
                     wb_ack_o,
                     wb_cyc_i,
                     mcb_cmd_clk,
                     mcb_cmd_en,
                     mcb_cmd_instr,
                     mcb_cmd_bl,
                     mcb_cmd_byte_addr,
                     mcb_cmd_empty,
                     mcb_cmd_full,
                     mcb_wr_clk,
                     mcb_wr_en,
                     mcb_wr_mask,
                     mcb_wr_data,
                     mcb_wr_empty,
                     mcb_wr_full,
                     mcb_wr_underrun,
                     mcb_wr_count,
                     mcb_wr_error,
                     mcb_rd_clk,
                     mcb_rd_en,
                     mcb_rd_data,
                     mcb_rd_empty,
                     mcb_rd_full,
                     mcb_rd_overflow,
                     mcb_rd_count,
                     mcb_rd_error)

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    @instance
    def check():
        yield delay(100)
        yield clk.posedge
        rst.next = 1
        yield clk.posedge
        rst.next = 0
        yield clk.posedge
        yield delay(100)
        yield clk.posedge

        yield clk.posedge
        print("test 1: write")
        current_test.next = 1

        wbm_inst.init_write(4, '\x11\x22\x33\x44')

        yield wbm_inst.wait()
        yield clk.posedge

        data = mcb_inst.read_mem(0, 32)
        for i in range(0, len(data), 16):
            print(" ".join("{:02x}".format(ord(c)) for c in data[i:i+16]))

        assert mcb_inst.read_mem(4,4) == '\x11\x22\x33\x44'

        yield delay(100)

        yield clk.posedge
        print("test 2: read")
        current_test.next = 2

        wbm_inst.init_read(4, 4)

        yield wbm_inst.wait()
        yield clk.posedge

        data = wbm_inst.get_read_data()
        assert data[0] == 4
        assert data[1] == '\x11\x22\x33\x44'

        yield delay(100)

        yield clk.posedge
        print("test 3: various writes")
        current_test.next = 3

        for length in range(1,8):
            for offset in range(4):
                wbm_inst.init_write(256*(16*offset+length)+offset, '\x11\x22\x33\x44\x55\x66\x77\x88'[0:length])

                yield wbm_inst.wait()
                yield clk.posedge

                data = mcb_inst.read_mem(256*(16*offset+length), 32)
                for i in range(0, len(data), 16):
                    print(" ".join("{:02x}".format(ord(c)) for c in data[i:i+16]))

                assert mcb_inst.read_mem(256*(16*offset+length)+offset,length) == '\x11\x22\x33\x44\x55\x66\x77\x88'[0:length]

        yield delay(100)

        yield clk.posedge
        print("test 4: various reads")
        current_test.next = 4

        for length in range(1,8):
            for offset in range(4):
                wbm_inst.init_read(256*(16*offset+length)+offset, length)

                yield wbm_inst.wait()
                yield clk.posedge

                data = wbm_inst.get_read_data()
                assert data[0] == 256*(16*offset+length)+offset
                assert data[1] == '\x11\x22\x33\x44\x55\x66\x77\x88'[0:length]

        yield delay(100)

        raise StopSimulation

    return dut, wbm_logic, mcb_controller, mcb_port0, clkgen, check

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
