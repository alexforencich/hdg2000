# Tools
COREGEN:=coregen
XAW2VERILOG:=xaw2verilog

# Source
XCO:=
XAW:=
MIG:=ddr2

# Targets
TARGETS += $(XCO)
TARGETS += $(XAW)
TARGETS += $(MIG)

# Rules
.PHONY: all
all: $(TARGETS)

.PHONY: clean
clean:
	-rm -rf $(TARGETS) $(MIG)

$(XCO): %: %.xco
	$(eval $@_TMP := $(shell mktemp -d))
	cp -a coregen.cgp $($@_TMP)
	cp -a $< $($@_TMP)
	cd $($@_TMP) && $(COREGEN) -p coregen.cgp -b $(notdir $<)
	mv $($@_TMP) $@

$(XAW): %: %.xaw
	$(eval $@_TMP := $(shell mktemp -d))
	cp -a coregen.cgp $($@_TMP)
	cp -a $< $($@_TMP)
	cd $($@_TMP) && $(XAW2VERILOG) -st $(notdir $<) $(notdir $*)
	mv $($@_TMP) $@

$(MIG): %: %.xco %.prj
	$(eval $@_TMP := $(shell mktemp -d))
	cp -a coregen.cgp $($@_TMP)
	cp -a $< $($@_TMP)
	mkdir -p $($@_TMP)/$@/user_design
	cp -a $(word 2,$^) $($@_TMP)/$@/user_design/mig.prj
	cd $($@_TMP) && $(COREGEN) -p coregen.cgp -b $(notdir $<)
	mv $($@_TMP) $@
