# 4-bit Array Multiplier: RTL to GDSII (SKY130)

## Team

| Name | Roll number |
|---|---|
| Sri Pranavadarsh Tadepalli | 2024102028 (last digit 8 used for the Part A example: A = 13, B = 7) |
| Srikar Krishna Durbha | 2024112010 |

## Environment

IIC-OSIC-TOOLS Docker image (`hpretl/iic-osic-tools:latest`) in WSL 2 Ubuntu 24.04, started in VNC mode:

```bash
cd ~/eda/IIC-OSIC-TOOLS && ./start_vnc.sh
```

This repository lives in `~/eda/designs/mult_array` (`/foss/designs/mult_array` inside the container).
`~/eda/designs/.designinit` sets `PDK=sky130A`. All commands below are run from the repository root inside the container.

## Part A: RTL design and verification

```bash
iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim
# PASS: 256 vectors checked, 0 errors
gtkwave mult.vcd
```

Error-detection check: temporarily changed `assign sum = a ^ b ^ cin;` to `assign sum = a ^ b;` in `rtl/full_adder.v`, then

```bash
iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim
# FAIL: 256 vectors checked, 95 errors
```

and restored the original line.

## Part B: Logic synthesis

```bash
yosys -c synth/synth.tcl
# writes synth/mult_array_netlist.v and synth/mult_array_stat.rpt

CELLS=$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog
iverilog -g2012 -DFUNCTIONAL -DUNIT_DELAY=#1 -o gls \
  tb/tb_mult.v $CELLS/primitives.v $CELLS/sky130_fd_sc_hd.v synth/mult_array_netlist.v
vvp gls
# PASS: 256 vectors checked, 0 errors
```

