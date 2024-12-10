/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
`default_nettype none
`timescale 1ns/10ps
module proc_hier_pbench();

   /* BEGIN DO NOT TOUCH */
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   // End of automatics
   

   wire [15:0] PC;
   wire [15:0] Inst;           /* This should be the 16 bits of the FF that
                                  stores instructions fetched from instruction memory
                               */
   wire        RegWrite;       /* Whether register file is being written to */
   wire [2:0]  WriteRegister;  /* What register is written */
   wire [15:0] WriteData;      /* Data */
   wire        MemWrite;       /* Similar as above but for memory */
   wire        MemRead;
   wire [15:0] MemAddress;
   wire [15:0] MemDataIn;
   wire [15:0] MemDataOut;
   wire        DCacheHit;
   wire        ICacheHit;
   wire        DCacheReq;
   wire        ICacheReq;
   

   wire        Halt;         /* Halt executed and in Memory or writeback stage */
        
   integer     inst_count;
   integer     trace_file;
   integer     sim_log_file;
     
   integer     DCacheHit_count;
   integer     ICacheHit_count;
   integer     DCacheReq_count;
   integer     ICacheReq_count;
   
   proc_hier DUT();   

   initial begin
      $display("Hello world...simulation starting");
      $display("See verilogsim.log and verilogsim.ptrace for output");
      inst_count = 0;
      DCacheHit_count = 0;
      ICacheHit_count = 0;
      DCacheReq_count = 0;
      ICacheReq_count = 0;

      trace_file = $fopen("verilogsim.ptrace");
      sim_log_file = $fopen("verilogsim.log");
      
   end

   always @ (posedge DUT.c0.clk) begin
      if (!DUT.c0.rst) begin
         if (Halt || RegWrite || MemWrite) begin
            inst_count = inst_count + 1;
         end
         if (DCacheHit) begin
            DCacheHit_count = DCacheHit_count + 1;      
         end    
         if (ICacheHit) begin
            ICacheHit_count = ICacheHit_count + 1;      
         end    
         if (DCacheReq) begin
            DCacheReq_count = DCacheReq_count + 1;      
         end    
         if (ICacheReq) begin
            ICacheReq_count = ICacheReq_count + 1;      
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
                   MemDataIn);
         if (RegWrite) begin
            $fdisplay(trace_file,"REG: %d VALUE: 0x%04x",
                      WriteRegister,
                      WriteData );            
         end
         if (MemRead) begin
            $fdisplay(trace_file,"LOAD: ADDR: 0x%04x VALUE: 0x%04x",
                      MemAddress, MemDataOut );
         end

         if (MemWrite) begin
            $fdisplay(trace_file,"STORE: ADDR: 0x%04x VALUE: 0x%04x",
                      MemAddress, MemDataIn  );
         end
         if (Halt) begin
            $fdisplay(sim_log_file, "SIMLOG:: Processor halted\n");
            $fdisplay(sim_log_file, "SIMLOG:: sim_cycles %d\n", DUT.c0.cycle_count);
            $fdisplay(sim_log_file, "SIMLOG:: inst_count %d\n", inst_count);
            $fdisplay(sim_log_file, "SIMLOG:: dcachehit_count %d\n", DCacheHit_count);
            $fdisplay(sim_log_file, "SIMLOG:: icachehit_count %d\n", ICacheHit_count);
            $fdisplay(sim_log_file, "SIMLOG:: dcachereq_count %d\n", DCacheReq_count);
            $fdisplay(sim_log_file, "SIMLOG:: icachereq_count %d\n", ICacheReq_count);

            $fclose(trace_file);
            $fclose(sim_log_file);
            #5;
            $finish;
         end 
      end
      
   end

   /* END DO NOT TOUCH */

   /* Assign internal signals to top level wires
      The internal module names and signal names will vary depending
      on your naming convention and your design */
   wire Done_DM;
   // Edit the example below. You must change the signal
   // names on the right hand side
    
   // Fetch stage signals
   assign PC = {DUT.p0.fetch0.instr_mem.\Addr<15> , DUT.p0.fetch0.instr_mem.\Addr<14> , DUT.p0.fetch0.instr_mem.\Addr<13> , 
             DUT.p0.fetch0.instr_mem.\Addr<12> , DUT.p0.fetch0.instr_mem.\Addr<11> , DUT.p0.fetch0.instr_mem.\Addr<10> , 
             DUT.p0.fetch0.instr_mem.\Addr<9> ,  DUT.p0.fetch0.instr_mem.\Addr<8> ,  DUT.p0.fetch0.instr_mem.\Addr<7> , 
             DUT.p0.fetch0.instr_mem.\Addr<6> ,  DUT.p0.fetch0.instr_mem.\Addr<5> ,  DUT.p0.fetch0.instr_mem.\Addr<4> , 
             DUT.p0.fetch0.instr_mem.\Addr<3> ,  DUT.p0.fetch0.instr_mem.\Addr<2> ,  DUT.p0.fetch0.instr_mem.\Addr<1> , 
             DUT.p0.fetch0.instr_mem.\Addr<0> };  // Current PC from fetch stage

   assign Inst = {DUT.p0.decode0.\instr<15> , DUT.p0.decode0.\instr<14> , DUT.p0.decode0.\instr<13> , 
                  DUT.p0.decode0.\instr<12> , DUT.p0.decode0.\instr<11> , DUT.p0.decode0.\instr<10> , 
                  DUT.p0.decode0.\instr<9> ,  DUT.p0.decode0.\instr<8> ,  DUT.p0.decode0.\instr<7> , 
                  DUT.p0.decode0.\instr<6> ,  DUT.p0.decode0.\instr<5> ,  DUT.p0.decode0.\instr<4> , 
                  DUT.p0.decode0.\instr<3> ,  DUT.p0.decode0.\instr<2> ,  DUT.p0.decode0.\instr<1> , 
                  DUT.p0.decode0.\instr<0> }; // Instruction fetched

   
      // Decode stage signals
   assign RegWrite = DUT.p0.decode0.regFile0.writeEn;     // Register write enable
   // Is register file being written to, one bit signal (1 means yes, 0 means no)
   
   assign WriteRegister = {DUT.p0.\DMWB_RD<2> , DUT.p0.\DMWB_RD<1> , DUT.p0.\DMWB_RD<0> };  // Register destination address
   // The name of the register being written to. (3 bit signal)
   
   assign WriteData = {DUT.p0.wb0.\WB<15> , DUT.p0.wb0.\WB<14> , DUT.p0.wb0.\WB<13> , 
                    DUT.p0.wb0.\WB<12> , DUT.p0.wb0.\WB<11> , DUT.p0.wb0.\WB<10> , 
                    DUT.p0.wb0.\WB<9> ,  DUT.p0.wb0.\WB<8> ,  DUT.p0.wb0.\WB<7> , 
                    DUT.p0.wb0.\WB<6> ,  DUT.p0.wb0.\WB<5> ,  DUT.p0.wb0.\WB<4> , 
                    DUT.p0.wb0.\WB<3> ,  DUT.p0.wb0.\WB<2> ,  DUT.p0.wb0.\WB<1> , 
                    DUT.p0.wb0.\WB<0> };

            
   // Data to write to register
   // Data being written to the register. (16 bits)
   
   // Memory stage signals
   assign Done_DM = DUT.p0.Done_DM;

   assign MemRead =  (DUT.p0.memory0.data_mem.Rd & Done_DM);      // Memory read enable
   // Is memory being read, one bit signal (1 means yes, 0 means no)
   
   assign MemWrite =  (DUT.p0.memory0.data_mem.Wr & Done_DM);   // Memory write enable
   // Is memory being written to (1 bit signal)
   
   assign MemAddress = {DUT.p0.memory0.\ALU<15> , DUT.p0.memory0.\ALU<14> , DUT.p0.memory0.\ALU<13> , 
                     DUT.p0.memory0.\ALU<12> , DUT.p0.memory0.\ALU<11> , DUT.p0.memory0.\ALU<10> , 
                     DUT.p0.memory0.\ALU<9> ,  DUT.p0.memory0.\ALU<8> ,  DUT.p0.memory0.\ALU<7> , 
                     DUT.p0.memory0.\ALU<6> ,  DUT.p0.memory0.\ALU<5> ,  DUT.p0.memory0.\ALU<4> , 
                     DUT.p0.memory0.\ALU<3> ,  DUT.p0.memory0.\ALU<2> ,  DUT.p0.memory0.\ALU<1> , 
                     DUT.p0.memory0.\ALU<0> }; // Address for memory read/write

   assign MemDataIn = {DUT.p0.memory0.data_mem.\DataIn<15> , DUT.p0.memory0.data_mem.\DataIn<14> , 
                     DUT.p0.memory0.data_mem.\DataIn<13> , DUT.p0.memory0.data_mem.\DataIn<12> , 
                     DUT.p0.memory0.data_mem.\DataIn<11> , DUT.p0.memory0.data_mem.\DataIn<10> , 
                     DUT.p0.memory0.data_mem.\DataIn<9> ,  DUT.p0.memory0.data_mem.\DataIn<8> ,  
                     DUT.p0.memory0.data_mem.\DataIn<7> ,  DUT.p0.memory0.data_mem.\DataIn<6> ,  
                     DUT.p0.memory0.data_mem.\DataIn<5> ,  DUT.p0.memory0.data_mem.\DataIn<4> ,  
                     DUT.p0.memory0.data_mem.\DataIn<3> ,  DUT.p0.memory0.data_mem.\DataIn<2> ,  
                     DUT.p0.memory0.data_mem.\DataIn<1> ,  DUT.p0.memory0.data_mem.\DataIn<0> }; // Data to write to memory

   assign MemDataOut = {DUT.p0.memory0.data_mem.\DataOut<15> , DUT.p0.memory0.data_mem.\DataOut<14> , 
                        DUT.p0.memory0.data_mem.\DataOut<13> , DUT.p0.memory0.data_mem.\DataOut<12> , 
                        DUT.p0.memory0.data_mem.\DataOut<11> , DUT.p0.memory0.data_mem.\DataOut<10> , 
                        DUT.p0.memory0.data_mem.\DataOut<9> ,  DUT.p0.memory0.data_mem.\DataOut<8> ,  
                        DUT.p0.memory0.data_mem.\DataOut<7> ,  DUT.p0.memory0.data_mem.\DataOut<6> ,  
                        DUT.p0.memory0.data_mem.\DataOut<5> ,  DUT.p0.memory0.data_mem.\DataOut<4> ,  
                        DUT.p0.memory0.data_mem.\DataOut<3> ,  DUT.p0.memory0.data_mem.\DataOut<2> ,  
                        DUT.p0.memory0.data_mem.\DataOut<1> ,  DUT.p0.memory0.data_mem.\DataOut<0> }; // Data read from memory


   // new added 05/03
   assign ICacheReq = DUT.p0.fetch0.instr_mem.Rd;
   // Signal indicating a valid instruction read request to cache
   // Above assignment is a dummy example
   
   assign ICacheHit = DUT.p0.fetch0.instr_mem.CacheHit;
   // Signal indicating a valid instruction cache hit
   // Above assignment is a dummy example

   assign DCacheReq = DUT.p0.memory0.data_mem.Rd | DUT.p0.memory0.data_mem.Wr;
   // Signal indicating a valid instruction data read or write request to cache
   // Above assignment is a dummy example
   //    
   assign DCacheHit = DUT.p0.memory0.data_mem.CacheHit;
   // Signal indicating a valid data cache hit
   // Above assignment is a dummy example
   
   assign Halt = DUT.p0.EXDM_HaltSig;
   // Processor halted
endmodule
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
