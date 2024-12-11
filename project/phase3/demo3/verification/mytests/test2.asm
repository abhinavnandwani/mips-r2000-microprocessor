// Step 1: Load Immediate Values into Registers
lbi r1, 4             // Load immediate 4 into r1 (aligned address offset)
lbi r2, 16            // Load immediate 16 into r2 (aligned address offset)
lbi r3, 12            // Load immediate 12 into r3 (aligned address offset)
lbi r4, 32            // Load immediate 32 into r4 (aligned address offset)
lbi r5, 28            // Load immediate 28 into r5 (aligned address offset)
lbi r6, 64            // Load immediate 64 into r6

// Step 2: Perform Arithmetic Operations
add r1, r1, r2        // Add r1 and r2, store result in r1 (4 + 16 = 20)
add r3, r3, r4        // Add r3 and r4, store result in r3 (12 + 32 = 44)
sub r2, r1, r6        // Subtract r6 from r1, store result in r2 (20 - 64 = -44)

// Step 3: Test Branching and Conditional Operations
bnez r2, 4            // If r2 is not zero, jump to instruction at 22 (skips next instruction)
nop                   // No operation (this part will be skipped if r2 is non-zero)

// Step 4: Perform Logical Operations
andni r3, r4, 1       // Perform bitwise AND between r4 and 1, store result in r3 (32 & 1 = 0)
xor r5, r1, r3        // Perform bitwise XOR between r1 and r3, store result in r5 (20 ^ 0 = 20)

// Step 5: Shift Operations
slli r6, r2, 2        // Shift left r2 by 2 bits, store in r6 (-44 << 2 = -176)
srli r7, r3, 1        // Shift right r3 by 1 bit, store in r7 (0 >> 1 = 0)

// Step 6: Store and Load Operations (Memory)
stu r1, r3, 0         // Store value of r1 into memory at aligned address (r3 + 0)
ld r2, r1, 4          // Load value from memory at aligned address (r1 + 4) into r2

// Step 7: Additional Add and Store Operations
st r1, r3, 0          // Store value of r1 into memory at aligned address (r3 + 0)
stu r5, r7, 8         // Store value of r5 into memory at aligned address (r7 + 8)

// Step 9: End of Sequence
halt                  // Halt the execution (end of test)