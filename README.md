# UART Receiver – Verilog RTL Project

## 1. Project title
**Design and Verification of an 8-bit UART Receiver using Verilog HDL**

## 2. Problem statement
UART is a widely used asynchronous serial communication protocol in embedded systems, microcontrollers, FPGA designs, and communication interfaces. The receiver must detect the start bit, sample the incoming data bits at the correct intervals, identify the stop bit, and provide the recovered parallel data to the rest of the digital system.

This project implements and verifies a parameterized UART receiver using synthesizable Verilog RTL.

## 3. Objectives
- Design a UART receiver supporting the standard 8-N-1 frame format.
- Synchronize the asynchronous serial input to the receiver clock.
- Detect and validate the start bit.
- Receive eight data bits in LSB-first order.
- Check the stop bit and generate a one-clock `rx_data_valid` pulse.
- Verify the RTL using a self-checking simulation testbench.

## 4. UART frame format

| Field | Description |
|---|---|
| Start bit | Logic 0 |
| Data | 8 bits, least-significant bit first |
| Parity | None |
| Stop bit | Logic 1 |

Frame sequence: `START(0) -> DATA[0] ... DATA[7] -> STOP(1)`

## 5. Block-level operation
1. In `IDLE`, the receiver waits for the synchronized RX line to go low.
2. In `START_BIT`, it waits half a bit period and confirms that the line is still low.
3. In `DATA_BITS`, it samples one bit every `CLKS_PER_BIT` clock cycles and stores it LSB first.
4. In `STOP_BIT`, it checks for a logic-high stop bit.
5. If the stop bit is valid, `rx_data_valid` is asserted for one clock cycle and `rx_data` contains the received byte.

## 6. RTL files
- `rtl/uart_rx.v` – synthesizable UART receiver.
- `tb/tb_uart_rx.v` – simulation testbench with multiple test bytes.
- `constraints/uart_rx_template.xdc` – optional Xilinx constraints template.
- `docs/PROJECT_NOTES.md` – design notes and verification guidance.

## 7. Parameters and interfaces

### Parameter
`CLKS_PER_BIT` = number of receiver clock cycles in one UART bit period.

Example: for a 50 MHz clock and 115200 baud:

`CLKS_PER_BIT = 50,000,000 / 115,200 ≈ 434`

Use a value appropriate for the actual clock frequency and baud rate. The testbench uses 16 to keep simulation short.

### Inputs
- `clk`: system clock.
- `rst_n`: active-low asynchronous reset.
- `rx_serial`: asynchronous UART serial input.

### Outputs
- `rx_data[7:0]`: received parallel byte.
- `rx_data_valid`: one-clock pulse when a valid frame is received.

## 8. Simulation using Icarus Verilog
From the project root, run:

```bash
iverilog -g2012 -o uart_rx_sim rtl/uart_rx.v tb/tb_uart_rx.v
vvp uart_rx_sim
```

Expected output includes successful reception of `A5`, `3C`, `00`, and `FF`, followed by:

```text
ALL UART RECEIVER TESTS PASSED
```

To view waveforms, open `uart_rx.vcd` using GTKWave:

```bash
gtkwave uart_rx.vcd
```

## 9. Using the project in Vivado
1. Create a new RTL project.
2. Add `rtl/uart_rx.v` under Design Sources.
3. Add `tb/tb_uart_rx.v` under Simulation Sources.
4. Set `tb_uart_rx` as the simulation top.
5. Set `CLKS_PER_BIT` to match the target clock and baud rate for hardware use.
6. Add and edit the XDC template only after checking the FPGA board's pinout.
7. Run behavioral simulation, then synthesis.

Vivado is not required to upload or store this source project on GitHub.

## 10. Limitations
- Supports 8 data bits, no parity, and one stop bit (8-N-1).
- Does not include a transmitter, FIFO, baud-rate generator, or flow control.
- A framing error is handled by not asserting `rx_data_valid`; there is no separate error output.
- The synchronizer reduces metastability risk but does not eliminate it.
- `CLKS_PER_BIT` must be at least 2 and fit within the 16-bit counter range.

## 11. Conclusion
The project demonstrates a parameterized UART receiver implemented using Verilog HDL. It uses input synchronization, finite-state-machine control, bit-period counting, serial-to-parallel conversion, and stop-bit validation. The self-checking testbench exercises multiple data patterns and helps confirm the receiver's basic functionality.

## 12. Suggested future enhancements
- Add configurable parity support.
- Add selectable one or two stop bits.
- Add framing-error and overrun indicators.
- Add a baud-rate tick generator and FIFO buffer.
- Integrate the receiver with an FPGA development board and a PC serial terminal.
