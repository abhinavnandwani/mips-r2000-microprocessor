// Initialize registers and memory
lbi r0, 0            // Load base address into r0
lbi r5, 43           // Load 43 into r5
lbi r6, 43           // Load 43 into r6
lbi r7, 43           // Load 43 into r7

// Start loop to perform operations
.main_loop:
ld r1, r0, 0         // Load memory at address r0 + 0 into r1
st r5, r1, 0         // Store value of r5 at address r1 + 0
ld r1, r0, 2         // Load memory at address r0 + 2 into r1
st r6, r1, 1         // Store value of r6 at address r1 + 1
ld r1, r0, 4         // Load memory at address r0 + 4 into r1
st r7, r1, 1         // Store value of r7 at address r1 + 1

// Decrement register to create a loop counter
subi r5, r5, 1       // Decrease r5 by 1
bnez r5, .main_loop   // If r5 != 0, repeat the loop

halt                 // End of program
