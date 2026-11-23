# Project Notes

## Suggested GitHub repository name
`uart-receiver-verilog-rtl`

## Suggested short description
Parameterized 8-bit UART receiver RTL in Verilog with a self-checking testbench, FSM-based reception, input synchronizer, and simulation instructions.

## Suggested repository topics
`verilog` `vlsi` `rtl-design` `uart` `digital-design` `fpga` `verification`

## Important design checks
- Keep the serial line idle at logic 1.
- Connect the UART device TX output to this module's `rx_serial` input.
- Ensure both devices use compatible baud rates and logic voltage levels.
- Calculate `CLKS_PER_BIT` using the receiver clock frequency divided by baud rate.
- Edit the XDC pin assignments for the exact FPGA board before programming hardware.

## Example
For a 100 MHz clock and 9600 baud:

`CLKS_PER_BIT = 100000000 / 9600 ≈ 10417`

The value is rounded to the nearest integer. The actual baud rate will therefore be approximate.
