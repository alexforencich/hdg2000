
# FPGA settings
FPGA_PART = xc6slx16csg324-2
FPGA_TOP = fpga
FPGA_ARCH = spartan6

# PROM settings
PROM = xcf32p
#SPI_PROM_SIZE = (in bytes)

# Files for synthesis
SYN_FILES = rtl/fpga.v
SYN_FILES += rtl/clock.v
SYN_FILES += rtl/reset_stretch.v
SYN_FILES += coregen/dcm_i10_o250/dcm_i10_o250.v

# UCF files
UCF_FILES = fpga.ucf
UCF_FILES += clock.ucf

# NGC paths for ngdbuild
NGC_PATHS = coregen/dcm_i10_o250
#NGC_PATHS += coregen/...

# Bitgen options
BITGEN_OPTIONS = -g StartupClk:Cclk -g ConfigRate:26

include ../common/xilinx.mk

program: $(FPGA_TOP).bit
	echo "setmode -bscan" > program.cmd
	echo "setcable -p auto" >> program.cmd
	echo "identify" >> program.cmd
	echo "assignfile -p 1 -file $(FPGA_TOP).bit" >> program.cmd
	echo "program -p 1" >> program.cmd
	echo "quit" >> program.cmd
	impact -batch program.cmd

