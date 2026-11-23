# Example Xilinx constraints template.
# Replace port names, package pins, and clock period for your FPGA board.
# Do not use these placeholder pin assignments as-is.

#create_clock -period 20.000 [get_ports clk]
#set_property PACKAGE_PIN <CLOCK_PIN> [get_ports clk]
#set_property IOSTANDARD LVCMOS33 [get_ports {clk rx_serial rst_n}]
#set_property PACKAGE_PIN <UART_RX_PIN> [get_ports rx_serial]
#set_property PACKAGE_PIN <RESET_PIN> [get_ports rst_n]
