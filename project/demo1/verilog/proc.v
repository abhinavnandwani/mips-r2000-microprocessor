/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input wire clk;
   input wire rst;

   output err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   
   /* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */
   wire [15:0] PC_Jump,PC;
   wire [15:0] instr, PC_f, PC_d;
   wire [5:0] ALUOpr;
   wire [3:0] Oper;
   wire [15:0] WB;
   wire [15:0] RSData, RTData, ALU, readData;
   wire [15:0] Imm5, Imm8, sImm8, sImm11;
   wire nHaltSig, RegWrt, ZeroExt, ImmSrc, invA, invB, ALUSign, Cin, ALUJmp, MemWrt;        
   wire [1:0] RegSrc, BSrc,RegDst;      
   wire [2:0] BranchTaken,RD;  


   control control0(.instr(instr), .err(err), .nHaltSig(nHaltSig), .RegDst(RegDst), .RegWrt(RegWrt), .ZeroExt(ZeroExt), .BSrc(BSrc), .ImmSrc(ImmSrc), .ALUOpr(ALUOpr), .invA(invA), .invB(invB), .ALUSign(ALUSign), .Cin(Cin), .ALUJmp(ALUJmp), .MemWrt(MemWrt), .RegSrc(RegSrc), .BranchTaken(BranchTaken));
   //aluOpr

   fetch fetch0(.clk(clk), .rst(rst), .PC_B(PC_Jump), .PC_curr(PC),.nHaltSig(nHaltSig), .instr(instr), .PC_Next(PC_f));
   decode decode0(.clk(clk), .rst(rst), .instr(instr), .RD(RD),.WB(WB), .PC(PC_f), .ALUOpr(ALUOpr),.Oper(Oper),.RegDst(RegDst), .ZeroExt(ZeroExt), .RegWrt(RegWrt), .err(err), .RSData(RSData), .RTData(RTData), .Imm5(Imm5), .Imm8(Imm8), .sImm8(sImm8), .sImm11(sImm11), .PC_Next(PC_d));
   execute execute0(.RSData(RSData), .RTData(RTData), .Oper(Oper), .PC(PC_d), .Imm5(Imm5), .Imm8(Imm8), .sImm8(sImm8), .sImm11(sImm11), .BSrc(BSrc), .ImmSrc(ImmSrc), .ALUJmp(ALUJmp), .invA(invA), .invB(invB), .ALUSign(ALUSign), .cin(Cin), .BranchTaken(BranchTaken), .ALU_Out(ALU), .PC_Next(PC_Jump));
   memory memory0(.ALU(ALU), .writeData(RTData), .nHaltSig(nHaltSig), .MemWrt(MemWrt), .readData(readData));
   wb wb0(.MemIn(readData), .PcIn(PC_d), .ALUIn(ALU), .RegSrc(RegSrc), .WB(WB));

endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
