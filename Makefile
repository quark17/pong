BSC?=bsc

BSVSRCDIR=$(abspath ./src_bsv)
BHSRCDIR=$(abspath ./src_bh)
VGASRCDIR=$(abspath ./src_vga)

BUILDDIR=build

BSVFPGADIR=$(BUILDDIR)/bsv_fpga

# -------------------------

.PHONY: default
default:
	@echo 'The following targets are available:'
	@echo
	@echo '  Simulation with 640x480 VGA display and arrow keys input:'
	@echo '    bh_sim            Create a Verilator simulation using OpenGL'
	@echo
	@echo '  Generate a Verilog module for FPGA (1024x768 VGA, PS/2 keyboard input):'
	@echo '    bh_fpga_kbd_v0    Version 0 (no Island)'
	@echo '    bh_fpga_kbd_v1    Version 1 (stationary Island)'
	@echo '    bh_fpga_kbd_v2    Version 2 (moving Island that cycles colors)'
	@echo
	@echo '  Generate a Verilog module for FPGA (1024x768 VGA, button input):'
	@echo '    bh_fpga_nokbd_v0  Version 0 (no Island)'
	@echo '    bh_fpga_nokbd_v1  Version 1 (stationary Island)'
	@echo '    bh_fpga_nokbd_v2  Version 2 (moving Island that cycles colors)'
	@echo
	@echo '  Abandoned support for BSV source code:'
	@echo '    bsv_fpga          Create a Verilog module to be used in an FPGA design'
	@echo
	@echo '  The above targets place generated files in separate directories'
	@echo '  below a '\''build'\'' subdirectory.'
	@echo '    clean             Remove the '\''build'\'' directory'
	@echo

# -------------------------

.PHONY: clean
clean:
	$(RM) -rf $(BUILDDIR)
	$(RM) -f bh_sim.exe

# -------------------------

# Reusable target for checking that a variable is set
guard-%:
	@if [ -z '${${*}}' ]; then \
		echo "Error: Variable $* is not set."; \
		exit 1; \
	fi

# -------------------------

.PHONY: bh_sim
bh_sim: bh_sim.exe
bh_sim: PONGVERSION?=0

bh_sim.exe: guard-PONGVERSION
bh_sim.exe: BHSIMDIR=$(BUILDDIR)/bh_sim
bh_sim.exe: $(wildcard $(BHSRCDIR)/*) $(wildcard $(VGASRCDIR)/*)
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
		-Xcpp -DNOKBD \
		-Xcpp -DVER$(PONGVERSION) \
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
	ln -sf $(BHSIMDIR)/ver_objdir/Vdisplay $@
	chmod u+x $@

# -------------------------

.PHONY: bh_fpga_kbd_v0
bh_fpga_kbd_v0: PONGVERSION=0
bh_fpga_kbd_v0: bh_fpga_kbd

.PHONY: bh_fpga_kbd_v1
bh_fpga_kbd_v1: PONGVERSION=1
bh_fpga_kbd_v1: bh_fpga_kbd

.PHONY: bh_fpga_kbd_v2
bh_fpga_kbd_v2: PONGVERSION=2
bh_fpga_kbd_v2: bh_fpga_kbd

# -----

.PHONY: bh_fpga_nokbd_v0
bh_fpga_nokbd_v0: PONGVERSION=0
bh_fpga_nokbd_v0: bh_fpga_nokbd

.PHONY: bh_fpga_nokbd_v1
bh_fpga_nokbd_v1: PONGVERSION=1
bh_fpga_nokbd_v1: bh_fpga_nokbd

.PHONY: bh_fpga_nokbd_v2
bh_fpga_nokbd_v2: PONGVERSION=2
bh_fpga_nokbd_v2: bh_fpga_nokbd

# -----

.PHONY: bh_fpga_kbd
bh_fpga_kbd: PONGCONTROLLER=KBD
bh_fpga_kbd: FPGADIR=src_de10std_kbd
bh_fpga_kbd: BHFPGADIR=$(BUILDDIR)/bh_fpga_kbd_ver$(PONGVERSION)
bh_fpga_kbd: bh_fpga

.PHONY: bh_fpga_nokbd
bh_fpga_nokbd: PONGCONTROLLER=NOKBD
bh_fpga_nokbd: FPGADIR=src_de10std
bh_fpga_nokbd: BHFPGADIR=$(BUILDDIR)/bh_fpga_nokbd_ver$(PONGVERSION)
bh_fpga_nokbd: bh_fpga

.PHONY: bh_fpga
bh_fpga: guard-PONGVERSION guard-PONGCONTROLLER
bh_fpga: guard-FPGADIR guard-BHFPGADIR
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
		-Xcpp -DVER$(PONGVERSION) \
		-Xcpp -D$(PONGCONTROLLER) \
		$(BHSRCDIR)/FPGATop_DE10Std.bs \
		)
	#cp $(BHFPGADIR)/FPGATop_DE10Std.bs $(FPGADIR)/

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
