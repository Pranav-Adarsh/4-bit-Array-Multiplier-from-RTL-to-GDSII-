# 4-bit Array Multiplier: RTL to GDSII (SKY130)

## Team

| Name | Roll number |
|---|---|
| TODO member 1 | TODO (placeholder, last digit 3 used for the Part A example) |
| TODO member 2 | TODO |

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

