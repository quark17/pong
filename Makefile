BSC?=bsc

BSVSRCDIR=$(abspath ./src_bsv)
BHSRCDIR=$(abspath ./src_bh)
VGASRCDIR=$(abspath ./src_vga)

BUILDDIR=build

BSVFPGADIR=$(BUILDDIR)/bsv_fpga

BHSIMDIR=$(BUILDDIR)/bh_sim
BHFPGADIR=$(BUILDDIR)/bh_fpga

# -------------------------

.PHONY: default
default:
	@echo 'The following targets are available:'
	@echo
	@echo '  bsv_fpga   Creates a Verilog module to be used in an FPGA design'
	@echo
	@echo '  bh_sim     Creates a Verilator simulation using OpenGL'
	@echo '  bh_fpga    Creates a Verilog module to be used in an FPGA design'
	@echo
	@echo '  clean      Removes the build directory'
	@echo

# -------------------------

.PHONY: clean
clean:
	$(RM) -rf $(BUILDDIR)
	$(RM) -f sim.exe

# -------------------------

.PHONY: bh_sim
bh_sim: sim.exe

bh_sim.exe:
	mkdir -p $(BHSIMDIR)/bsc_objdir
	(cd $(BUILDDIR)/sim ; \
	    $(BSC) \
		-u \
		-verilog \
		-bdir bsc_objdir \
		-vdir . \
		-info-dir . \
		-p $(BHSRCDIR):+ \
		$(BHSRCDIR)/SimTop.bs \
		)
	(cd $(BUILDDIR)/sim ; \
	verilator --cc --exe \
		-Mdir ver_objdir \
		$(VGASRCDIR)/simulator.cpp \
		$(VGASRCDIR)/display.v \
		$(VGASRCDIR)/vga_controller.v \
		-LDFLAGS -lglut \
		-LDFLAGS -lGLU \
		-LDFLAGS -lGL \
		-DBSV_POSITIVE_RESET \
		-Wno-TIMESCALEMOD \
		--timing \
		)
	(cd $(BUILDDIR)/sim/ver_objdir ; \
	 make -j -f Vdisplay.mk Vdisplay \
	 )
	ln -s $(BUILDDIR)/sim/ver_objdir/Vdisplay $@
	chmod u+x $@

# -------------------------

.PHONY: bh_fpga
bh_fpga:
	mkdir -p $(BHFPGADIR)/bsc_objdir
	(cd $(BHFPGADIR) ; \
	    $(BSC) \
		-u \
		-verilog \
		-bdir bsc_objdir \
		-vdir . \
		-info-dir . \
		-p $(BHSRCDIR):+ \
		$(BHSRCDIR)/FPGATopNoKbd_DE10Std.bs \
		)
	cp $(BHFPGADIR)/mkFPGATopNoKbd_DE10Std.v src_de10std/

# -------------------------

.PHONY: bsv_fpga
bsv_fpga:
	cp $(BSVSRCDIR)/TopLevel0.bsv $(BSVSRCDIR)/TopLevel.bsv
	cp $(BSVSRCDIR)/Ball0.bsv $(BSVSRCDIR)/Ball.bsv
	#cp $(BSVSRCDIR)/Island0.bsv $(BSVSRCDIR)/Island.bsv
	mkdir -p $(BSVFPGADIR)/bsc_objdir
	(cd $(BSVFPGADIR) ; \
	    $(BSC) \
		-u \
		-verilog \
		-bdir bsc_objdir \
		-vdir . \
		-info-dir . \
		-p $(BSVSRCDIR):+ \
		$(BSVSRCDIR)/TopLevel.bsv \
		)

# -------------------------
