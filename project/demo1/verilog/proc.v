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

   output reg err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   
   /* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */
   wire PC_Jump;
   wire [15:0] instr, PC_f, PC_d;
   wire [15:0] WB;
   wire [15:0] RSData, RTData, ALU, readData;
   wire [15:0] Imm5, Imm8, sImm8, sImm11;

   //control instruction_decoder(.instr(instr), .nHaltSig(nHaltSig), .RegDst(RegDst), .RegWrt(RegWrt), .0Ext(0Ext), .BSrc(BSrc), .ImmSrc(ImmSrc), .ALUOpr(ALUOpr), .invA(invA), .invB(invB), .ALUSign(ALUSign), .cin(cin), .ALUJmp(ALUJmp), .MemWrt(MemWrt), .RegSrc(RegSrc));
   //aluOpr
   
   fetch fetch_stage(.clk(clk), .rst(rst), .PC_B(PC_Jump), nHaltSig(nHaltSig), .instr(instr), .PC_Next(PC_f));
   decode decode_stage(.clk(clk), .rst(rst), .instr(instr), .WB(WB), .PC(PC_f), .RegDst(RegDst), .0Ext(OExt), .RegWrt(RegWrt), .err(err), .RSData(RSData), .RTData(RTData), .Imm5(Imm5), .Imm8(Imm8), .sImm8(sIMm8), .sImm11(sImm11), .PC_Next(PC_d));
   execute execute_stage(.RSData(RSData), .RTData(RTData), .PC(PC_d), .Imm5(Imm5), .Imm8(Imm8), .sImm8(sImm8), .sImm11(sImm11), .BSrc(BSrc), .ImmSrc(ImmSrc), .ALUJmp(ALUJmp), .invA(invA), .invB(invB), .ALUSign(ALUSign), .cin(cin), .ALU_Out(ALU), .PC_Next(PC_Jump));
   memory memory_stage(.ALU(ALU), .writeData(RTData), .MemWrt(MemWrt), .readData(readData));
   wb wb_stage(.MemIn(readData), .PcIn(PC_d), .AluIn(ALU), .RegSrc(RegSrc), .WB(WB));

endmodule // proc
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
