PROJ = 1_bit_am
PIN_DEF = am.pcf
DEVICE = up5k

ICEPACK = icepack
ICETIME = icetime
ICEPROG = iceprog

SOURCE = top.v

SRCDIR=../../src

SOURCE += $(SRCDIR)/am_demod.v	\
	$(SRCDIR)/mult.v	\
	$(SRCDIR)/cic.v		\
	$(SRCDIR)/mixer_2bit.v	\
	$(SRCDIR)/nco.v		\
	$(SRCDIR)/sine_table.v	\
	$(SRCDIR)/noise_table.v	\
	$(SRCDIR)/cos_table.v	\
	$(SRCDIR)/audio.v	


all: $(PROJ).bin

$(PROJ).json: $(SOURCE)
	yosys -p 'debug synth_ice40 -top top -json $@' $(SOURCE)

%.asc: $(PIN_DEF) %.json
	nextpnr-ice40 --timing-allow-fail --randomize-seed --freq 25.125 --up5k --json $(PROJ).json --pcf $(PIN_DEF) --asc $@

%.bin: %.asc
	$(ICEPACK) $< $@

%.rpt: %.asc
	$(ICETIME) -d $(DEVICE) -mtr $@ $<

prog: $(PROJ).bin
	$(ICEPROG) -S $<
	#$(ICEPROG) $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo $(ICEPROG) -S $<

clean:
	rm -f $(PROJ).blif $(PROJ).json $(PROJ).asc $(PROJ).rpt $(PROJ).bin


.SECONDARY:
.PHONY: all prog clean
