
# FPGA settings
FPGA_PART = xc6slx16-2csg324
FPGA_TOP = fpga
FPGA_ARCH = spartan6

# PROM settings
PROM = xcf32p
#SPI_PROM_SIZE = (in bytes)

# Files for synthesis
SYN_FILES = rtl/fpga.v
SYN_FILES += rtl/fpga_core.v
SYN_FILES += rtl/clock.v
SYN_FILES += rtl/reset_stretch.v
SYN_FILES += rtl/ddr2.v
SYN_FILES += rtl/ddr2_clock.v
SYN_FILES += rtl/axis_spi_slave.v
SYN_FILES += rtl/soc_interface.v
SYN_FILES += rtl/srl_fifo_reg.v
SYN_FILES += coregen/ddr2/ddr2/user_design/rtl/memc_wrapper.v
SYN_FILES += coregen/ddr2/ddr2/user_design/rtl/mcb_controller/iodrp_controller.v
SYN_FILES += coregen/ddr2/ddr2/user_design/rtl/mcb_controller/iodrp_mcb_controller.v
SYN_FILES += coregen/ddr2/ddr2/user_design/rtl/mcb_controller/mcb_raw_wrapper.v
SYN_FILES += coregen/ddr2/ddr2/user_design/rtl/mcb_controller/mcb_soft_calibration.v
SYN_FILES += coregen/ddr2/ddr2/user_design/rtl/mcb_controller/mcb_soft_calibration_top.v
SYN_FILES += coregen/ddr2/ddr2/user_design/rtl/mcb_controller/mcb_ui_top.v

# UCF files
UCF_FILES = fpga.ucf
UCF_FILES += clock.ucf
UCF_FILES += ddr2.ucf

# NGC paths for ngdbuild
NGC_PATHS = 
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

