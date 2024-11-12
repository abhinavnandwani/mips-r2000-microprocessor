// Step 1: Load Immediate Values into Registers
lbi r1, 5             // Load immediate 5 into r1
lbi r2, 20            // Load immediate 20 into r2
lbi r3, 15            // Load immediate 15 into r3
lbi r4, 30            // Load immediate 30 into r4
lbi r5, 25            // Load immediate 25 into r5
lbi r6, 50            // Load immediate 50 into r6

// Step 2: Perform Arithmetic Operations
add r1, r1, r2        // Add r1 and r2, store result in r1 (5 + 20 = 25)
add r3, r3, r4        // Add r3 and r4, store result in r3 (15 + 30 = 45)
sub r2, r1, r6        // Subtract r6 from r1, store result in r2 (25 - 50 = -25)

// Step 3: Test Branching and Conditional Operations
bnez r2, 4          // If r2 is not zero, jump to instruction at 22 (skips next instruction)
nop                   // No operation (this part will be skipped if r2 is non-zero)

// Step 4: Perform Logical Operations
andni r3, r4, 1       // Perform bitwise AND between r4 and 1, store result in r3 (30 & 1 = 0)
xor r5, r1, r3        // Perform bitwise XOR between r1 and r3, store result in r5 (25 ^ 0 = 25)

// Step 5: Shift Operations
slli r6, r2, 2        // Shift left r2 by 2 bits, store in r6 (-25 << 2 = -100)
srli r7, r3, 1        // Shift right r3 by 1 bit, store in r7 (0 >> 1 = 0)

// Step 6: Store and Load Operations (Memory)
stu r1, r3, 0         // Store value of r1 into memory at address (r3 + 0)
ld r2, r1, 4          // Load value from memory at (r1 + 4) into r2

// Step 7: Additional Add and Store Operations
st r1, r3, 0          // Store value of r1 into memory at address (r3 + 0)
stu r5, r7, 8         // Store value of r5 into memory at address (r7 + 8)

// Step 9: End of Sequence
halt                  // Halt the execution (end of test)