# =================================================
# Nexys A7-50T - General Constraints File
# Based on https://github.com/Digilent/digilent-xdc
# =================================================

# -----------------------------------------------
# Clock
# -----------------------------------------------
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports {clk}];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];

# -----------------------------------------------
# Push buttons
# -----------------------------------------------
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports {btnc}]; #probably not needed
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports {btnu}];
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 } [get_ports {btnl}];
set_property -dict { PACKAGE_PIN M17 IOSTANDARD LVCMOS33 } [get_ports {btnr}];
set_property -dict { PACKAGE_PIN P18 IOSTANDARD LVCMOS33 } [get_ports {btnd}];

# -----------------------------------------------
# Switches
# -----------------------------------------------
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]; #ON/OFF output

# -----------------------------------------------
# LEDs
# -----------------------------------------------
set_property PACKAGE_PIN H17 [get_ports {led[0]}];
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

# -----------------------------------------------
# Seven-segment cathodes CA..CG + DP (active-low)
# seg[6]=A ... seg[0]=G
# -----------------------------------------------
set_property PACKAGE_PIN T10 [get_ports {seg[6]}]; # CA
set_property PACKAGE_PIN R10 [get_ports {seg[5]}]; # CB
set_property PACKAGE_PIN K16 [get_ports {seg[4]}]; # CC
set_property PACKAGE_PIN K13 [get_ports {seg[3]}]; # CD
set_property PACKAGE_PIN P15 [get_ports {seg[2]}]; # CE
set_property PACKAGE_PIN T11 [get_ports {seg[1]}]; # CF
set_property PACKAGE_PIN L18 [get_ports {seg[0]}]; # CG
set_property PACKAGE_PIN H15 [get_ports {dp}];
set_property IOSTANDARD LVCMOS33 [get_ports {seg[*] dp}]

# -----------------------------------------------
# Seven-segment anodes AN7..AN0 (active-low)
# -----------------------------------------------
set_property PACKAGE_PIN J17 [get_ports {an[0]}];   # s / t / s
set_property PACKAGE_PIN J18 [get_ports {an[1]}];   # i / r / q
set_property PACKAGE_PIN T9  [get_ports {an[2]}];   # n / i / r
set_property PACKAGE_PIN J14 [get_ports {an[3]}];   # inactive
set_property PACKAGE_PIN P14 [get_ports {an[4]}];   # 1 / 1
set_property PACKAGE_PIN T14 [get_ports {an[5]}];   # 0 / 0
set_property PACKAGE_PIN K2  [get_ports {an[6]}];   # 0 / k
set_property PACKAGE_PIN U13 [get_ports {an[7]}];   # 0
set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]

# -----------------------------------------------
# USB-RS232 Interface
# -----------------------------------------------
set_property -dict { PACKAGE_PIN C4 IOSTANDARD LVCMOS33 } [get_ports {uart_txd_in}];
set_property -dict { PACKAGE_PIN D4 IOSTANDARD LVCMOS33 } [get_ports {uart_rxd_out}];
set_property -dict { PACKAGE_PIN D3 IOSTANDARD LVCMOS33 } [get_ports {uart_cts}];
set_property -dict { PACKAGE_PIN E5 IOSTANDARD LVCMOS33 } [get_ports {uart_rts}];

# -----------------------------------------------
# Pmod Header JA
# -----------------------------------------------
set_property -dict { PACKAGE_PIN C17 IOSTANDARD LVCMOS33 } [get_ports {ja[1]}];
set_property -dict { PACKAGE_PIN D18 IOSTANDARD LVCMOS33 } [get_ports {ja[2]}];
set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVCMOS33 } [get_ports {ja[3]}];
set_property -dict { PACKAGE_PIN G17 IOSTANDARD LVCMOS33 } [get_ports {ja[4]}];
set_property -dict { PACKAGE_PIN D17 IOSTANDARD LVCMOS33 } [get_ports {ja[7]}];
set_property -dict { PACKAGE_PIN E17 IOSTANDARD LVCMOS33 } [get_ports {ja[8]}];
set_property -dict { PACKAGE_PIN F18 IOSTANDARD LVCMOS33 } [get_ports {ja[9]}];
set_property -dict { PACKAGE_PIN G18 IOSTANDARD LVCMOS33 } [get_ports {ja[10]}];

# -----------------------------------------------
# (Remaining peripherals preserved but omitted here for brevity)
# JB, JC, JD, XADC, VGA, SD, Ethernet, Audio, etc.
# Same conversion style applies:
#
# # set_property PACKAGE_PIN <PIN> [get_ports {<signal>}]
# # set_property IOSTANDARD LVCMOS33 [get_ports {...}]
#
# -----------------------------------------------
