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

import axis_ep
import mcb

module = 'soc_interface'

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("test_%s.v" % module)

src = ' '.join(srcs)

build_cmd = "iverilog -o test_%s.vvp %s" % (module, src)

def dut_soc_interface(clk,
                 rst,
                 current_test,

                 input_axis_tdata,
                 input_axis_tvalid,
                 input_axis_tready,
                 input_axis_tlast,

                 output_axis_tdata,
                 output_axis_tvalid,
                 output_axis_tready,
                 output_axis_tlast,

                 port0_cmd_clk,
                 port0_cmd_en,
                 port0_cmd_instr,
                 port0_cmd_bl,
                 port0_cmd_byte_addr,
                 port0_cmd_empty,
                 port0_cmd_full,
                 port0_wr_clk,
                 port0_wr_en,
                 port0_wr_mask,
                 port0_wr_data,
                 port0_wr_empty,
                 port0_wr_full,
                 port0_wr_underrun,
                 port0_wr_count,
                 port0_wr_error,
                 port0_rd_clk,
                 port0_rd_en,
                 port0_rd_data,
                 port0_rd_empty,
                 port0_rd_full,
                 port0_rd_overflow,
                 port0_rd_count,
                 port0_rd_error,

                 port1_cmd_clk,
                 port1_cmd_en,
                 port1_cmd_instr,
                 port1_cmd_bl,
                 port1_cmd_byte_addr,
                 port1_cmd_empty,
                 port1_cmd_full,
                 port1_wr_clk,
                 port1_wr_en,
                 port1_wr_mask,
                 port1_wr_data,
                 port1_wr_empty,
                 port1_wr_full,
                 port1_wr_underrun,
                 port1_wr_count,
                 port1_wr_error,
                 port1_rd_clk,
                 port1_rd_en,
                 port1_rd_data,
                 port1_rd_empty,
                 port1_rd_full,
                 port1_rd_overflow,
                 port1_rd_count,
                 port1_rd_error,

                 busy):

    if os.system(build_cmd):
        raise Exception("Error running build command")
    return Cosimulation("vvp -m myhdl test_%s.vvp -lxt2" % module,
                clk=clk,
                rst=rst,
                current_test=current_test,

                input_axis_tdata=input_axis_tdata,
                input_axis_tvalid=input_axis_tvalid,
                input_axis_tready=input_axis_tready,
                input_axis_tlast=input_axis_tlast,

                output_axis_tdata=output_axis_tdata,
                output_axis_tvalid=output_axis_tvalid,
                output_axis_tready=output_axis_tready,
                output_axis_tlast=output_axis_tlast,

                port0_cmd_clk=port0_cmd_clk,
                port0_cmd_en=port0_cmd_en,
                port0_cmd_instr=port0_cmd_instr,
                port0_cmd_bl=port0_cmd_bl,
                port0_cmd_byte_addr=port0_cmd_byte_addr,
                port0_cmd_empty=port0_cmd_empty,
                port0_cmd_full=port0_cmd_full,
                port0_wr_clk=port0_wr_clk,
                port0_wr_en=port0_wr_en,
                port0_wr_mask=port0_wr_mask,
                port0_wr_data=port0_wr_data,
                port0_wr_empty=port0_wr_empty,
                port0_wr_full=port0_wr_full,
                port0_wr_underrun=port0_wr_underrun,
                port0_wr_count=port0_wr_count,
                port0_wr_error=port0_wr_error,
                port0_rd_clk=port0_rd_clk,
                port0_rd_en=port0_rd_en,
                port0_rd_data=port0_rd_data,
                port0_rd_empty=port0_rd_empty,
                port0_rd_full=port0_rd_full,
                port0_rd_overflow=port0_rd_overflow,
                port0_rd_count=port0_rd_count,
                port0_rd_error=port0_rd_error,

                port1_cmd_clk=port1_cmd_clk,
                port1_cmd_en=port1_cmd_en,
                port1_cmd_instr=port1_cmd_instr,
                port1_cmd_bl=port1_cmd_bl,
                port1_cmd_byte_addr=port1_cmd_byte_addr,
                port1_cmd_empty=port1_cmd_empty,
                port1_cmd_full=port1_cmd_full,
                port1_wr_clk=port1_wr_clk,
                port1_wr_en=port1_wr_en,
                port1_wr_mask=port1_wr_mask,
                port1_wr_data=port1_wr_data,
                port1_wr_empty=port1_wr_empty,
                port1_wr_full=port1_wr_full,
                port1_wr_underrun=port1_wr_underrun,
                port1_wr_count=port1_wr_count,
                port1_wr_error=port1_wr_error,
                port1_rd_clk=port1_rd_clk,
                port1_rd_en=port1_rd_en,
                port1_rd_data=port1_rd_data,
                port1_rd_empty=port1_rd_empty,
                port1_rd_full=port1_rd_full,
                port1_rd_overflow=port1_rd_overflow,
                port1_rd_count=port1_rd_count,
                port1_rd_error=port1_rd_error,

                busy=busy)

