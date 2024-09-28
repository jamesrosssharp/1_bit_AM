
SRCDIR=../../src

SOURCE= $(SRCDIR)/am_demod_lite.v	\
	$(SRCDIR)/mult.v	\
	$(SRCDIR)/cic_lite.v	\
	$(SRCDIR)/mixer_2bit.v	\
	$(SRCDIR)/nco_sq.v	\
	$(SRCDIR)/sine_table.v	\
	$(SRCDIR)/cos_table.v

 
PROJECT=am_demod

all: sim

.PHONY: sim

sim: $(SOURCE) tb.v 1bit_rf.txt
	iverilog -grelative-include -o $(PROJECT)_design -D SIM -Winfloop tb.v $(SOURCE)
	vvp      -n $(PROJECT)_design
	gtkwave   dump.vcd config.gtkw 

clean: 
	rm $(PROJECT)_design
	rm dump.vcd
