# MIPS — ALU Processor

A compact HDL implementation of a 5 stage pipelined MIPS-styled processor focused on the ALU and core datapath. This project follows the spirit and structure of the MIPS20 reference material — implementing a clean, teachable subset of the MIPS ISA and the minimal control and datapath necessary to demonstrate instruction execution.

## Overview
This repository implements:
- A simple instruction fetch/decode/execute datapath
- Register file (20 x 32-bit registers)
- ALU with common arithmetic and logical operations
- Instruction and data memories (as separate memories for clarity)
- Basic control unit to support a small but useful instruction subset

The design is intended for learning, simulation, and basic synthesis on FPGA tools.

## Supported instructions (subset)
Typical instructions implemented (may vary by source file):
- R-type: add, sub, and, or, slt
- I-type: addi, lw, sw, beq
- J-type: j

These cover arithmetic, memory access, and simple control flow so you can exercise the ALU, register file, and memory interfaces.

## Architecture highlights
- Single-cycle datapath: each instruction completes in one clock cycle (simple and easy to follow).
- Clean separation between instruction memory, data memory, register file, ALU, and control logic.
- Signals and modules named to mirror the canonical MIPS datapath for readability and teaching.

## Files (high level)
- src/            — HDL source modules (ALU, register file, control, memories, top-level)
- tb/             — Testbenches to simulate instruction sequences
- sims/           — Example instruction binaries / test programs
- docs/           — Reference notes and any diagrams (if present)

(Adapt paths to the repository layout — these are typical locations; see the repo for exact filenames.)

## Simulation / Quick start
To simulate with Icarus Verilog (example):
1. Ensure you have iverilog and vvp installed.
2. From the repo root:
   - iverilog -o simv tb/top_tb.v src/*.v
   - vvp simv
3. Inspect waveform (if generated) with GTKWave:
   - gtkwave dump.vcd

For vendor tools (Vivado/Quartus), create a new project and add the source files; set the top module and follow the vendor flow for synthesis or implementation.

## Testing
- Testbenches provide examples for ALU ops, register-file reads/writes, loads/stores, and control flow.
- Add new tests in tb/ to exercise additional instruction sequences or edge cases.

## Contributing
Contributions, bug reports, and suggestions are welcome. If you add instructions, please:
- Update the supported-instruction list
- Add testbenches that validate correct behavior
- Keep module interfaces and naming consistent for clarity

## License
Specify your license here (e.g., MIT, BSD). If none is present, add a LICENSE file before reuse.

## Contact
For questions or discussion, open an issue in this repository or contact the maintainer.
