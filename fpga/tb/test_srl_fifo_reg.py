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

module = 'srl_fifo_reg'

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("test_%s.v" % module)

src = ' '.join(srcs)

build_cmd = "iverilog -o test_%s.vvp %s" % (module, src)

def dut_srl_fifo_reg(clk,
                     rst,
                     current_test,

                     write_en,
                     write_data,
                     read_en,
                     read_data,
                     full,
                     empty):

    if os.system(build_cmd):
        raise Exception("Error running build command")
    return Cosimulation("vvp -m myhdl test_%s.vvp -lxt2" % module,
                clk=clk,
                rst=rst,
                current_test=current_test,

                write_en=write_en,
                write_data=write_data,
                read_en=read_en,
                read_data=read_data,
                full=full,
                empty=empty)

def bench():

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    write_en = Signal(bool(0))
    write_data = Signal(intbv(0)[8:])
    read_en = Signal(bool(0))
    
    # Outputs
    read_data = Signal(intbv(0)[8:])
    full = Signal(bool(0))
    empty = Signal(bool(0))

    # DUT
    dut = dut_srl_fifo_reg(clk,
                          rst,
                          current_test,

                          write_en,
                          write_data,
                          read_en,
                          read_data,
                          full,
                          empty)

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

        yield clk.posedge
        print("test 1: write data")
        current_test.next = 1

        write_data.next = 0xAA
        write_en.next = True
        yield clk.posedge
        write_data.next = 0x00
        write_en.next = False
        yield clk.posedge

        #assert full

        yield delay(100)

        yield clk.posedge
        print("test 2: read data")
        current_test.next = 2

        read_en.next = True
        yield clk.posedge
        assert read_data == 0xAA
        read_en.next = False
        yield clk.posedge

        #assert empty

        yield delay(100)

        yield clk.posedge
        print("test 3: write data")
        current_test.next = 3

        write_data.next = 0xAA
        write_en.next = True
        yield clk.posedge
        write_data.next = 0xBB
        write_en.next = True
        yield clk.posedge
        write_data.next = 0x00
        write_en.next = False
        yield clk.posedge

        #assert full

        yield delay(100)

        yield clk.posedge
        print("test 4: read data")
        current_test.next = 4

        read_en.next = True
        yield clk.posedge
        #assert read_data == 0xAA
        read_en.next = True
        yield clk.posedge
        #assert read_data == 0xAA
        read_en.next = False
        yield clk.posedge

        #assert empty

        yield delay(100)

        raise StopSimulation

        yield clk.posedge
        print("test 3: transfer data")
        current_test.next = 3

        write_data.next = 0x11
        write_en.next = True
        read_en.next = False
        yield clk.posedge
        write_data.next = 0x22
        write_en.next = True
        read_en.next = False
        yield clk.posedge
        write_data.next = 0x33
        write_en.next = True
        read_en.next = False
        yield clk.posedge
        write_data.next = 0x44
        write_en.next = True
        read_en.next = True
        yield clk.posedge
        assert read_data == 0x11
        write_data.next = 0x55
        write_en.next = True
        read_en.next = True
        yield clk.posedge
        assert read_data == 0x22
        write_data.next = 0x66
        write_en.next = True
        read_en.next = True
        yield clk.posedge
        assert read_data == 0x33
        write_data.next = 0x77
        write_en.next = True
        read_en.next = True
        yield clk.posedge
        assert read_data == 0x44
        write_data.next = 0x88
        write_en.next = True
        read_en.next = True
        yield clk.posedge
        assert read_data == 0x55
        write_data.next = 0x00
        write_en.next = False
        read_en.next = True
        yield clk.posedge
        assert read_data == 0x66
        read_en.next = True
        yield clk.posedge
        assert read_data == 0x77
        read_en.next = True
        yield clk.posedge
        assert read_data == 0x88
        read_en.next = False
        yield clk.posedge

        assert empty

        yield delay(100)

        raise StopSimulation

    return dut, clkgen, check

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

