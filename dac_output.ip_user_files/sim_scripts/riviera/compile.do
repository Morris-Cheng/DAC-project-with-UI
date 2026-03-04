transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xil_defaultlib

vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+../../../dac_output.gen/sources_1/ip/clk_wiz_0" -l xil_defaultlib \
"../../../dac_output.srcs/sources_1/new/clock_divider.v" \
"../../../dac_output.srcs/sources_1/new/dac.v" \
"../../../dac_output.srcs/sources_1/new/delay_timer.v" \
"../../../dac_output.srcs/sources_1/new/top_tb.v" \


vlog -work xil_defaultlib \
"glbl.v"

