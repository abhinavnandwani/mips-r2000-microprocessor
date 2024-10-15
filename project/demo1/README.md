# Demo1: WISC-F24 Single-Cycle Memory Specification

## Overview
This document outlines the memory specification for the single-cycle processor implementation of the WISC-F24 architecture.

## Key Points

1. **Dual Memory Instances**
   - Two instances of the memory module are required:
     - One for instructions
     - One for data
   - Both instances should be loaded with the same program binary

2. **Memory Operations**

   | Enable | Wr | Function | data_out |
   |--------|----|-----------| ---------|
   | 0 | X | No operation | 0 |
   | 1 | 0 | Read | M[addr] |
   | 1 | 1 | Write data_in | 0 |

3. **Read Cycles**
   - Data output immediately reflects the contents of the address input
   - Changes in a flow-through fashion if the address changes

4. **Write Cycles**
   - "wr", "addr", and "data_in" signals must be stable at the rising edge of the clock

5. **Memory Initialization**
   - File name: "loadfile_all.img" (can be changed in Verilog source)
   - Loaded at the first rising edge of the clock during reset
   - File format:
     ```
     @0
     12
     34
     56
     ```
     where "@0" specifies a starting address of zero, and "12", "34", etc. represent 2-digit hex numbers

6. **Memory Dump**
   - Created when "createdump" is asserted at the rising edge of the clock
   - Generates a file named "dumpfile" in the mentor directory
   - Contains locations from zero to the highest modified address
   - Format:
     ```
     00001234
     00011234
     00021234
     ```

7. **Possible Modifications** (in memory2c.v)
   - File names can be changed
   - Dumpfile format can be modified
   - Starting and ending addresses for dump can be adjusted

8. **Dual Memory Setup**
   - Both instruction and data memories can load the same loadfile
   - Only data memory should generate a dumpfile

9. **Loading Programs**
   - Use the assembler to create the memory dump
   - Name it "loadfile_all.img"
   - Copy it to the directory where memory2c.v is located

## Usage
1. Instantiate the memory module twice in your design:
   - Once for instruction memory
   - Once for data memory
2. Ensure both instances are loaded with the same program binary
3. Use the appropriate enable and wr signals to control read/write operations
4. Assert "createdump" at the end of simulation to generate the memory dump file

## Note
This specification is crucial for the correct implementation of the WISC-F24 single-cycle processor. Ensure all timing and signal requirements are met for proper functionality.
