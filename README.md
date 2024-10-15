# WISC-F24 Microarchitecture Specification

## Project Overview
This document outlines the specifications for the WISC-F24 microarchitecture, designed by **Abhinav Nandwani** and **Anna Huang** as part of their class project. The architecture is inspired by the MIPS R2000 but features a smaller instruction set and 16-bit words[1].

## Table of Contents
1. [Registers](#registers)
2. [Memory System](#memory-system)
3. [Pipeline](#pipeline)
4. [Optimizations](#optimizations)
5. [Exceptions: Extra Credit](#exceptions-extra-credit)
6. [Instruction Set Architecture Specification](#instruction-set-architecture-specification)

## Registers
- Eight user registers (R0-R7)
- R0 is not always zero
- R7 serves as the link register for JAL or JALR instructions
- Program counter is separate from the user register file
- Special register EPC saves the current PC upon exception or interrupt[1]

## Memory System
- Harvard architecture: instructions and data in different physical memories
- Byte-addressable and word-aligned (16 bits)
- Big-endian
- Final version will include multi-cycle memory and level-1 cache[1]

## Pipeline
Five-stage pipeline:
1. Instruction Fetch (IF)
2. Instruction Decode/Register Fetch (ID)
3. Execute/Address Calculation (EX)
4. Memory Access (MEM)
5. Write Back (WB)[1]

## Optimizations
- Two register forwarding paths: one within ID and another between MEM and EX
- All branches predicted as not taken
- Goal: reduce CPI or total cycles for program execution[1]

## Exceptions: Extra Credit
- Optional implementation
- IllegalOp exception for unrecognized opcodes
- Exception handler saves PC to EPC and loads address 0x02
- Minimum handler functionality: load 0xBADD into R7 and call RTI instruction[1]

## Instruction Set Architecture Specification

### Instructions Summary

| Instruction Format | Syntax | Semantics |
|--------------------|--------|-----------|
| 00000 xxxxxxxxxxx  | HALT   | Cease instruction issue, dump memory state to file |
| 00001 xxxxxxxxxxx  | NOP    | None |
| 01000 sss ddd iiiii | ADDI Rd, Rs, immediate | Rd ← Rs + (sign ext.) |
| 01001 sss ddd iiii | SUBI Rd, Rs, immediate | Rd ← I(sign ext.) - Rs |
| ... | ... | ... |

### Formats
WISC-F24 supports four instruction formats: J-format, two I-formats, and R-format[1].

#### J-format
Used for jump instructions requiring large displacements.

| Bits   | Description  |
|--------|--------------|
| 5 bits | Op Code      |
| 11 bits| Displacement |

#### I-format
I-format instructions utilize registers and immediate values.

##### I-format 1 Instructions
| Bits   | Description |
|--------|-------------|
| 5 bits | Op Code     |
| 3 bits | Rs          |
| 3 bits | Rd          |
| 5 bits | Immediate   |

##### I-format 2 Instructions
| Bits   | Description |
|--------|-------------|
| 5 bits | Op Code     |
| 3 bits | Rs          |
| 8 bits | Immediate   |

#### R-format
R-format instructions exclusively use registers as operands.

| Bits   | Description       |
|--------|-------------------|
| 5 bits | Op Code           |
| 3 bits | Rs                |
| 3 bits | Rt                |
| 3 bits | Rd                |
| 2 bits | Op Code Extension |
