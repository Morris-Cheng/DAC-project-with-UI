set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk -period 10.000 [get_ports clk]

set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

set_property PACKAGE_PIN R2 [get_ports dac_enable]
set_property IOSTANDARD LVCMOS33 [get_ports dac_enable]

set_property PACKAGE_PIN B18 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]

set_property PACKAGE_PIN A14 [get_ports cs]
set_property IOSTANDARD LVCMOS33 [get_ports cs]

set_property PACKAGE_PIN A16 [get_ports d_in]
set_property IOSTANDARD LVCMOS33 [get_ports d_in]

set_property PACKAGE_PIN B16 [get_ports sclk]
set_property IOSTANDARD LVCMOS33 [get_ports sclk]

# display
set_property PACKAGE_PIN W7  [get_ports {seg[0]}]
set_property PACKAGE_PIN W6  [get_ports {seg[1]}]
set_property PACKAGE_PIN U8  [get_ports {seg[2]}]
set_property PACKAGE_PIN V8  [get_ports {seg[3]}]
set_property PACKAGE_PIN U5  [get_ports {seg[4]}]
set_property PACKAGE_PIN V5  [get_ports {seg[5]}]
set_property PACKAGE_PIN U7  [get_ports {seg[6]}]
set_property PACKAGE_PIN V7  [get_ports {seg[7]}]

set_property PACKAGE_PIN W4  [get_ports {an[3]}]
set_property PACKAGE_PIN V4  [get_ports {an[2]}]
set_property PACKAGE_PIN U4  [get_ports {an[1]}]
set_property PACKAGE_PIN U2  [get_ports {an[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]

set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]

set_property PACKAGE_PIN U16 [get_ports {LD[0]}]
set_property PACKAGE_PIN E19 [get_ports {LD[1]}]
set_property PACKAGE_PIN U19 [get_ports {LD[2]}]
set_property PACKAGE_PIN V19 [get_ports {LD[3]}]
set_property PACKAGE_PIN W18 [get_ports {LD[4]}]
set_property PACKAGE_PIN U15 [get_ports {LD[5]}]
set_property PACKAGE_PIN U14 [get_ports {LD[6]}]
set_property PACKAGE_PIN V14 [get_ports {LD[7]}]
set_property PACKAGE_PIN V13 [get_ports {LD[8]}]
set_property PACKAGE_PIN V3  [get_ports {LD[9]}]

set_property PACKAGE_PIN W3  [get_ports {LD[10]}]
set_property PACKAGE_PIN U3  [get_ports {LD[11]}]
set_property PACKAGE_PIN P3  [get_ports {LD[12]}]
set_property PACKAGE_PIN N3  [get_ports {LD[13]}]
set_property PACKAGE_PIN P1  [get_ports {LD[14]}]
set_property PACKAGE_PIN L1  [get_ports {LD[15]}]

set_property IOSTANDARD LVCMOS33 [get_ports {LD[*]}]


set_property IOSTANDARD LVCMOS33 [get_ports LD[*]]