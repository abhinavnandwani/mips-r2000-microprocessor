/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
`default_nettype none
module proc_hier_bench();

   /* BEGIN DO NOT TOUCH */
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   // End of automatics
   

   wire [15:0] PC;
   wire [15:0] Inst;           /* This should be the 15 bits of the FF that
                                  stores instructions fetched from instruction memory
                               */
   wire        RegWrite;       /* Whether register file is being written to */
   wire [2:0]  WriteRegister;  /* What register is written */
   wire [15:0] WriteData;      /* Data */
   wire        MemWrite;       /* Similar as above but for memory */
   wire        MemRead;
   wire [15:0] MemAddress;
   wire [15:0] MemData;

   wire        Halt;         /* Halt executed and in Memory or writeback stage */
        
   integer     inst_count;
   integer     trace_file;
   integer     sim_log_file;
     

   proc_hier DUT();
   

   initial begin
      $display("Hello world...simulation starting");
      $display("See verilogsim.log and verilogsim.trace for output");
      inst_count = 0;
      trace_file = $fopen("verilogsim.trace");
      sim_log_file = $fopen("verilogsim.log");
      
   end

   always @ (posedge DUT.c0.clk) begin
      if (!DUT.c0.rst) begin
         if (Halt || RegWrite || MemWrite) begin
            inst_count = inst_count + 1;
         end
         $fdisplay(sim_log_file, "SIMLOG:: Cycle %d PC: %8x I: %8x R: %d %3d %8x M: %d %d %8x %8x",
                  DUT.c0.cycle_count,
                  PC,
                  Inst,
                  RegWrite,
                  WriteRegister,
                  WriteData,
                  MemRead,
                  MemWrite,
                  MemAddress,
                  MemData);
         if (RegWrite) begin
            if (MemWrite) begin
               // stu
               $fdisplay(trace_file,"INUM: %8d PC: 0x%04x REG: %d VALUE: 0x%04x ADDR: 0x%04x VALUE: 0x%04x",
                         (inst_count-1),
                        PC,
                        WriteRegister,
                        WriteData,
                        MemAddress,
                        MemData);
            end else if (MemRead) begin
               // ld
               $fdisplay(trace_file,"INUM: %8d PC: 0x%04x REG: %d VALUE: 0x%04x ADDR: 0x%04x",
                         (inst_count-1),
                        PC,
                        WriteRegister,
                        WriteData,
                        MemAddress);
            end else begin
               $fdisplay(trace_file,"INUM: %8d PC: 0x%04x REG: %d VALUE: 0x%04x",
                         (inst_count-1),
                        PC,
                        WriteRegister,
                        WriteData );
            end
         end else if (Halt) begin
            $fdisplay(sim_log_file, "SIMLOG:: Processor halted\n");
            $fdisplay(sim_log_file, "SIMLOG:: sim_cycles %d\n", DUT.c0.cycle_count);
            $fdisplay(sim_log_file, "SIMLOG:: inst_count %d\n", inst_count);
            $fdisplay(trace_file, "INUM: %8d PC: 0x%04x",
                      (inst_count-1),
                      PC );

            $fclose(trace_file);
            $fclose(sim_log_file);
            
            $finish;
         end else begin // if (RegWrite)
            if (MemWrite) begin
               // st
               $fdisplay(trace_file,"INUM: %8d PC: 0x%04x ADDR: 0x%04x VALUE: 0x%04x",
                         (inst_count-1),
                        PC,
                        MemAddress,
                        MemData);
            end else begin
               // conditional branch or NOP
               // Need better checking in pipelined testbench
               inst_count = inst_count + 1;
               $fdisplay(trace_file, "INUM: %8d PC: 0x%04x",
                         (inst_count-1),
                         PC );
            end
         end 
      end
      
   end

   /* END DO NOT TOUCH */

   /* Assign internal signals to top level wires
      The internal module names and signal names will vary depending
      on your naming convention and your design */

   // Fetch stage assignments
   assign PC = DUT.p0.fetch0.PC_Next;  // Next PC from fetch stage
   assign Inst = DUT.p0.fetch0.instr;   // Instruction fetched

   // Decode stage assignments
   assign RegWrite = DUT.p0.decode0.RegWrt;  // Register write signal
   assign WriteRegister = DUT.p0.decode0.RegDst; // Register destination
   assign WriteData = DUT.p0.decode0.WB;  // Data to write to register

   // Memory stage assignments
   assign MemRead = DUT.p0.memory0.readData; // Memory read signal
   assign MemWrite = (DUT.p0.memory0.nHaltSig & DUT.p0.memory0.MemWrt); // Memory write signal
   assign MemAddress = DUT.p0.memory0.ALU; // Address for memory access
   assign MemData = DUT.p0.memory0.writeData; // Data to write to memory

   // Control and status signals
   assign Halt = DUT.p0.memory0.nHaltSig; // Processor halt signal

   // Additional control signals from instruction decoder
   assign ZeroExt = DUT.p0.control0.ZeroExt;  // Zero extension signal
   assign BSrc = DUT.p0.control0.BSrc;        // Source selection for ALU
   assign ImmSrc = DUT.p0.control0.ImmSrc;    // Immediate source selection
   assign ALUOpr = DUT.p0.control0.ALUOpr;    // ALU operation code
   assign invA = DUT.p0.control0.invA;        // Invert A signal for ALU
   assign invB = DUT.p0.control0.invB;        // Invert B signal for ALU
   assign ALUSign = DUT.p0.control0.ALUSign;  // ALU sign control
   assign cin = DUT.p0.control0.cin;          // Carry-in for ALU
   assign ALUJmp = DUT.p0.control0.ALUJmp;    // ALU jump signal
   assign RegSrc = DUT.p0.control0.RegSrc;    // Source for register write
   assign BranchTaken = DUT.p0.control0.BranchTaken; // Branch taken signal

   // Additional signals from decode stage
   assign err = DUT.p0.decode0.err;           // Error signal from decode stage
   assign RSData = DUT.p0.decode0.RSData;     // Data for source register
   assign RTData = DUT.p0.decode0.RTData;     // Data for target register
   assign Imm5 = DUT.p0.decode0.Imm5;         // 5-bit immediate value
   assign Imm8 = DUT.p0.decode0.Imm8;         // 8-bit immediate value
   assign sImm8 = DUT.p0.decode0.sImm8;       // Sign-extended 8-bit immediate
   assign sImm11 = DUT.p0.decode0.sImm11;     // Sign-extended 11-bit immediate

   // ALU output assignment
   assign ALU_Out = DUT.p0.execute0.ALU_Out;  // Output from the ALU

   /* Add any other necessary assignments here */


   
endmodule
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