def bench():

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_axis_tdata = Signal(intbv(0)[8:])
    input_axis_tvalid = Signal(bool(0))
    input_axis_tlast = Signal(bool(0))
    output_axis_tready = Signal(bool(0))

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

    port1_cmd_empty = Signal(bool(0))
    port1_cmd_full = Signal(bool(0))
    port1_wr_empty = Signal(bool(0))
    port1_wr_full = Signal(bool(0))
    port1_wr_underrun = Signal(bool(0))
    port1_wr_count = Signal(intbv(0)[7:])
    port1_wr_error = Signal(bool(0))
    port1_rd_data = Signal(intbv(0)[32:])
    port1_rd_empty = Signal(bool(0))
    port1_rd_full = Signal(bool(0))
    port1_rd_overflow = Signal(bool(0))
    port1_rd_count = Signal(intbv(0)[7:])
    port1_rd_error = Signal(bool(0))

    # Outputs
    input_axis_tready = Signal(bool(0))
    output_axis_tdata = Signal(intbv(0)[8:])
    output_axis_tvalid = Signal(bool(0))
    output_axis_tlast = Signal(bool(0))

    port0_cmd_clk = Signal(bool(0))
    port0_cmd_en = Signal(bool(0))
    port0_cmd_instr = Signal(intbv(0)[3:])
    port0_cmd_bl = Signal(intbv(0)[6:])
    port0_cmd_byte_addr = Signal(intbv(0)[30:])
    port0_wr_clk = Signal(bool(0))
    port0_wr_en = Signal(bool(0))
    port0_wr_mask = Signal(intbv(0)[4:])
    port0_wr_data = Signal(intbv(0)[32:])
    port0_rd_clk = Signal(bool(0))
    port0_rd_en = Signal(bool(0))

    port1_cmd_clk = Signal(bool(0))
    port1_cmd_en = Signal(bool(0))
    port1_cmd_instr = Signal(intbv(0)[3:])
    port1_cmd_bl = Signal(intbv(0)[6:])
    port1_cmd_byte_addr = Signal(intbv(0)[30:])
    port1_wr_clk = Signal(bool(0))
    port1_wr_en = Signal(bool(0))
    port1_wr_mask = Signal(intbv(0)[4:])
    port1_wr_data = Signal(intbv(0)[32:])
    port1_rd_clk = Signal(bool(0))
    port1_rd_en = Signal(bool(0))

    busy = Signal(bool(0))

    # sources and sinks
    source_queue = Queue()
    source_pause = Signal(bool(0))
    sink_queue = Queue()
    sink_pause = Signal(bool(0))

    source = axis_ep.AXIStreamSource(clk,
                                     rst,
                                     tdata=input_axis_tdata,
                                     tvalid=input_axis_tvalid,
                                     tready=input_axis_tready,
                                     tlast=input_axis_tlast,
                                     fifo=source_queue,
                                     pause=source_pause,
                                     name='source')

    sink = axis_ep.AXIStreamSink(clk,
                                 rst,
                                 tdata=output_axis_tdata,
                                 tvalid=output_axis_tvalid,
                                 tready=output_axis_tready,
                                 tlast=output_axis_tlast,
                                 fifo=sink_queue,
                                 pause=sink_pause,
                                 name='sink')

    # MCB model
    mcb0_inst = mcb.MCB(1024)
    mcb1_inst = mcb.MCB(1024)

    mcb0_controller = mcb0_inst.create_controller(clk, rst)

    mcb0_port0 = mcb0_inst.create_readwrite_port(cmd_clk=port0_cmd_clk,
                                    cmd_en=port0_cmd_en,
                                    cmd_instr=port0_cmd_instr,
                                    cmd_bl=port0_cmd_bl,
                                    cmd_byte_addr=port0_cmd_byte_addr,
                                    cmd_empty=port0_cmd_empty,
                                    cmd_full=port0_cmd_full,
                                    wr_clk=port0_wr_clk,
                                    wr_en=port0_wr_en,
                                    wr_mask=port0_wr_mask,
                                    wr_data=port0_wr_data,
                                    wr_empty=port0_wr_empty,
                                    wr_full=port0_wr_full,
                                    wr_underrun=port0_wr_underrun,
                                    wr_count=port0_wr_count,
                                    wr_error=port0_wr_error,
                                    rd_clk=port0_rd_clk,
                                    rd_en=port0_rd_en,
                                    rd_data=port0_rd_data,
                                    rd_empty=port0_rd_empty,
                                    rd_full=port0_rd_full,
                                    rd_overflow=port0_rd_overflow,
                                    rd_count=port0_rd_count,
                                    rd_error=port0_rd_error,
                                    name='mcb0port0')

    mcb1_controller = mcb1_inst.create_controller(clk, rst)

    mcb1_port0 = mcb1_inst.create_readwrite_port(cmd_clk=port1_cmd_clk,
                                    cmd_en=port1_cmd_en,
                                    cmd_instr=port1_cmd_instr,
                                    cmd_bl=port1_cmd_bl,
                                    cmd_byte_addr=port1_cmd_byte_addr,
                                    cmd_empty=port1_cmd_empty,
                                    cmd_full=port1_cmd_full,
                                    wr_clk=port1_wr_clk,
                                    wr_en=port1_wr_en,
                                    wr_mask=port1_wr_mask,
                                    wr_data=port1_wr_data,
                                    wr_empty=port1_wr_empty,
                                    wr_full=port1_wr_full,
                                    wr_underrun=port1_wr_underrun,
                                    wr_count=port1_wr_count,
                                    wr_error=port1_wr_error,
                                    rd_clk=port1_rd_clk,
                                    rd_en=port1_rd_en,
                                    rd_data=port1_rd_data,
                                    rd_empty=port1_rd_empty,
                                    rd_full=port1_rd_full,
                                    rd_overflow=port1_rd_overflow,
                                    rd_count=port1_rd_count,
                                    rd_error=port1_rd_error,
                                    name='mcb0port0')

    # DUT
    dut = dut_soc_interface(clk,
                        rst,
                        current_test,

                        input_axis_tdata,
                        input_axis_tvalid,
                        input_axis_tready,
                        input_axis_tlast,

                        output_axis_tdata,
                        output_axis_tvalid,
                        output_axis_tready,
                        output_axis_tlast,

                        port0_cmd_clk,
                        port0_cmd_en,
                        port0_cmd_instr,
                        port0_cmd_bl,
                        port0_cmd_byte_addr,
                        port0_cmd_empty,
                        port0_cmd_full,
                        port0_wr_clk,
                        port0_wr_en,
                        port0_wr_mask,
                        port0_wr_data,
                        port0_wr_empty,
                        port0_wr_full,
                        port0_wr_underrun,
                        port0_wr_count,
                        port0_wr_error,
                        port0_rd_clk,
                        port0_rd_en,
                        port0_rd_data,
                        port0_rd_empty,
                        port0_rd_full,
                        port0_rd_overflow,
                        port0_rd_count,
                        port0_rd_error,

                        port1_cmd_clk,
                        port1_cmd_en,
                        port1_cmd_instr,
                        port1_cmd_bl,
                        port1_cmd_byte_addr,
                        port1_cmd_empty,
                        port1_cmd_full,
                        port1_wr_clk,
                        port1_wr_en,
                        port1_wr_mask,
                        port1_wr_data,
                        port1_wr_empty,
                        port1_wr_full,
                        port1_wr_underrun,
                        port1_wr_count,
                        port1_wr_error,
                        port1_rd_clk,
                        port1_rd_en,
                        port1_rd_data,
                        port1_rd_empty,
                        port1_rd_full,
                        port1_rd_overflow,
                        port1_rd_count,
                        port1_rd_error,

                        busy)

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
        print("test 1: Write to port 0")
        current_test.next = 1

        test_frame = bytearray('\xB0\x00\x00\x00\x00\xAA')
        source_queue.put(test_frame)
        yield clk.posedge

        yield busy.negedge
        yield clk.posedge
        yield clk.posedge

        data = mcb0_inst.read_mem(0, 1)
        
        assert data == '\xAA'

        yield delay(100)

        yield clk.posedge
        print("test 2: Longer write to port 0")
        current_test.next = 2

        test_frame = bytearray('\xB0\x00\x00\x00\x20\x11\x22\x33\x44\x55\x66\x77')
        source_queue.put(test_frame)
        yield clk.posedge

        yield busy.negedge
        yield clk.posedge
        yield clk.posedge

        data = mcb0_inst.read_mem(32, 7)

        assert data == '\x11\x22\x33\x44\x55\x66\x77'

        yield delay(100)

        yield clk.posedge
        print("test 3: Read from port 0")
        current_test.next = 3

        test_frame = bytearray('\xA0\x00\x00\x00\x00'+'\x00'*8)
        source_queue.put(test_frame)
        yield clk.posedge

        yield busy.negedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = bytearray(sink_queue.get())
        assert rx_frame.find('\x01\xAA') >= 0

        yield delay(100)

        yield clk.posedge
        print("test 4: Longer read from port 0")
        current_test.next = 4

        test_frame = bytearray('\xA0\x00\x00\x00\x20'+'\x00'*15)
        source_queue.put(test_frame)
        yield clk.posedge

        yield busy.negedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = bytearray(sink_queue.get())
        print(repr(rx_frame))
        assert rx_frame.find('\x01\x11\x22\x33\x44\x55\x66\x77') >= 0

        yield delay(100)

        yield clk.posedge
        print("test 5: Write to port 0, source pause")
        current_test.next = 5

        test_frame = bytearray('\xB0\x00\x00\x00\x20\x11\x22\x33\x44\x55\x66\x77')
        source_queue.put(test_frame)
        yield clk.posedge

        while input_axis_tvalid or output_axis_tvalid:
            source_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            source_pause.next = False
            yield clk.posedge

        yield clk.posedge
        yield clk.posedge

        data = mcb0_inst.read_mem(32, 7)

        assert data == '\x11\x22\x33\x44\x55\x66\x77'

        yield delay(100)

        yield clk.posedge
        print("test 6: Read from port 0, source pause")
        current_test.next = 6

        test_frame = bytearray('\xA0\x00\x00\x00\x20'+'\x00'*10)
        source_queue.put(test_frame)
        yield clk.posedge

        while input_axis_tvalid or output_axis_tvalid:
            source_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            source_pause.next = False
            yield clk.posedge

        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = bytearray(sink_queue.get())
        assert rx_frame.find('\x01\x11\x22\x33\x44\x55\x66\x77') >= 0

        yield delay(100)

        yield clk.posedge
        print("test 7: Read from port 0, sink pause")
        current_test.next = 7

        test_frame = bytearray('\xA0\x00\x00\x00\x20'+'\x00'*40)
        source_queue.put(test_frame)
        yield clk.posedge

        while input_axis_tvalid or output_axis_tvalid:
            sink_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            sink_pause.next = False
            yield clk.posedge

        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = bytearray(sink_queue.get())
        print(repr(rx_frame))
        assert rx_frame.find('\x01\x11\x22\x33\x44\x55\x66\x77') >= 0

        yield delay(100)

        yield clk.posedge
        print("test 8: Write to port 1")
        current_test.next = 8

        test_frame = bytearray('\xB1\x00\x00\x00\x00\x11')
        source_queue.put(test_frame)
        yield clk.posedge

        yield busy.negedge
        yield clk.posedge
        yield clk.posedge

        data = mcb1_inst.read_mem(0, 1)

        assert data == '\x11'

        yield delay(100)

        yield clk.posedge
        print("test 9: Longer write to port 1")
        current_test.next = 9

        test_frame = bytearray('\xB1\x00\x00\x00\x20\xAA\xBB\xCC\xDD\xEE\xFF\x77')
        source_queue.put(test_frame)
        yield clk.posedge

        yield busy.negedge
        yield clk.posedge
        yield clk.posedge

        data = mcb1_inst.read_mem(32, 7)

        assert data == '\xAA\xBB\xCC\xDD\xEE\xFF\x77'

        yield delay(100)

        yield clk.posedge
        print("test 10: Read from port 1")
        current_test.next = 10

        test_frame = bytearray('\xA1\x00\x00\x00\x00'+'\x00'*8)
        source_queue.put(test_frame)
        yield clk.posedge

        yield busy.negedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = bytearray(sink_queue.get())
        assert rx_frame.find('\x01\x11') >= 0

        yield delay(100)

        yield clk.posedge
        print("test 11: Longer read from port 1")
        current_test.next = 11

        test_frame = bytearray('\xA1\x00\x00\x00\x20'+'\x00'*15)
        source_queue.put(test_frame)
        yield clk.posedge

        yield busy.negedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = bytearray(sink_queue.get())
        assert rx_frame.find('\x01\xAA\xBB\xCC\xDD\xEE\xFF\x77') >= 0

        yield delay(100)

        raise StopSimulation

    return dut, source, sink, mcb0_controller, mcb0_port0, mcb1_controller, mcb1_port0, clkgen, check

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

