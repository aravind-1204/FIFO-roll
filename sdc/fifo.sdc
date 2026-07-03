#Set up clocks
create_clock -name w_clk -period 5 [get_ports w_clk]
create_clock -name r_clk -period 20 [get_ports r_clk]

set_max_delay -from [get_clocks w_clk] -to [get_clocks r_clk] 10.000
set_max_delay -from [get_clocks r_clk] -to [get_clocks w_clk] 10.000

set_false_path -hold -from [get_clocks w_clk] -to [get_clocks r_clk]
set_false_path -hold -from [get_clocks r_clk] -to [get_clocks w_clk]

#Constraint Paths:
create_clock -name virt_w_clk -period 5
create_clock -name virt_r_clk -period 20
#	Writer:

set_input_delay -clock virt_w_clk -max 2.500 [get_ports {w_data[*] w_valid w_last}]
set_input_delay -clock virt_w_clk -min 0.100 [get_ports {w_data[*] w_valid w_last}]

set_output_delay -clock virt_w_clk -max 2.500 [get_ports {w_ready}]
set_output_delay -clock virt_w_clk -min 0.100 [get_ports {w_ready}]

#	Reader:

set_input_delay -clock virt_r_clk -max 10.00 [get_ports {r_ready}]
set_input_delay -clock virt_r_clk -min 0.100 [get_ports {r_ready}]

set_output_delay -clock virt_r_clk -max 10.00 [get_ports {r_data[*] r_keep[*] r_valid r_last}]
set_output_delay -clock virt_r_clk -min 0.100 [get_ports {r_data[*] r_keep[*] r_valid r_last}]

set_clock_groups -asynchronous -group {w_clk virt_w_clk} -group {r_clk virt_r_clk}

#Ignore rst_n

set_false_path -from [get_ports {rst_n}]


