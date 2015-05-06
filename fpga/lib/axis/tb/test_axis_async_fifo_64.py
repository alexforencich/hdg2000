#!/usr/bin/env python
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

try:
    from queue import Queue
except ImportError:
    from Queue import Queue

import axis_ep

module = 'axis_async_fifo_64'

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("test_%s.v" % module)

src = ' '.join(srcs)

build_cmd = "iverilog -o test_%s.vvp %s" % (module, src)

def dut_axis_async_fifo_64(input_clk,
                 input_rst,
                 output_clk,
                 output_rst,
                 current_test,

                 input_axis_tdata,
                 input_axis_tkeep,
                 input_axis_tvalid,
                 input_axis_tready,
                 input_axis_tlast,
                 input_axis_tuser,

                 output_axis_tdata,
                 output_axis_tkeep,
                 output_axis_tvalid,
                 output_axis_tready,
                 output_axis_tlast,
                 output_axis_tuser):

    if os.system(build_cmd):
        raise Exception("Error running build command")
    return Cosimulation("vvp -m myhdl test_%s.vvp -lxt2" % module,
                input_clk=input_clk,
                input_rst=input_rst,
                output_clk=output_clk,
                output_rst=output_rst,
                current_test=current_test,

                input_axis_tdata=input_axis_tdata,
                input_axis_tkeep=input_axis_tkeep,
                input_axis_tvalid=input_axis_tvalid,
                input_axis_tready=input_axis_tready,
                input_axis_tlast=input_axis_tlast,
                input_axis_tuser=input_axis_tuser,

                output_axis_tdata=output_axis_tdata,
                output_axis_tkeep=output_axis_tkeep,
                output_axis_tvalid=output_axis_tvalid,
                output_axis_tready=output_axis_tready,
                output_axis_tlast=output_axis_tlast,
                output_axis_tuser=output_axis_tuser)

