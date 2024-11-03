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
   wire [3:0] Oper,BranchTaken;
   wire [15:0] WB;
   wire [15:0] RSData, RTData, ALU, readData;
   wire [15:0] Imm5, Imm8, sImm8, sImm11;
   wire nHaltSig, RegWrt, ZeroExt, ImmSrc, invA, invB, ALUSign, Cin, ALUJmp, MemWrt,MemRead,err;        
   wire [1:0] RegSrc, BSrc,RegDst;      
   wire [2:0] RD;  


   control control0(.instr(instr), .err(err), .nHaltSig(nHaltSig), .MemRead(MemRead),.RegDst(RegDst), .RegWrt(RegWrt), .ZeroExt(ZeroExt), .BSrc(BSrc), .ImmSrc(ImmSrc), .ALUOpr(ALUOpr), .ALUSign(ALUSign), .ALUJmp(ALUJmp), .MemWrt(MemWrt), .RegSrc(RegSrc), .BranchTaken(BranchTaken));
   
   fetch fetch0(
      .clk(clk), 
      .rst(rst), 
      .PC_B(PC_Jump), 
      .PC_curr(PC),
      .nHaltSig(nHaltSig),
      .instr(instr), 
      .PC_Next(PC_f)
      );

   dff dff_f_pc(q(PC_f_flopped), d(PC_f), .clk(clk), .rst(rst)); \\ will move later
   dff dff_f_pc_curr(.q(pc_curr_f_flopped), .d(PC), .clk(clk), .rst(rst));
   dff dff_f_instr(.q(instr_f_flopped), .d(instr), .clk(clk), .rst(rst));
   
   decode decode0(
      .clk(clk), 
      .rst(rst), 
      .instr(instr), 
      .invA(invA),
      .invB(invB),
      .Cin(Cin),
      .RD(RD),
      .WB(WB), 
      .PC(PC_f), 
      .ALUOpr(ALUOpr),
      .Oper(Oper),
      .RegDst(RegDst), 
      .ZeroExt(ZeroExt), 
      .RegWrt(RegWrt), 
      .err(err), 
      .RSData(RSData), 
      .RTData(RTData), 
      .Imm5(Imm5), 
      .Imm8(Imm8), 
      .sImm8(sImm8), 
      .sImm11(sImm11), 
      .PC_Next(PC_d)
      );
      
   dff dff_d_oper(.q(oper_d_flopped), .d(Oper), .clk(clk), .rst(rst));
   dff dff_d_RSData(.q(RSData_d_flopped), .d(RSData), .clk(clk), .rst(rst));
   dff dff_d_RTData(.q(RTData_d_flopped), .d(RSData), .clk(clk), .rst(rst));
   dff dff_d_Imm5(.q(Imm5_d_flopped), .d(Imm5), .clk(clk), .rst(rst));
   dff dff_d_Imm8(.q(Imm8_d_flopped), .d(Imm8), .clk(clk), .rst(rst));
   dff dff_d_sImm8(.q(sImm8_d_flopped), .d(sImm8), .clk(clk), .rst(rst));
   dff dff_d_sImm11(.q(sImm11_d_flopped), .d(sImm11), .clk(clk), .rst(rst));
   dff dff_d_PC(.q(PC_d_flopped), .d(PC_d), .clk(clk), .rst(rst));
   dff dff_d_invA(.q(invA_d_flopped), .d(invA), .clk(clk), .rst(rst));
   dff dff_d_RSData(.q(invB_d_flopped), .d(invB), .clk(clk), .rst(rst));
   dff dff_d_RSData(.q(Cin_d_flopped), .d(Cin), .clk(clk), .rst(rst));

   execute execute0(.RSData(RSData), .RTData(RTData), .nHaltSig(nHaltSig),.Oper(Oper), .PC(PC_d), .Imm5(Imm5), .Imm8(Imm8), .sImm8(sImm8), .sImm11(sImm11), .BSrc(BSrc), .ImmSrc(ImmSrc), .ALUJmp(ALUJmp), .invA(invA), .invB(invB), .ALUSign(ALUSign), .cin(Cin), .BranchTaken(BranchTaken), .ALU_Out(ALU), .PC_Next(PC_Jump));
   dff dff_e_ALU(.q(ALU_e_flopped), .d(ALU), .clk(clk), .rst(rst));
   dff dff_e_PC(.q(PC_Jump_e_flopped), .d(PC_Jump), .clk(clk), .rst(rst));

   memory memory0(.clk(clk),.rst(rst),.ALU(ALU), .nHaltSig(nHaltSig),.writeData(RTData), .readEn(MemRead), .MemWrt(MemWrt), .readData(readData));
   dff dff_memory(.q(readData_m_flopped), .d(readData), .clk(clk), .rst(rst));

   wb wb0(.MemIn(readData), .PcIn(PC_d), .ALUIn(ALU), .RegSrc(RegSrc), .WB(WB));

endmodule // proc
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
