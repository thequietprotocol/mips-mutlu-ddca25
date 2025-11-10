# Digital Design and Computer Architecture — Lab Portfolio

Self-directed implementation of the lab series from **ETH Zürich's Digital Design and Computer Architecture (Spring 2025)**, culminating in a functional **single-cycle MIPS processor** synthesized and verified on an FPGA.

> Course reference: [ETH Zürich DDCA Spring 2025 — Labs](https://safari.ethz.ch/ddca/spring2025/doku.php?id=labs)  
> Completed: November 10, 2025

Labs 1–3 cover basic circuit drawing, FPGA toolflow, and combinational Verilog. These were skipped as prior experience with Verilog and Vivado made them redundant. The repository starts from Lab 4.

---

## Target Hardware

| Parameter | Detail |
|---|---|
| Board | Digilent Basys 3 |
| FPGA | Xilinx Artix-7 (XC7A35T-1CPG236C) |
| Part Number | `xc7a35tcpg236-1` |
| Processor Clock | 25 MHz (100 MHz board clock ÷ 4) |
| EDA Tool | Xilinx Vivado (Batch Mode) |

---

## Repository Structure

```
.
├── lab4/
│   ├── constraints/
│   │   └── Basys3-Master.xdc
│   ├── src/
│   │   ├── clk_div.v
│   │   └── fsm_design.v
│   ├── build.tcl
│   └── ddca_ss25_lab4_manual.pdf
├── lab5/
│   ├── constraints/
│   │   └── Basys3-Master.xdc
│   ├── src/
│   │   └── alu.v
│   ├── build.tcl
│   ├── ddca_ss25_lab5_manual.pdf
│   └── solution_values.txt
├── lab6/
│   ├── constraints/
│   │   └── Basys3-Master.xdc
│   ├── ALU_test.v
│   ├── bad_ALU.v
│   ├── ddca_ss25_lab6_manual.pdf
│   └── testvectors_hex.txt
├── lab7/
│   ├── Mars.jar
│   ├── ddca_ss25_lab7_manual.pdf
│   ├── lab7.asm
│   ├── lab7_sad.asm
│   ├── run_mars.bat
│   ├── test
│   └── test.c
├── lab8/
│   ├── constraints/
│   │   └── top.xdc
│   ├── src/
│   │   ├── MIPS.v
│   │   ├── alu.v
│   │   ├── control_unit.v
│   │   ├── data_mem_h.txt
│   │   ├── data_memory.v
│   │   ├── instr_mem_h.txt
│   │   ├── instruction_memory.v
│   │   ├── register_file.v
│   │   └── top.v
│   ├── build.tcl
│   ├── ddca_ss25_lab8-1_manual.pdf
│   ├── ddca_ss25_lab8-2_manual.pdf
│   └── snake_patterns.asm
├── lab9/
│   ├── constraints/
│   │   └── top.xdc
│   ├── src/
│   │   ├── MIPS.v
│   │   ├── alu.v
│   │   ├── control_unit.v
│   │   ├── data_mem_h.txt
│   │   ├── data_memory.v
│   │   ├── instr_mem_h.txt
│   │   ├── instruction_memory.v
│   │   ├── register_file.v
│   │   └── top.v
│   ├── alu_tb.v
│   ├── build.tcl
│   ├── ddca_ss25_lab9_manual.pdf
│   └── lab9.asm
├── .gitignore
├── mips_reference_data.pdf
└── README.md
```

---

## Lab Progression

| Lab | Topic | Key Concepts |
|-----|-------|-------------|
| 1 | *(skipped)* Drawing a Basic Circuit | Combinational logic, gate-level schematics, equality comparators, NAND universality |
| 2 | *(skipped)* Mapping Your Circuit to FPGA | 4-bit ripple-carry adder, structural Verilog, Vivado toolflow, XDC constraints, FPGA programming |
| 3 | *(skipped)* Verilog for Combinational Circuits | Behavioral Verilog, 7-segment display decoding, hierarchical design |
| 4 | Finite State Machines | Moore/Mealy FSMs, state encoding, clock division, Basys 3 I/O |
| 5 | Implementing an ALU | 32-bit ALU design, arithmetic/logic operations, `slt`, timing analysis, FPGA resource utilization |
| 6 | Testing the ALU | Verilog testbenches, testvector-based verification, waveform debugging, fault identification |
| 7 | Writing Assembly Code | MIPS ISA subset, MARS simulator, integer summation, Sum of Absolute Differences (SAD) |
| 8.1 | Full System Integration (Part I) | Single-cycle MIPS assembly, memory-mapped I/O, 7-segment display driver, crawling snake demo |
| 8.2 | Full System Integration (Part II) | Switch-controlled I/O, assembly modification, MARS memory dump workflow |
| 9 | The Performance of MIPS | Gaussian summation, ALU extension (`srl`, `multu`, `mflo`), processor performance analysis |

---

## Build Instructions

Labs with an FPGA component include a Vivado TCL build script. To build from within a lab directory:

```bash
vivado -mode batch -source ./build.tcl
```

The script runs the full flow: synthesis → implementation → bitstream generation → FPGA programming (if a board is connected). If no board is connected, it completes at bitstream generation.

**TCL script notes:**
- Part number is set to `xc7a35tcpg236-1` (Basys 3). Modify if targeting a different board.
- `-jobs 8` is configured for an 8-logical-core machine. Adjust to match your system.

Lab 7 has no FPGA component — assembly is run directly in the MARS simulator via `run_mars.bat`.

---

## Lab 9 — The Performance of MIPS (Capstone)

### Architecture

A single-cycle MIPS processor where each instruction completes in one clock cycle. The design consists of a datapath and a combinational control unit that decodes instructions and asserts the appropriate control signals.

### Top-Level Design & I/O

The top-level module (`top.v`) wraps the MIPS processor and handles all board-level I/O. The 100 MHz board clock is divided by 4, giving the processor a 25 MHz operating clock. Switch inputs are registered on this clock to avoid metastability.

The processor communicates with peripherals through a memory-mapped I/O interface — input switches are read at addresses `0x4` and `0x8`, and the result is written to the 7-segment display via `IOWriteEn`. The display uses a time-multiplexed refresh circuit driven by the upper 2 bits of a free-running counter to cycle through all four digits.

### Supported Instructions

The processor implements the following subset of the MIPS ISA, decoded by the control unit and executed by the ALU:

| Type | Instructions |
|------|-------------|
| R-type | `add`, `sub`, `and`, `or`, `xor`, `nor`, `slt`, `srl`, `multu`, `mflo` |
| I-type | `lw`, `sw`, `beq`, `addi` |
| J-type | `j` |

The ALU operates on the full 6-bit `funct` field for R-type instructions. Arithmetic (`add`, `sub`) and logical (`and`, `or`, `xor`, `nor`) operations are handled combinationally. `slt` performs a signed comparison using sign-bit detection. `srl` performs a logical right shift by the `shamt` field. `multu` computes a 32×32 unsigned multiply each clock cycle, with the lower 32-bit result stored in a dedicated `LO` register retrievable via `mflo`.

> **Note:** The multiplier is not clock-gated — `HI`/`LO` update every clock edge regardless of whether a multiply is in progress. This is a known power inefficiency in the current implementation.

### Gaussian Sum Demo

The lab program computes the sum of all integers between two 4-bit switch inputs using the Gaussian summation formula, implemented in MIPS assembly. The result is routed to the 4-digit 7-segment display, with each digit showing one bit of the 4-bit result as `0` or `1`.

Input order does not matter — the assembly handles `num1 > num2` correctly.

| `num1` (SW[3:0]) | `num2` (SW[7:4]) | Sum | Display |
|:-:|:-:|:-:|:-:|
| `0000` | `0101` | 15 (0+1+2+3+4+5) | `[1][1][1][1]` |
| `0000` | `0110` | 21 | `[1][0][1][0][1]`* |
| `0101` | `0000` | 15 | `[1][1][1][1]` |

*Lower 4 bits only — see [Known Limitations](#known-limitations).

### Memory Initialization

The MIPS assembly source is located in `lab9/lab9.asm`. The file was assembled using the **MARS MIPS Simulator** (Missouri State University) — `Tools → Dump Memory` was used to export the instruction and data memory contents in hex format, stored in `lab9/src/instr_mem_h.txt` and `lab9/src/data_mem_h.txt` respectively. These files are loaded into the instruction and data memories at synthesis time. If you modify the assembly, re-assemble in MARS, dump the updated hex for both memories, and replace both files before rebuilding.

---

## Known Limitations

- **7-segment display truncates to 4 bits** — results exceeding 15 display only the lower 4 bits of the true sum. Full range would require a binary-to-BCD converter (e.g. Double Dabble), not implemented.
- **Partial MIPS ISA** — instructions outside the supported subset are not decoded.
- **Single-cycle design** — CPI = 1 but maximum clock frequency is bounded by the critical path through the datapath.
- **No exception handling** — overflow, undefined instructions, and memory faults are not handled.
- **Multiplier not clock-gated** — `HI`/`LO` registers update every cycle regardless of instruction, leading to unnecessary power consumption.

---

## References

- [ETH Zürich DDCA Spring 2025](https://safari.ethz.ch/ddca/spring2025/doku.php?id=start)
- Harris & Harris, *Digital Design and Computer Architecture* (MIPS Edition)
- Patterson & Hennessy, *Computer Organization and Design* (MIPS Edition)
- [Digilent Basys 3 Reference Manual](https://digilent.com/reference/programmable-logic/basys-3/reference-manual)
- [MARS MIPS Simulator](https://computerscience.missouristate.edu/mars-mips-simulator.htm)
