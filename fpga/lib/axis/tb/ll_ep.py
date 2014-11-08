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

def LocalLinkSource(clk, rst,
                    data_out,
                    sof_out_n,
                    eof_out_n,
                    src_rdy_out_n,
                    dst_rdy_in_n,
                    fifo,
                    pause=0,
                    name=None):

    src_rdy_out_n_int = Signal(bool(True))
    dst_rdy_in_n_int = Signal(bool(True))

    @always_comb
    def pause_logic():
        dst_rdy_in_n_int.next = dst_rdy_in_n or pause
        src_rdy_out_n.next = src_rdy_out_n_int or pause

    @instance
    def logic():
        frame = []

        while True:
            yield clk.posedge, rst.posedge

            if rst:
                data_out.next = 0
                src_rdy_out_n_int.next = True
                sof_out_n.next = True
                eof_out_n.next = True
            else:
                if not dst_rdy_in_n_int and not src_rdy_out_n:
                    if len(frame) > 0:
                        data_out.next = frame.pop(0)
                        src_rdy_out_n_int.next = False
                        sof_out_n.next = True
                        eof_out_n.next = len(frame) != 0
                    else:
                        src_rdy_out_n_int.next = True
                        eof_out_n.next = True
                if (not eof_out_n and not dst_rdy_in_n_int and not src_rdy_out_n) or src_rdy_out_n_int:
                    if not fifo.empty():
                        frame = fifo.get()
                        if name is not None:
                            print("[%s] Sending frame %s" % (name, repr(frame)))
                        data_out.next = frame.pop(0)
                        src_rdy_out_n_int.next = False
                        sof_out_n.next = False
                        eof_out_n.next = len(frame) != 0

    return logic, pause_logic


def LocalLinkSink(clk, rst,
                  data_in,
                  sof_in_n,
                  eof_in_n,
                  src_rdy_in_n,
                  dst_rdy_out_n,
                  fifo=None,
                  pause=0,
                  name=None):

    src_rdy_in_n_int = Signal(bool(True))
    dst_rdy_out_n_int = Signal(bool(True))

    @always_comb
    def pause_logic():
        dst_rdy_out_n.next = dst_rdy_out_n_int or pause
        src_rdy_in_n_int.next = src_rdy_in_n or pause

    @instance
    def logic():
        frame = []

        while True:
            yield clk.posedge, rst.posedge

            if rst:
                dst_rdy_out_n_int.next = True
                frame = []
            else:
                dst_rdy_out_n_int.next = False

                if not src_rdy_in_n_int:
                    if not sof_in_n:
                        frame = []
                    frame.append(int(data_in))
                    if not eof_in_n:
                        if fifo is not None:
                            fifo.put(frame)
                        if name is not None:
                            print("[%s] Got frame %s" % (name, repr(frame)))
                        frame = []

    return logic, pause_logic

