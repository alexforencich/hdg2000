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

import mcb

def bench():

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_axis_tdata = Signal(intbv(0)[8:])
    input_axis_tkeep = Signal(intbv(0)[1:])
    input_axis_tvalid = Signal(bool(0))
    input_axis_tlast = Signal(bool(0))
    input_axis_tuser = Signal(bool(0))
    output_axis_tready = Signal(bool(0))

    port0_cmd_en = Signal(bool(0))
    port0_cmd_instr = Signal(intbv(0)[3:])
    port0_cmd_bl = Signal(intbv(0)[6:])
    port0_cmd_byte_addr = Signal(intbv(0)[30:])
    port0_wr_en = Signal(bool(0))
    port0_wr_mask = Signal(intbv(0)[4:])
    port0_wr_data = Signal(intbv(0)[32:])
    port0_rd_en = Signal(bool(0))

    # Outputs
    port0_cmd_empty = Signal(bool(0))
    port0_cmd_full = Signal(bool(0))
    port0_wr_empty = Signal(bool(0))
    port0_wr_full = Signal(bool(0))
    port0_wr_underrun = Signal(bool(0))
    port0_wr_count = Signal(intbv(0)[7:])
    port0_wr_error = Signal(bool(0))
    port0_rd_data = Signal(intbv(0)[32:])
    port0_rd_empty = Signal(bool(0))
    port0_rd_full = Signal(bool(0))
    port0_rd_overflow = Signal(bool(0))
    port0_rd_count = Signal(intbv(0)[7:])
    port0_rd_error = Signal(bool(0))

    # MCB model
    mcb_inst = mcb.MCB(1024)

    mcb_controller = mcb_inst.create_controller(clk, rst)

    mcb_port0 = mcb_inst.create_readwrite_port(cmd_clk=clk,
                                    cmd_en=port0_cmd_en,
                                    cmd_instr=port0_cmd_instr,
                                    cmd_bl=port0_cmd_bl,
                                    cmd_byte_addr=port0_cmd_byte_addr,
                                    cmd_empty=port0_cmd_empty,
                                    cmd_full=port0_cmd_full,
                                    wr_clk=clk,
                                    wr_en=port0_wr_en,
                                    wr_mask=port0_wr_mask,
                                    wr_data=port0_wr_data,
                                    wr_empty=port0_wr_empty,
                                    wr_full=port0_wr_full,
                                    wr_underrun=port0_wr_underrun,
                                    wr_count=port0_wr_count,
                                    wr_error=port0_wr_error,
                                    rd_clk=clk,
                                    rd_en=port0_rd_en,
                                    rd_data=port0_rd_data,
                                    rd_empty=port0_rd_empty,
                                    rd_full=port0_rd_full,
                                    rd_overflow=port0_rd_overflow,
                                    rd_count=port0_rd_count,
                                    rd_error=port0_rd_error,
                                    name='port0')

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
        print("test 1: baseline")
        current_test.next = 1

        data = mcb_inst.read_mem(0, 32)
        for i in range(0, len(data), 16):
            print(" ".join("{:02x}".format(ord(c)) for c in data[i:i+16]))

        yield clk.posedge
        print("test 2: direct write")
        current_test.next = 2

        mcb_inst.write_mem(0, b'test')

        data = mcb_inst.read_mem(0, 32)
        for i in range(0, len(data), 16):
            print(" ".join("{:02x}".format(ord(c)) for c in data[i:i+16]))

        yield clk.posedge
        print("test 2: write via port0")
        current_test.next = 2

        yield clk.posedge
        port0_wr_mask.next = 0xf
        port0_wr_data.next = 0x44332211
        port0_wr_en.next = 1
        
        port0_cmd_instr.next = 0
        port0_cmd_bl.next = 0
        port0_cmd_byte_addr.next = 4
        port0_cmd_en.next = 1
        
        yield clk.posedge
        port0_wr_en.next = 0
        port0_cmd_en.next = 0

        yield clk.posedge
        yield clk.posedge

        data = mcb_inst.read_mem(0, 32)
        for i in range(0, len(data), 16):
            print(" ".join("{:02x}".format(ord(c)) for c in data[i:i+16]))

        raise StopSimulation

    return mcb_controller, mcb_port0, clkgen, check

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

