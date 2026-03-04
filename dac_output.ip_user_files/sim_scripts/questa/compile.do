vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+../../../dac_output.gen/sources_1/ip/clk_wiz_0" \
"../../../dac_output.srcs/sources_1/new/clock_divider.v" \
"../../../dac_output.srcs/sources_1/new/dac.v" \
"../../../dac_output.srcs/sources_1/new/delay_timer.v" \
"../../../dac_output.srcs/sources_1/new/top_tb.v" \


vlog -work xil_defaultlib \
"glbl.v"

