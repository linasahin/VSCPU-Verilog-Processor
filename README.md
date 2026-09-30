# ⚡ VSCPU - Verilog Processor

Design and implementation of a fully functional Very Simple CPU (VSCPU) using Verilog HDL. Features a complete Instruction Set Architecture (ISA) supporting arithmetic, logical, shift, and branch operations, extended with custom SUB and SUBi instructions.

---

## ✨ Key Features

* **Complete ISA Support:** Implemented a wide range of instructions including arithmetic, logical, shift, and control flow operations.
* **Custom ISA Extensions:** Extended the base processor architecture with custom `SUB` and `SUBi` instructions.
* **Hardware Synthesis:** Synthesized using Vivado/Synopsys to analyze hardware performance, including LUT/FF utilization and critical timing constraints.
* **Comprehensive Verification:** Validated processor execution logic through assembly program sequences and reference waveform simulations.

---

## 📋 Instruction Set Architecture (ISA)

| Category | Instructions |
| :--- | :--- |
| **Arithmetic** | ADD, ADDi, MUL, MULi, SUB (Custom), SUBi (Custom) |
| **Logical** | NAND, NANDi |
| **Shift** | SRL, SRLi |
| **Comparison** | LT, LTi |
| **Data Copy** | CP, CPi, CPI, CPIi |
| **Control Flow** | BZJ, BZJi |

---

## 🛠️ Technical Implementation

### Custom Subtraction Logic
* **SUB:** Implemented using 2's complement logic where the second operand is inverted and incremented before addition ($R1 - R2$).
* **SUBi:** Designed to execute immediate subtraction directly from instruction data fields.

### Synthesis & Performance Metrics
* **Resource Utilization:** Detailed reporting of LUT/ALM and Flip-Flop counts across design blocks.
* **Timing & Critical Path Analysis:** Verification of maximum clock frequency and path constraints.
* **Physical Footprint:** Evaluated total silicon/FPGA resource footprint.

---

## 🚀 How to Run & Simulation

1. **Online Simulation:** You can run and inspect the simulation directly on [EDA Playground](https://edaplayground.com/x/HMBK).
2. **Local Simulation:** Load the Verilog source files (`vscpu.v`, `tb_vscpu.v`) into **Vivado**, **ModelSim**, or your preferred HDL simulator.
3. **Execution:** Run the testbench to simulate the 22-instruction assembly execution sequence.
4. **Verification:** Compare generated waveform traces against expected register and memory states.

---

## 📁 Repository Structure

* `vscpu.v`: Main Verilog HDL processor core design.
* `tb_vscpu.v`: Comprehensive testbench for ISA verification.
* `vscpu_program.c`: C helper script for generating assembly sequences / memory init.
