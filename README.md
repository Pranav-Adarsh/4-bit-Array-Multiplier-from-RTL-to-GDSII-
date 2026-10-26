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

## Part C: Static timing analysis

```bash
sta sta/sta.tcl                    # T = 10 ns: worst slack 7.213 ns
STA_PERIOD=2.79 sta sta/sta.tcl    # T = Tmin = 10 - 7.213 = 2.787 -> 2.79 ns: worst slack 0.003 ns
```

`sta/mult_array_timing.rpt` is from the final run at T = 2.79 ns.

## Part D: Physical design

Starting CLOCK_PERIOD = 1.2 × Tmin = 1.2 × 2.787 = 3.34 ns, rounded up to 3.5 ns. Each failed run raised it by 0.5 ns
(`CLOCK_PERIOD` edited in `pnr/config.json`, then):

```bash
cd pnr
librelane config.json
```

| Run | CLOCK_PERIOD (ns) | Result | Worst setup slack, all corners (ns) | Typical-corner slack (ns) | DRC | LVS |
|---|---|---|---|---|---|---|
| 1 | 3.5 | setup violations (ss corners) | -2.546 | +0.431 | 0 | 0 |
| 2 | 4.0 | setup violations (ss corners) | -2.027 | +0.929 | 0 | 0 |
| 3 | 4.5 | setup violations (ss corners) | -1.527 | +1.429 | 0 | 0 |
| 4 | 5.0 | setup violations (ss corners) | -1.027 | +1.929 | 0 | 0 |
| 5 | 5.5 | setup violations (ss corners) | -0.527 | +2.429 | 0 | 0 |
| 6 | 6.0 | setup violations (ss corners) | -0.037 | +2.911 | 0 | 0 |
| 7 | 6.5 | setup violations (ss corners) | -0.205 | +3.111 | 0 | 0 |
| 8 | 7.0 | setup violations (ss corners) | -0.116 | +3.526 | 0 | 0 |
| 9 | 7.5 | setup violations (ss corners) | -0.138 | +3.722 | 0 | 0 |
| 10 | 8.0 | **passed** | +0.362 | +4.222 | 0 | 0 |

After removing comments from the sources, the flow was run once more at 8.0 ns (`runs/RUN_2026-10-23_21-24-25`)
with identical results. Its `final/metrics.json` and `final/gds/mult_array.gds` were copied:

```bash
cd pnr
librelane config.json
cp runs/RUN_2026-10-23_21-24-25/final/metrics.json metrics.json
cp runs/RUN_2026-10-23_21-24-25/final/gds/mult_array.gds mult_array.gds
klayout mult_array.gds
```
