
---

## File Descriptions

### `temp_tracker_top.v`
- Top-level design module
- Interfaces with XADC
- Processes raw temperature data
- Connects display and UART modules

### `top_temp_7seg.v`
- Converts temperature values into decimal digits
- Drives 7-segment display and digit enable signals
- Handles multiplexing for multi-digit displays

### `uart_tx.v`
- Implements UART transmission logic
- Configurable baud rate and clock frequency
- Sends formatted temperature data serially

### `constrain1.xdc`
- FPGA pin assignments
- Clock, reset, UART TX, and 7-segment display constraints
- Designed for the target FPGA board

---

## System Architecture

1. **XADC Module**
   - Reads internal FPGA temperature sensor
   - Provides digital temperature output

2. **Processing Logic**
   - Scales and formats temperature value
   - Converts raw data to human-readable form

3. **Display Interface**
   - Drives a 7-segment LED display
   - Shows temperature in real time

4. **UART Interface**
   - Sends temperature data to PC
   - Can be viewed using a serial terminal

---

## Requirements

### Hardware
- Xilinx FPGA board with XADC support
- 7-segment display (on-board or external)
- USB-to-UART connection (on-board or external)

### Software
- Xilinx Vivado (recommended)
- Serial terminal software (PuTTY, Tera Term, etc.)

---

## How to Use

1. Create a new Vivado project.
2. Add all Verilog source files:
   - `temp_tracker_top.v`
   - `top_temp_7seg.v`
   - `uart_tx.v`
3. Add `constrain1.xdc` as the constraints file.
4. Synthesize, implement, and generate the bitstream.
5. Program the FPGA.
6. Open a serial terminal with the configured baud rate to view temperature output.

---

## Applications
- FPGA thermal monitoring
- Embedded system diagnostics
- Academic FPGA and XADC learning projects
- On-chip sensor interfacing demonstrations

---

## Notes
- Baud rate and clock frequency can be adjusted in the UART module parameters.
- Display digit enable mapping may vary depending on the FPGA board.
- Ensure correct constraint mapping for your specific hardware.

---

## Author
Developed as part of an FPGA-based embedded systems project using Xilinx XADC.

---

## License
This project is intended for educational and academic use.
