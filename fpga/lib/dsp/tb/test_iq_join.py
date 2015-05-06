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
from Queue import Queue

import axis_ep

module = 'iq_join'

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("test_%s.v" % module)

src = ' '.join(srcs)

build_cmd = "iverilog -o test_%s.vvp %s" % (module, src)

def dut_iq_join(clk,
                rst,
                current_test,
                input_i_tdata,
                input_i_tvalid,
                input_i_tready,
                input_q_tdata,
                input_q_tvalid,
                input_q_tready,
                output_i_tdata,
                output_q_tdata,
                output_tvalid,
                output_tready):

    if os.system(build_cmd):
        raise Exception("Error running build command")
    return Cosimulation("vvp -m myhdl test_%s.vvp -lxt2" % module,
                clk=clk,
                rst=rst,
                current_test=current_test,
                input_i_tdata=input_i_tdata,
                input_i_tvalid=input_i_tvalid,
                input_i_tready=input_i_tready,
                input_q_tdata=input_q_tdata,
                input_q_tvalid=input_q_tvalid,
                input_q_tready=input_q_tready,
                output_i_tdata=output_i_tdata,
                output_q_tdata=output_q_tdata,
                output_tvalid=output_tvalid,
                output_tready=output_tready)

def bench():

    # Parameters
    WIDTH = 16

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_i_tdata = Signal(intbv(0)[WIDTH:])
    input_i_tvalid = Signal(bool(0))
    input_q_tdata = Signal(intbv(0)[WIDTH:])
    input_q_tvalid = Signal(bool(0))
    output_tready = Signal(bool(0))

    # Outputs
    input_i_tready = Signal(bool(0))
    input_q_tready = Signal(bool(0))
    output_i_tdata = Signal(intbv(0)[WIDTH:])
    output_q_tdata = Signal(intbv(0)[WIDTH:])
    output_tvalid = Signal(bool(0))

    # Sources and sinks
    input_i_source_queue = Queue()
    input_i_source_pause = Signal(bool(0))
    input_q_source_queue = Queue()
    input_q_source_pause = Signal(bool(0))
    output_sink_queue = Queue()
    output_sink_pause = Signal(bool(0))

    input_i_source = axis_ep.AXIStreamSource(clk,
                                             rst,
                                             tdata=input_i_tdata,
                                             tvalid=input_i_tvalid,
                                             tready=input_i_tready,
                                             fifo=input_i_source_queue,
                                             pause=input_i_source_pause,
                                             name='input_i_source')

    input_q_source = axis_ep.AXIStreamSource(clk,
                                             rst,
                                             tdata=input_q_tdata,
                                             tvalid=input_q_tvalid,
                                             tready=input_q_tready,
                                             fifo=input_q_source_queue,
                                             pause=input_q_source_pause,
                                             name='input_q_source')

    output_sink = axis_ep.AXIStreamSink(clk,
                                       rst,
                                       tdata=(output_i_tdata, output_q_tdata),
                                       tvalid=output_tvalid,
                                       tready=output_tready,
                                       fifo=output_sink_queue,
                                       pause=output_sink_pause,
                                       name='output_sink')

    # DUT
    dut = dut_iq_join(clk,
                      rst,
                      current_test,
                      input_i_tdata,
                      input_i_tvalid,
                      input_i_tready,
                      input_q_tdata,
                      input_q_tvalid,
                      input_q_tready,
                      output_i_tdata,
                      output_q_tdata,
                      output_tvalid,
                      output_tready)

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

        # testbench stimulus

        yield clk.posedge
        print("test 1: test sequence")
        current_test.next = 1

        i_data = list(range(20))
        q_data = list(range(20,40))

        test_frame_i = axis_ep.AXIStreamFrame(i_data)
        test_frame_q = axis_ep.AXIStreamFrame(q_data)

        input_i_source_queue.put(test_frame_i)
        input_q_source_queue.put(test_frame_q)
        yield clk.posedge
        yield clk.posedge

        while input_i_tvalid or input_q_tvalid or output_tvalid:
            yield clk.posedge

        yield clk.posedge
        yield clk.posedge

        lst = []

        while not output_sink_queue.empty():
            lst += output_sink_queue.get(False).data

        assert lst == [list(f) for f in zip(i_data, q_data)]

        yield delay(100)

        yield clk.posedge
        print("test 2: pause source")
        current_test.next = 2

        i_data = list(range(20))
        q_data = list(range(20,40))

        test_frame_i = axis_ep.AXIStreamFrame(i_data)
        test_frame_q = axis_ep.AXIStreamFrame(q_data)

        input_i_source_queue.put(test_frame_i)
        input_q_source_queue.put(test_frame_q)
        yield clk.posedge
        yield clk.posedge

        while input_i_tvalid or input_q_tvalid or output_tvalid:
            input_i_source_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            input_i_source_pause.next = False
            yield clk.posedge

        yield clk.posedge
        yield clk.posedge

        lst = []

        while not output_sink_queue.empty():
            lst += output_sink_queue.get(False).data

        assert lst == [list(f) for f in zip(i_data, q_data)]

        yield delay(100)

        yield clk.posedge
        print("test 3: pause both sources")
        current_test.next = 3

        i_data = list(range(20))
        q_data = list(range(20,40))

        test_frame_i = axis_ep.AXIStreamFrame(i_data)
        test_frame_q = axis_ep.AXIStreamFrame(q_data)

        input_i_source_queue.put(test_frame_i)
        input_q_source_queue.put(test_frame_q)
        yield clk.posedge
        yield clk.posedge

        input_q_source_pause.next = True

        while input_i_tvalid or input_q_tvalid or output_tvalid:
            input_i_source_pause.next = True
            yield clk.posedge
            input_q_source_pause.next = False
            yield clk.posedge
            input_q_source_pause.next = True
            yield clk.posedge
            input_i_source_pause.next = False
            yield clk.posedge

        input_q_source_pause.next = False

        yield clk.posedge
        yield clk.posedge

        lst = []

        while not output_sink_queue.empty():
            lst += output_sink_queue.get(False).data

        assert lst == [list(f) for f in zip(i_data, q_data)]

        yield delay(100)

        yield clk.posedge
        print("test 4: pause sink")
        current_test.next = 4

        i_data = list(range(20))
        q_data = list(range(20,40))

        test_frame_i = axis_ep.AXIStreamFrame(i_data)
        test_frame_q = axis_ep.AXIStreamFrame(q_data)

        input_i_source_queue.put(test_frame_i)
        input_q_source_queue.put(test_frame_q)
        yield clk.posedge
        yield clk.posedge

        while input_i_tvalid or input_q_tvalid or output_tvalid:
            output_sink_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            output_sink_pause.next = False
            yield clk.posedge

        yield clk.posedge
        yield clk.posedge

        lst = []

        while not output_sink_queue.empty():
            lst += output_sink_queue.get(False).data

        assert lst == [list(f) for f in zip(i_data, q_data)]

        yield delay(100)

        yield clk.posedge
        print("test 5: pause source and sink")
        current_test.next = 4

        i_data = list(range(20))
        q_data = list(range(20,40))

        test_frame_i = axis_ep.AXIStreamFrame(i_data)
        test_frame_q = axis_ep.AXIStreamFrame(q_data)

        input_i_source_queue.put(test_frame_i)
        input_q_source_queue.put(test_frame_q)
        yield clk.posedge
        yield clk.posedge

        input_q_source_pause.next = True
    
        while input_i_tvalid or input_q_tvalid or output_tvalid:
            output_sink_pause.next = True
            yield clk.posedge
            input_q_source_pause.next = False
            yield clk.posedge
            input_q_source_pause.next = True
            yield clk.posedge
            output_sink_pause.next = False
            yield clk.posedge
        
        input_q_source_pause.next = False

        yield clk.posedge
        yield clk.posedge

        lst = []

        while not output_sink_queue.empty():
            lst += output_sink_queue.get(False).data

        assert lst == [list(f) for f in zip(i_data, q_data)]

        yield delay(100)

        raise StopSimulation

    return dut, input_i_source, input_q_source, output_sink, clkgen, check

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
