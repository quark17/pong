# Pong

A simple implementation of [Pong](https://en.wikipedia.org/wiki/Pong)
in [Bluespec HDL](https://github.com/b-lang-org/bsc), that can be
synthesized to Verilog for simulation with
[Verilator](https://github.com/verilator/verilator) or to Verilog for
embedding on an FPGA (files are provided for deploying on a
[Terasic DE10-Standard board](http://de10-standard.terasic.com)).

The BH source files (`src_bh`) are adapted from files in
[the BSC repo](https://github.com/b-lang-org/bsc)
(in [`testsuite/bsc.bsc_examples/pong`](https://github.com/B-Lang-org/bsc/tree/main/testsuite/bsc.bsc_examples/pong).
They are copyright [Bluespec Inc](https://bluespec.com) and licensed
under the BSD-3-Clause license
([details](https://github.com/B-Lang-org/bsc/blob/main/COPYING)).

The files in `src_vga`, for Verilator VGA simulation, are adapted from
Seyedsaman Mohsenisangtabi's
[VGA-Simulation repo](https://github.com/SamanMohseni/VGA-Simulation).
They are copyright SamanMohseni and licensed under the MIT license
([details](https://github.com/SamanMohseni/VGA-Simulation/blob/main/LICENSE)).

Additional files in this repository are copyright Julie Schwartz
and licensed under the BSD-3-Clause license ([details](./LICENSE)).
