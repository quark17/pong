BSC?=bsc

BSVSRCDIR=$(abspath ./src_bsv)
BHSRCDIR=$(abspath ./src_bh)
VGASRCDIR=$(abspath ./src_vga)

BUILDDIR=build

BSVFPGADIR=$(BUILDDIR)/bsv_fpga

BHSIMDIR=$(BUILDDIR)/bh_sim
BHFPGADIR=$(BUILDDIR)/bh_fpga
BHFPGAKBDDIR=$(BUILDDIR)/bh_fpga_kbd

# -------------------------

.PHONY: default
default:
	@echo 'The following targets are available:'
	@echo
	@echo '  bsv_fpga     Creates a Verilog module to be used in an FPGA design'
	@echo
	@echo '  bh_sim       Creates a Verilator simulation using OpenGL'
	@echo '  bh_fpga      Creates a Verilog module to be used in an FPGA design'
	@echo '  bh_fpga_kbd  Creates a Verilog module to be used in an FPGA design'
	@echo
	@echo '  clean        Removes the build directory'
	@echo

# -------------------------

.PHONY: clean
clean:
	$(RM) -rf $(BUILDDIR)
	$(RM) -f bh_sim.exe

# -------------------------

.PHONY: bh_sim
bh_sim: bh_sim.exe

bh_sim.exe:
	mkdir -p $(BHSIMDIR)/bsc_objdir
	(cd $(BHSIMDIR) ; \
	    $(BSC) \
		-u \
		-cpp \
		-verilog \
		-bdir bsc_objdir \
		-vdir . \
		-info-dir . \
		-p $(BHSRCDIR):+ \
		-Xcpp -DVGA_SMALL \
		$(BHSRCDIR)/SimTop.bs \
		)
	(cd $(BHSIMDIR) ; \
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
	(cd $(BHSIMDIR)/ver_objdir ; \
	 make -j -f Vdisplay.mk Vdisplay \
	 )
	ln -s $(BHSIMDIR)/ver_objdir/Vdisplay $@
	chmod u+x $@

# -------------------------

.PHONY: bh_fpga
bh_fpga:
	mkdir -p $(BHFPGADIR)/bsc_objdir
	(cd $(BHFPGADIR) ; \
	    $(BSC) \
		-u \
		-cpp \
		-verilog \
		-bdir bsc_objdir \
		-vdir . \
		-info-dir . \
		-p $(BHSRCDIR):+ \
		$(BHSRCDIR)/FPGATopNoKbd_DE10Std.bs \
		)
	cp $(BHFPGADIR)/mkFPGATopNoKbd_DE10Std.v src_de10std/

# -------------------------

.PHONY: bh_fpga_kbd
bh_fpga_kbd:
	mkdir -p $(BHFPGAKBDDIR)/bsc_objdir
	(cd $(BHFPGAKBDDIR) ; \
	    $(BSC) \
		-u \
		-cpp \
		-verilog \
		-bdir bsc_objdir \
		-vdir . \
		-info-dir . \
		-p $(BHSRCDIR):+ \
		$(BHSRCDIR)/FPGATop_DE10Std.bs \
		)
	cp $(BHFPGAKBDDIR)/mkFPGATop_DE10Std.v src_de10std_kbd/

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
		-cpp \
		-verilog \
		-bdir bsc_objdir \
		-vdir . \
		-info-dir . \
		-p $(BSVSRCDIR):+ \
		$(BSVSRCDIR)/TopLevel.bsv \
		)

# -------------------------
