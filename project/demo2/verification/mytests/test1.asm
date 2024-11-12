lbi r1,100     // Load an immediate value into r1
j 6            // Jump forward to avoid looping back
lbi r2,50      // Load an immediate value into r2
halt           // Stop the program
lbi r2,40      // Load an immediate value into r2 (reachable only if needed)
halt           // Stop the program