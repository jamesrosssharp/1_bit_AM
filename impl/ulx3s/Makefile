#
#
#	Makefile for SLURM16 on ulx3s board
#
#

VERILOG_FILES = top.v

PLL_FILES := $(shell find -L pll -name '*.sv')

SRCDIR=../../src

SOURCE= $(SRCDIR)/am_demod.v	\
	$(SRCDIR)/mult.v	\
	$(SRCDIR)/cic.v		\
	$(SRCDIR)/mixer.v	\
	$(SRCDIR)/nco.v		\
	$(SRCDIR)/sine_table.v	\
	$(SRCDIR)/noise_table.v	\
	$(SRCDIR)/cos_table.v	\
	$(SRCDIR)/audio.v	\
	$(SRCDIR)/am_gen.v	

SRC_FILES := $(SOURCE)

VERILOG_FILES += $(SRC_FILES) $(PLL_FILES)

TOP_MODULE = top

PROJECT = 1bit_am
BOARD = ulx3s

FPGA_PREFIX =
# 12, 25, 45, 85, um-85, um5g-85
FPGA_SIZE = 85
FPGA_CHIP := lfe5u-$(FPGA_SIZE)f
FPGA_PACKAGE = CABGA381
CONSTRAINTS = ulx3s_v316.lpf

FLASH_READ_MHZ = 62.0

FPGA_K = $(FPGA_PREFIX)$(FPGA_SIZE)
YOSYS = yosys
NEXTPNR-ECP5 = nextpnr-ecp5
ECPPACK = LANG=C ecppack
ECPPLL = LANG=C ecppll

UJPROG = fujprog

NEXTPNR_OPTIONS = 
YOSYS_OPTIONS = 

all: $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).bit

# Yosys synth

$(PROJECT).json: $(VERILOG_FILES)
	$(YOSYS) \
	-p "read -sv $(VERILOG_FILES)" \
	-p "hierarchy -top $(TOP_MODULE)" \
	-p "synth_ecp5 $(YOSYS_OPTIONS) -json $(PROJECT).json"

# Nextpnr
$(BOARD)_$(FPGA_SIZE)f_$(PROJECT).config: $(PROJECT).json
	$(NEXTPNR-ECP5) $(NEXTPNR_OPTIONS) --$(FPGA_K)k --package $(FPGA_PACKAGE) \
		--json $(PROJECT).json --lpf $(CONSTRAINTS) --textcfg $@ 

# Pack bitstream

$(BOARD)_$(FPGA_SIZE)f_$(PROJECT).bit: $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).config
	$(ECPPACK) --compress --freq $(FLASH_READ_MHZ) --input $< --bit $@

# Prog SRAM

prog: program
program: $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).bit
	$(UJPROG) $<

# program FLASH over US1 port with ujprog (permanently)
flash: $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).bit
	$(UJPROG) -j flash $<

# Clean

JUNK = *~
JUNK += $(PROJECT).json
JUNK += $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).config
JUNK += $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).bit

clean:
	rm -rf $(JUNK)
	

