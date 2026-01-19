
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN A18 [get_ports tx]
set_property IOSTANDARD LVCMOS33 [get_ports tx]

create_clock -period 10.000 -name sys_clk -waveform {0.000 5.000} [get_ports clk]

## ============================
## Seven-segment segments (a-g)
## Active-LOW, Common-Anode
## ============================
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]

set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]

## ============================
## Digit enables (AN0-AN3)
## ============================
set_property PACKAGE_PIN U2 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

set_property PACKAGE_PIN A18 [get_ports tx]
set_property IOSTANDARD LVCMOS33 [get_ports tx]
