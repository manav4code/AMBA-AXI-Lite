clear

iverilog -o sim tb/axi_control_s_top_tb.v tb/axi_control_s_top.v src/axi_control_s.v src/mem_p.v
./sim