def bench():

    # Inputs
    input_clk = Signal(bool(0))
    input_rst = Signal(bool(0))
    output_clk = Signal(bool(0))
    output_rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_axis_tdata = Signal(intbv(0)[64:])
    input_axis_tkeep = Signal(intbv(0)[8:])
    input_axis_tvalid = Signal(bool(0))
    input_axis_tlast = Signal(bool(0))
    input_axis_tuser = Signal(bool(0))
    output_axis_tready = Signal(bool(0))

    # Outputs
    input_axis_tready = Signal(bool(0))
    output_axis_tdata = Signal(intbv(0)[64:])
    output_axis_tkeep = Signal(intbv(0)[8:])
    output_axis_tvalid = Signal(bool(0))
    output_axis_tlast = Signal(bool(0))
    output_axis_tuser = Signal(bool(0))

    # sources and sinks
    source_queue = Queue()
    source_pause = Signal(bool(0))
    sink_queue = Queue()
    sink_pause = Signal(bool(0))

    source = axis_ep.AXIStreamSource(input_clk,
                                    input_rst,
                                    tdata=input_axis_tdata,
                                    tkeep=input_axis_tkeep,
                                    tvalid=input_axis_tvalid,
                                    tready=input_axis_tready,
                                    tlast=input_axis_tlast,
                                    tuser=input_axis_tuser,
                                    fifo=source_queue,
                                    pause=source_pause,
                                    name='source')

    sink = axis_ep.AXIStreamSink(output_clk,
                                output_rst,
                                tdata=output_axis_tdata,
                                tkeep=output_axis_tkeep,
                                tvalid=output_axis_tvalid,
                                tready=output_axis_tready,
                                tlast=output_axis_tlast,
                                tuser=output_axis_tuser,
                                fifo=sink_queue,
                                pause=sink_pause,
                                name='sink')

    # DUT
    dut = dut_axis_async_fifo_64(input_clk,
                       input_rst,
                       output_clk,
                       output_rst,
                       current_test,

                       input_axis_tdata,
                       input_axis_tkeep,
                       input_axis_tvalid,
                       input_axis_tready,
                       input_axis_tlast,
                       input_axis_tuser,

                       output_axis_tdata,
                       output_axis_tkeep,
                       output_axis_tvalid,
                       output_axis_tready,
                       output_axis_tlast,
                       output_axis_tuser)

    @always(delay(4))
    def input_clkgen():
        input_clk.next = not input_clk

    @always(delay(5))
    def output_clkgen():
        output_clk.next = not output_clk

    @instance
    def check():
        yield delay(100)
        yield input_clk.posedge
        input_rst.next = 1
        output_rst.next = 1
        yield input_clk.posedge
        yield input_clk.posedge
        yield input_clk.posedge
        input_rst.next = 0
        output_rst.next = 0
        yield input_clk.posedge
        yield delay(100)
        yield input_clk.posedge

        yield input_clk.posedge

        yield input_clk.posedge
        print("test 1: test packet")
        current_test.next = 1

        test_frame = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source_queue.put(test_frame)
        yield input_clk.posedge

        yield output_axis_tlast.posedge
        yield output_clk.posedge
        yield output_clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame

        yield delay(100)

        yield input_clk.posedge
        print("test 2: longer packet")
        current_test.next = 2

        test_frame = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            bytearray(range(256)))
        source_queue.put(test_frame)
        yield input_clk.posedge

        yield output_axis_tlast.posedge
        yield output_clk.posedge
        yield output_clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame

        yield input_clk.posedge
        print("test 3: test packet with pauses")
        current_test.next = 3

        test_frame = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            bytearray(range(256)))
        source_queue.put(test_frame)
        yield input_clk.posedge

        yield delay(64)
        yield input_clk.posedge
        source_pause.next = True
        yield delay(32)
        yield input_clk.posedge
        source_pause.next = False

        yield delay(64)
        yield output_clk.posedge
        sink_pause.next = True
        yield delay(32)
        yield output_clk.posedge
        sink_pause.next = False

        yield output_axis_tlast.posedge
        yield output_clk.posedge
        yield output_clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame

        yield delay(100)

        yield input_clk.posedge
        print("test 4: back-to-back packets")
        current_test.next = 4

        test_frame1 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        test_frame2 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x02\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source_queue.put(test_frame1)
        source_queue.put(test_frame2)
        yield input_clk.posedge

        yield output_axis_tlast.posedge
        yield output_clk.posedge
        yield output_axis_tlast.posedge
        yield output_clk.posedge
        yield output_clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame1

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame2

        yield delay(100)

        yield input_clk.posedge
        print("test 5: alternate pause source")
        current_test.next = 5

        test_frame1 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        test_frame2 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x02\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source_queue.put(test_frame1)
        source_queue.put(test_frame2)
        yield input_clk.posedge

        while input_axis_tvalid or output_axis_tvalid:
            source_pause.next = True
            yield input_clk.posedge
            yield input_clk.posedge
            yield input_clk.posedge
            source_pause.next = False
            yield input_clk.posedge

        yield output_clk.posedge
        yield output_clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame1

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame2

        yield delay(100)

        yield input_clk.posedge
        print("test 6: alternate pause sink")
        current_test.next = 6

        test_frame1 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        test_frame2 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x02\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source_queue.put(test_frame1)
        source_queue.put(test_frame2)
        yield input_clk.posedge

        while input_axis_tvalid or output_axis_tvalid:
            sink_pause.next = True
            yield output_clk.posedge
            yield output_clk.posedge
            yield output_clk.posedge
            sink_pause.next = False
            yield output_clk.posedge

        yield output_clk.posedge
        yield output_clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame1

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame2

        yield delay(100)

        yield input_clk.posedge
        print("test 7: tuser assert")
        current_test.next = 7

        test_frame = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        test_frame.user = 1
        source_queue.put(test_frame)
        yield input_clk.posedge

        yield output_axis_tlast.posedge
        yield output_clk.posedge
        yield output_clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame
        assert rx_frame.user[-1]

        yield delay(100)

        raise StopSimulation

    return dut, source, sink, input_clkgen, output_clkgen, check

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

