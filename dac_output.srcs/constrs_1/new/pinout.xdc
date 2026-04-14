set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 [get_ports clk]

set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_false_path -from [get_ports reset]

set_property PACKAGE_PIN R2 [get_ports dac_enable]
set_property IOSTANDARD LVCMOS33 [get_ports dac_enable]
set_false_path -from [get_ports dac_enable]

set_property PACKAGE_PIN A14 [get_ports cs]
set_property IOSTANDARD LVCMOS33 [get_ports cs]

set_property PACKAGE_PIN A16 [get_ports d_in]
set_property IOSTANDARD LVCMOS33 [get_ports d_in]

set_property PACKAGE_PIN B15 [get_ports ldac]
set_property IOSTANDARD LVCMOS33 [get_ports ldac]

set_property PACKAGE_PIN B16 [get_ports sclk]
set_property IOSTANDARD LVCMOS33 [get_ports sclk]

set_output_delay -clock [get_clocks -quiet clk_out1_clk_wiz_0] -max 2.000 [get_ports {cs d_in ldac sclk}]
set_output_delay -clock [get_clocks -quiet clk_out1_clk_wiz_0] -min -1.000 [get_ports {cs d_in ldac sclk}]

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
set_false_path -to [get_ports {seg[*]}]

set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]
set_false_path -to [get_ports {an[*]}]

set_property PACKAGE_PIN V17 [get_ports switch250]
set_property IOSTANDARD LVCMOS33 [get_ports switch250]
set_false_path -from [get_ports switch250]

set_property PACKAGE_PIN V16 [get_ports switch200]
set_property IOSTANDARD LVCMOS33 [get_ports switch200]
set_false_path -from [get_ports switch200]

set_property PACKAGE_PIN W16 [get_ports switch100]
set_property IOSTANDARD LVCMOS33 [get_ports switch100]
set_false_path -from [get_ports switch100]