BSC?=bsc

BSCSRCDIR=$(abspath ./src_bh)
VGASRCDIR=$(abspath ./src_vga)

BUILDDIR=build

SIMDIR=$(BUILDDIR)/sim

# -------------------------

.PHONY: default
default:
	@echo 'The following targets are available:'
	@echo
	@echo '  sim     Creates a Verilator simulation using OpenGL'
	@echo '  ver     Creates a Verilog module to be used in an FPGA design'
	@echo '  clean   Removes the build directory'
	@echo

# -------------------------

.PHONY: clean
clean:
	$(RM) -rf $(BUILDDIR)
	$(RM) -f sim.exe

# -------------------------

.PHONY: sim
sim: sim.exe

sim.exe:
	mkdir -p $(SIMDIR)/bsc_objdir
	(cd $(BUILDDIR)/sim ; \
	    $(BSC) \
		-u \
		-verilog \
		-bdir bsc_objdir \
		-vdir . \
		-info-dir . \
		-p $(BSCSRCDIR):+ \
		$(BSCSRCDIR)/SimTop.bs \
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
	ln -s $(BUILDDIR)/sim/ver_objdir/Vdisplay sim.exe
	chmod u+x sim.exe
