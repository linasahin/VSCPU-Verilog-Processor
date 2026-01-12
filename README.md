# VSCPU-Verilog-Processor

## Project Overview
[cite_start]This repository contains the full design, implementation, and verification of a **Very Simple CPU (VSCPU)** using **Verilog HDL**[cite: 118]. [cite_start]The project involves creating a functional 32-bit processor core that supports a specific Instruction Set Architecture (ISA) and is fully synthesizable for FPGA/Silicon realization[cite: 118, 170].



## Key Features
* [cite_start]**Complete ISA Support**: Implemented a wide range of instructions including arithmetic, logical, shift, and control flow operations [cite: 119, 124-130].
* [cite_start]**Custom ISA Extensions**: Successfully extended the base processor with custom **SUB** and **SUBi** instructions [cite: 119, 362-363].
* [cite_start]**Hardware Synthesis**: Design synthesized using **Vivado/Synopsys** to analyze hardware performance, including LUT usage and timing constraints[cite: 170].
* [cite_start]**Comprehensive Verification**: Validated the processor's logic by executing a 22-instruction assembly program and verifying waveforms against reference simulations [cite: 134-135].

---

## Instruction Set Architecture (ISA)
[cite_start]The VSCPU supports the following categories of instructions [cite: 124-130, 362-363]:

| Category | Instructions |
| :--- | :--- |
| **Arithmetic** | ADD, ADDi, MUL, MULi, **SUB (Custom)**, **SUBi (Custom)** |
| **Logical** | NAND, NANDi |
| **Shift** | SRL, SRLi |
| **Comparison** | LT, LTi |
| **Data Copy** | CP, CPi, CPI, CPIi |
| **Control Flow** | BZJ, BZJi |

---

## Technical Implementation

### Custom Subtraction Logic
[cite_start]The ISA was extended to include two new subtraction operations [cite: 362-363]:
* [cite_start]**SUB**: Implemented using **2's complement** logic where the second operand is inverted and incremented before addition ($R1 - R2$) [cite: 370-371].
* [cite_start]**SUBi**: Designed to handle subtraction with immediate values directly from the instruction word [cite: 373-374].

### Synthesis & Performance Metrics
[cite_start]The design was synthesized to evaluate physical hardware requirements and performance[cite: 170, 176]:
* [cite_start]**Resource Utilization**: Detailed reporting of LUT/ALM and Flip-Flop counts[cite: 170].
* [cite_start]**Timing Analysis**: Verification of clock frequency and critical path delays[cite: 170].
* [cite_start]**Area Utilization**: Analysis of the total physical footprint on the hardware[cite: 170].

---

## How to Run
1. [cite_start]**Simulation**: Load the Verilog source files (`.v`) into **Vivado**, **Synopsys**, or **EDAPlayground**[cite: 170, 386].
2. [cite_start]**Execution**: Run the provided testbench to execute the assembly program sequence [cite: 135-157, 388].
3. [cite_start]**Verification**: Compare generated waveforms with the verification screenshots provided in the `project_report.pdf` [cite: 174, 178-180].

## Repository Contents
* [cite_start]**Verilog Design Files**: Source code for the VSCPU core[cite: 387].
* [cite_start]**Testbench**: Verification code for executing assembly programs[cite: 388].
* [cite_start]**Project Report**: Full documentation of datapath, control signals, and synthesis results[cite: 386].
