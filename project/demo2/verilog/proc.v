/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
`default_nettype none
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input wire clk;
   input wire rst;

   output wire err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   
   /* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */
     // Internal signals for each pipeline stage
   wire [15:0] PC, instr, PC_f, PC_d;
   wire [15:0] PC_Jump, WB;
   wire [15:0] RSData, RTData, ALU, readData;
   wire [15:0] Imm5, Imm8, sImm8, sImm11;

   // Control signals
   wire nHaltSig, RegWrt, ZeroExt, ImmSrc, invA, invB;
   wire ALUSign, Cin, ALUJmp, MemWrt, MemRead;
   wire [1:0] RegSrc, BSrc, RegDst;
   wire [3:0] Oper, BranchTaken;
   wire [2:0] RD;

   // Flopped signals between pipeline stages
   wire [15:0] PC_f_flopped, instr_f_flopped;
   wire [15:0] PC_2ff, PC_3ff;
   wire [15:0] ALU_ff;
   wire MemWrt_2flopped, MemRead_2flopped;

   /* Fetch Stage */
   fetch fetch0 (
       .clk(clk), 
       .rst(rst), 
       .PC_B(PC_Jump), 
       .PC_curr(PC),
       .nHaltSig(nHaltSig),
       .instr(instr), 
       .PC_Next(PC_f)
   );

   /* Decode Stage */
   decode decode0 (
       .clk(clk), 
       .rst(rst), 
       .instr(instr), 
       .invA(invA),
       .invB(invB),
       .Cin(Cin),
       .RD(RD),
       .WB(WB), 
       .PC(PC_f), 
       .nHaltSig(nHaltSig),
       .MemRead(MemRead),
       .ImmSrc(ImmSrc),
       .ALUSign(ALUSign),
       .ALUJmp(ALUJmp),
       .MemWrt(MemWrt),
       .RegSrc(RegSrc),
       .BSrc(BSrc),
       .BranchTaken(BranchTaken),
       .Oper(Oper),
       .err(err), 
       .RSData(RSData), 
       .RTData(RTData), 
       .Imm5(Imm5), 
       .Imm8(Imm8), 
       .sImm8(sImm8), 
       .sImm11(sImm11), 
       .PC_Next(PC_d)
   );

   /* Execute Stage */
   execute execute0 (
       .clk(clk),
       .rst(rst),
       .NOP(), // Placeholder if NOP signal is needed
       .RSData(RSData), 
       .RTData(RTData), 
       .nHaltSig(nHaltSig),
       .Oper(Oper), 
       .PC(PC_d), 
       .Imm5(Imm5), 
       .Imm8(Imm8), 
       .sImm8(sImm8), 
       .sImm11(sImm11), 
       .BSrc(BSrc), 
       .ImmSrc(ImmSrc), 
       .ALUJmp(ALUJmp), 
       .invA(invA), 
       .invB(invB), 
       .ALUSign(ALUSign), 
       .cin(Cin), 
       .BranchTaken(BranchTaken), 
       .ALU_Out(ALU), 
       .PC_Next(PC_Jump),
       .MemRead_ff(MemRead), 
       .MemRead_2ff(MemRead_2flopped), 
       .MemWrt_ff(MemWrt), 
       .MemWrt_2ff(MemWrt_2flopped),
       .PC_2ff(PC_2ff)
   );

   /* Memory Stage */
   memory memory0 (
       .clk(clk),
       .rst(rst),
       .PC(PC_2ff),
       .ALU(ALU), 
       .nHaltSig(nHaltSig),
       .writeData(RTData), 
       .readEn(MemRead_2flopped), 
       .MemWrt(MemWrt_2flopped), 
       .readData(readData), 
       .ALU_ff(ALU_ff),
       .PC_Next(PC_3ff)
   );

   /* Write-Back (WB) Stage */
   wb wb0 (
       .MemIn(readData), 
       .PcIn(PC_3ff), 
       .ALUIn(ALU_ff), 
       .RegSrc(RegSrc), 
       .WB(WB)
   );

endmodule // proc
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0: