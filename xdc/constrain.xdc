## Clock Signal - reduced further for the Q2.22 datapath (wider 24-bit
## arithmetic increased critical path length vs. the Q2.14 version)
## 90 MHz failed: WNS = -3.285 ns (theoretical max ~69.5 MHz)
## Using 65 MHz for safe margin below that limit
set_property -dict { PACKAGE_PIN R4  IOSTANDARD LVCMOS33 } [get_ports { clk }]; #Sch=sysclk
create_clock -add -name sys_clk_pin -period 15.385 -waveform {0 7.692} [get_ports { clk }]

## Reset - CPU RESET button (active-low on board; invert in RTL/wrapper if needed)
set_property -dict { PACKAGE_PIN G4  IOSTANDARD LVCMOS15 } [get_ports { reset }]; #Sch=cpu_resetn

## Configuration options (standard, keep these)
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## Allow bitstream generation despite unconstrained data ports
set_property BITSTREAM.GENERAL.UNCONSTRAINEDPINS {Allow} [current_design]