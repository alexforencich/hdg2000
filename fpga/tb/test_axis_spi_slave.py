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
import spi_ep

module = 'axis_spi_slave'

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("test_%s.v" % module)

src = ' '.join(srcs)

build_cmd = "iverilog -o test_%s.vvp %s" % (module, src)

def dut_axis_spi_slave(clk,
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

                 cs,
                 sck,
                 mosi,
                 miso,

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

                cs=cs,
                sck=sck,
                mosi=mosi,
                miso=miso,

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
    cs = Signal(bool(0))
    sck = Signal(bool(0))
    mosi = Signal(bool(0))

    # Outputs
    input_axis_tready = Signal(bool(0))
    output_axis_tdata = Signal(intbv(0)[8:])
    output_axis_tvalid = Signal(bool(0))
    output_axis_tlast = Signal(bool(0))
    miso = Signal(bool(0))

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

    # SPI master
    master_tx_queue = Queue()
    master_rx_queue = Queue()

    master = spi_ep.SPIMaster(clk,
                              rst,
                              cs=cs,
                              sck=sck,
                              mosi=mosi,
                              miso=miso,
                              width=8,
                              prescale=4,
                              cpol=0,
                              cpha=0,
                              tx_fifo=master_tx_queue,
                              rx_fifo=master_rx_queue,
                              name='spi')

    # DUT
    dut = dut_axis_spi_slave(clk,
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

                        cs,
                        sck,
                        mosi,
                        miso,

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

        while not sink_queue.empty():
            sink_queue.get()
        while not master_rx_queue.empty():
            master_rx_queue.get()

        yield clk.posedge
        print("test 1: SPI to AXI walk")
        current_test.next = 1

        test_frame = bytearray('\x00\x01\x02\x04\x08\x10\x20\x40\x80')
        master_tx_queue.put(test_frame)
        yield clk.posedge

        yield output_axis_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = bytearray(sink_queue.get())
        assert rx_frame == test_frame

        yield delay(100)

        while not sink_queue.empty():
            sink_queue.get()
        while not master_rx_queue.empty():
            master_rx_queue.get()

        yield clk.posedge
        print("test 2: SPI to AXI walk 2")
        current_test.next = 2

        test_frame = bytearray('\x00\x01\x03\x07\x0F\x1F\x3F\x7F\xFF')
        master_tx_queue.put(test_frame)
        yield clk.posedge

        yield output_axis_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = bytearray(sink_queue.get())
        assert rx_frame == test_frame

        yield delay(100)

        while not sink_queue.empty():
            sink_queue.get()
        while not master_rx_queue.empty():
            master_rx_queue.get()

        yield clk.posedge
        print("test 3: AXI to SPI walk")
        current_test.next = 3

        test_frame = bytearray('\x00\x01\x02\x04\x08\x10\x20\x40\x80')
        master_tx_queue.put(bytearray('\x00'*9))
        source_queue.put(test_frame)
        yield clk.posedge

        yield output_axis_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not master_rx_queue.empty():
            rx_frame = bytearray(master_rx_queue.get())
        assert rx_frame == test_frame

        yield delay(100)

        while not sink_queue.empty():
            sink_queue.get()
        while not master_rx_queue.empty():
            master_rx_queue.get()

        yield clk.posedge
        print("test 4: AXI to SPI walk 2")
        current_test.next = 4

        test_frame = bytearray('\x00\x01\x03\x07\x0F\x1F\x3F\x7F\xFF')
        master_tx_queue.put(bytearray('\x00'*9))
        source_queue.put(test_frame)
        yield clk.posedge

        yield output_axis_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not master_rx_queue.empty():
            rx_frame = bytearray(master_rx_queue.get())
        assert rx_frame == test_frame

        yield delay(100)

        raise StopSimulation

    return dut, source, sink, master, clkgen, check

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

