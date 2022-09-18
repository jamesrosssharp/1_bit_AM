
SRCDIR=../../src

SOURCE= $(SRCDIR)/mixer.v	\
	$(SRCDIR)/nco.v		\
	$(SRCDIR)/sine_table.v	\
	$(SRCDIR)/cos_table.v

 
PROJECT=mixer

all: sim

.PHONY: sim

sim: $(SOURCE) tb.v 1bit_rf.txt
	iverilog -grelative-include -o $(PROJECT)_design -D SIM -Winfloop tb.v $(SOURCE)
	vvp      -n $(PROJECT)_design
	gtkwave   dump.vcd config.gtkw 

clean: 
	rm $(PROJECT)_design
	rm dump.vcd
