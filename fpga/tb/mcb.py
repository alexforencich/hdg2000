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
from Queue import Queue
import mmap
import struct

class MCB(object):
    def __init__(self, size = 1024):
        self.port_queues = []
        self.controller_queue = Queue()
        self.has_controller = False
        self.size = size
        self.mem = mmap.mmap(-1, size)

    def read_mem(self, address, length):
        self.mem.seek(address)
        return self.mem.read(length)

    def write_mem(self, address, data):
        self.mem.seek(address)
        self.mem.write(data)

    def create_controller(self, clk, rst):
        if self.has_controller:
            raise Exception("Controller already instantiated!")

        self.has_controller = True

        port_queues = []

        @instance
        def logic():
            
            while True:
                yield clk.posedge

                # build port list
                while not self.controller_queue.empty():
                    port_queues.append(self.controller_queue.get())

                # check for commands
                for port in port_queues:
                    pw, pn, cmdf, wrf, rdf = port

                    if not cmdf.empty():
                        instr, ba, bl = cmdf.get()

                        if pn is not None:
                            print("[%s] Got command i:%d a:0x%08x bl:%d" % (pn, instr, ba, bl))

                        # check alignment
                        if pw == 32:
                            assert ba & 3 == 0
                        elif pw == 64:
                            assert ba & 7 == 0
                        elif pw == 128:
                            assert ba & 15 == 0

                        if instr == 0 or instr == 2:
                            # write or write with auto precharge
                            self.mem.seek(ba % self.size)
                            for k in range(bl+1):
                                mask, data = wrf.get()
                                if pw == 32:
                                    data = struct.pack('<L', data)
                                elif pw == 64:
                                    data = struct.pack('<Q', data)
                                elif pw == 128:
                                    data = struct.pack('<Q', data & 2**64-1) + struct.pack('<Q', data >> 64)
                                for l in range(len(data)):
                                    if not mask & (1 << l):
                                        self.mem.write(data[l])
                                    else:
                                        self.mem.seek(1, 1)
                                if pn is not None:
                                    print("[%s] Write word %d/%d a:0x%08x m:0x%02x d:%s" % (pn, k+1, bl+1, ba+k*pw/8, mask, " ".join("{:02x}".format(ord(c)) for c in data)))
                        elif instr == 1 or instr == 3:
                            # read or read with auto precharge
                            self.mem.seek(ba % self.size)
                            data = self.mem.read(int((bl+1)*pw/8))
                            for k in range(bl+1):
                                if pw == 32:
                                    rdf.put(struct.unpack('<L', data[k*4:(k+1)*4])[0])
                                elif pw == 64:
                                    rdf.put(struct.unpack('<Q', data[k*8:(k+1)*8])[0])
                                elif pw == 128:
                                    rdf.put(struct.unpack('<Q', data[k*16:k*16+8])[0] + struct.unpack('<Q', data[k*16+8:(k+1)*16])[0] * 2**64)
                                if pn is not None:
                                    print("[%s] Read word %d/%d a:0x%08x d:%s" % (pn, k+1, bl+1, ba+k*pw/8, " ".join("{:02x}".format(ord(c)) for c in data[k*int(pw/8):(k+1)*int(pw/8)])))
                        else:
                            # refresh
                            pass

        return logic

    def port_cmd_logic(self, cmd_clk,
                             cmd_en,
                             cmd_instr,
                             cmd_byte_addr,
                             cmd_bl,
                             cmd_empty,
                             cmd_full,
                             fifo):

        @instance
        def logic():
            
            while True:
                yield cmd_clk.posedge

                if not fifo.full() and cmd_en:
                    fifo.put((int(cmd_instr), int(cmd_byte_addr), int(cmd_bl)))

                cmd_full.next = fifo.full()
                cmd_empty.next = fifo.empty()

        return logic

    def port_wr_logic(self, wr_clk,
                            wr_en,
                            wr_mask,
                            wr_data,
                            wr_empty,
                            wr_full,
                            wr_underrun,
                            wr_count,
                            wr_error,
                            fifo):

        @instance
        def logic():
            
            while True:
                yield wr_clk.posedge

                if not fifo.full() and wr_en:
                    fifo.put((int(wr_mask), int(wr_data)))

                wr_full.next = fifo.full()
                wr_empty.next = fifo.empty()
                wr_count.next = fifo.qsize()

        return logic

    def port_rd_logic(self, rd_clk,
                            rd_en,
                            rd_data,
                            rd_empty,
                            rd_full,
                            rd_overflow,
                            rd_count,
                            rd_error,
                            fifo):

        @instance
        def logic():
            valid = False

            while True:
                yield rd_clk.posedge

                if rd_en:
                    valid = False

                if not fifo.empty() and (rd_en or not valid):
                    valid = True
                    rd_data.next = fifo.get()

                rd_full.next = fifo.full()
                rd_empty.next = not valid
                rd_count.next = fifo.qsize() + int(valid)

        return logic

    def create_read_port(self, cmd_clk,
                               cmd_en,
                               cmd_instr,
                               cmd_byte_addr,
                               cmd_bl,
                               cmd_empty,
                               cmd_full,
                               rd_clk,
                               rd_en,
                               rd_data,
                               rd_empty,
                               rd_full,
                               rd_overflow,
                               rd_count,
                               rd_error,
                               name=None):

        assert len(rd_data) in [32, 64, 128]

        cmd_fifo = Queue(4)
        read_fifo = Queue(64)

        self.port_queues.append((len(rd_data), name, cmd_fifo, None, read_fifo))
        self.controller_queue.put((len(rd_data), name, cmd_fifo, None, read_fifo))

        cmd_logic = self.port_cmd_logic(cmd_clk,
                                        cmd_en,
                                        cmd_instr,
                                        cmd_byte_addr,
                                        cmd_bl,
                                        cmd_empty,
                                        cmd_full,
                                        cmd_fifo)
        read_logic = self.port_rd_logic(rd_clk,
                                        rd_en,
                                        rd_data,
                                        rd_empty,
                                        rd_full,
                                        rd_overflow,
                                        rd_count,
                                        rd_error,
                                        read_fifo)

        return cmd_logic, read_logic

    def create_write_port(self, cmd_clk,
                                cmd_en,
                                cmd_instr,
                                cmd_bl,
                                cmd_byte_addr,
                                cmd_empty,
                                cmd_full,
                                wr_clk,
                                wr_en,
                                wr_mask,
                                wr_data,
                                wr_empty,
                                wr_full,
                                wr_underrun,
                                wr_count,
                                wr_error,
                                name=None):

        assert len(wr_data) in [32, 64, 128]
        
        cmd_fifo = Queue(4)
        write_fifo = Queue(64)

        self.port_queues.append((len(wr_data), name, cmd_fifo, write_fifo, None))
        self.controller_queue.put((len(wr_data), name, cmd_fifo, write_fifo, None))

        cmd_logic = self.port_cmd_logic(cmd_clk,
                                        cmd_en,
                                        cmd_instr,
                                        cmd_byte_addr,
                                        cmd_bl,
                                        cmd_empty,
                                        cmd_full,
                                        cmd_fifo)
        write_logic = self.port_wr_logic(wr_clk,
                                         wr_en,
                                         wr_mask,
                                         wr_data,
                                         wr_empty,
                                         wr_full,
                                         wr_underrun,
                                         wr_count,
                                         wr_error,
                                         write_fifo)

        return cmd_logic, write_logic

    def create_readwrite_port(self, cmd_clk,
                                    cmd_en,
                                    cmd_instr,
                                    cmd_bl,
                                    cmd_byte_addr,
                                    cmd_empty,
                                    cmd_full,
                                    wr_clk,
                                    wr_en,
                                    wr_mask,
                                    wr_data,
                                    wr_empty,
                                    wr_full,
                                    wr_underrun,
                                    wr_count,
                                    wr_error,
                                    rd_clk,
                                    rd_en,
                                    rd_data,
                                    rd_empty,
                                    rd_full,
                                    rd_overflow,
                                    rd_count,
                                    rd_error,
                                    name=None):

        assert len(wr_data) in [32, 64, 128]
        assert len(rd_data) in [32, 64, 128]
        
        cmd_fifo = Queue(4)
        write_fifo = Queue(64)
        read_fifo = Queue(64)

        assert len(wr_data) == len(rd_data)

        self.port_queues.append((len(wr_data), name, cmd_fifo, write_fifo, read_fifo))
        self.controller_queue.put((len(wr_data), name, cmd_fifo, write_fifo, read_fifo))

        cmd_logic = self.port_cmd_logic(cmd_clk,
                                        cmd_en,
                                        cmd_instr,
                                        cmd_byte_addr,
                                        cmd_bl,
                                        cmd_empty,
                                        cmd_full,
                                        cmd_fifo)
        write_logic = self.port_wr_logic(wr_clk,
                                         wr_en,
                                         wr_mask,
                                         wr_data,
                                         wr_empty,
                                         wr_full,
                                         wr_underrun,
                                         wr_count,
                                         wr_error,
                                         write_fifo)
        read_logic = self.port_rd_logic(rd_clk,
                                        rd_en,
                                        rd_data,
                                        rd_empty,
                                        rd_full,
                                        rd_overflow,
                                        rd_count,
                                        rd_error,
                                        read_fifo)

        return cmd_logic, write_logic, read_logic
