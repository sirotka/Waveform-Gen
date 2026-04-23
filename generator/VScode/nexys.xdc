# -----------------------------------------------
# Title       : Waveform Generator (Basic)
# File        : nexys.xdc
# Author      : Klimt
# Institution : Brno University of Technology (VUT)
# Faculty     : Faculty of Electrical Engineering and Communication (FEKT)
# Course      : Digital Electronics 1 / VHDL Project 2026
#
# Description :
# This project implements a basic waveform generator on the Nexys A7-50T FPGA
# board. The system is capable of generating three types of signals:
# sine, triangle, and square wave.
#
# The design uses a hybrid architecture:
# - clk_en generates a clock enable signal (ce)
# - counter_step implements DDS phase accumulation
# - waveform modules generate signals based on phase
# - waveform_mux selects the active waveform
# - pwm_out converts the signal to PWM for audio output
# - seg7 displays waveform type and frequency
#
# User Control :
# - Buttons are used to change waveform and frequency
# - Switch enables/disables output
# - LEDs indicate system state
#
# Target Device :
# Digilent Nexys A7-50T (Xilinx Artix-7 FPGA)
#
# Notes :
# This project was developed as part of a laboratory assignment.
# All modules are designed using synchronous logic principles.
#
# -----------------------------------------------

# -----------------------------------------------
# Clock
# -----------------------------------------------
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports {clk}];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];

# -----------------------------------------------
# Reset (CPU_RESETN - red button, active low)
# -----------------------------------------------
set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports {rst}];

# -----------------------------------------------
# Push buttons
# -----------------------------------------------
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports {btnu}];
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 } [get_ports {btnl}];
set_property -dict { PACKAGE_PIN M17 IOSTANDARD LVCMOS33 } [get_ports {btnr}];
set_property -dict { PACKAGE_PIN P18 IOSTANDARD LVCMOS33 } [get_ports {btnd}];

# -----------------------------------------------
# Switch & LED
# -----------------------------------------------
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports {sw}];
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports {led}];

# -----------------------------------------------
# 7 segment cathodes CA..CG (active-low)
# -----------------------------------------------
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports {seg[0]}]; # CA
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports {seg[1]}]; # CB
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports {seg[2]}]; # CC
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports {seg[3]}]; # CD
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports {seg[4]}]; # CE
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports {seg[5]}]; # CF
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports {seg[6]}]; # CG

# -----------------------------------------------
# Seven-segment anodes AN7..AN0 (active-low)
# -----------------------------------------------
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports {an[0]}];
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports {an[1]}];
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports {an[2]}];
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports {an[3]}];
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {an[4]}];
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports {an[5]}];
set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports {an[6]}];
set_property -dict { PACKAGE_PIN U13 IOSTANDARD LVCMOS33 } [get_ports {an[7]}];

# -----------------------------------------------
# Mono Audio Output
# -----------------------------------------------
set_property -dict { PACKAGE_PIN A11 IOSTANDARD LVCMOS33 } [get_ports {pwm}];
set_property -dict { PACKAGE_PIN D12 IOSTANDARD LVCMOS33 } [get_ports {aud_sd}];