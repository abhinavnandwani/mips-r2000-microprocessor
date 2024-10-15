# WISC-F24 Microarchitecture Specification

## Project Overview
This project involves the hardware implementation of the WISC-F24 microarchitecture, as specified in the provided document. Me and **Anna** were responsible for designing the hardware components based on the given specification.

The WISC-F24 architecture shares many resemblances with the MIPS R2000, with major differences being a smaller instruction set and 16-bit words[1].

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
- Harvard architecture: separate physical memories for instructions and data
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
- Two register forwarding paths:
  - Within ID stage
  - Between beginning of MEM and beginning of EX
- All branches predicted as not-taken
- Goal: Reduce CPI or total cycles for program execution[1]

## Exceptions: Extra Credit
- Optional implementation
- IllegalOp exception for unrecognized opcodes
- Saves current PC into EPC
- Loads address 0x02 (exception handler location)
- Minimum handler functionality: load 0xBADD into R7 and call RTI instruction[1]

## Instruction Set Architecture Specification

### Instruction Formats

1. J-format
2. Two I-formats
3. R-format

#### J-format

| Bits   | Description  |
|--------|--------------|
| 5 bits | Op Code      |
| 11 bits| Displacement |

#### I-format 1

| Bits   | Description |
|--------|-------------|
| 5 bits | Op Code     |
| 3 bits | Rs          |
| 3 bits | Rd          |
| 5 bits | Immediate   |

#### I-format 2

| Bits   | Description |
|--------|-------------|
| 5 bits | Op Code     |
| 3 bits | Rs          |
| 8 bits | Immediate   |

#### R-format

| Bits   | Description       |
|--------|-------------------|
| 5 bits | Op Code           |
| 3 bits | Rs                |
| 3 bits | Rt                |
| 3 bits | Rd                |
| 2 bits | Op Code Extension |

### Instructions Summary (Partial List)

| Instruction Format | Syntax | Semantics |
|--------------------|--------|-----------|
| 00000 xxxxxxxxxxx  | HALT   | Cease instruction issue, dump memory state to file |
| 00001 xxxxxxxxxxx  | NOP    | None |
| 01000 sss ddd iiiii | ADDI Rd, Rs, immediate | Rd ← Rs + (sign ext.) |
| 01001 sss ddd iiii | SUBI Rd, Rs, immediate | Rd ← I(sign ext.) - Rs |
| 01010 sss ddd iiiii | XORI Rd, Rs, immediate | Rd ← Rs XOR I(zero ext.) |
| ... | ... | ... |
