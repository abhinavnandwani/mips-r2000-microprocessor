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



    // Flopped Signals for Fetch Stage
    wire [15:0] PC_f_flopped;
    wire [15:0] pc_curr_f_flopped;
    wire [15:0] instr_f_flopped;

    // Flopped Signals for Decode Stage
    wire [3:0] oper_d_flopped;
    wire [15:0] RSData_d_flopped;
    wire [15:0] RTData_d_flopped;
    wire [15:0] Imm5_d_flopped;
    wire [15:0] Imm8_d_flopped;
    wire [15:0] sImm8_d_flopped;
    wire [15:0] sImm11_d_flopped;
    wire [15:0] PC_d_flopped, PC_d_2flopped;
    wire invA_d_flopped;
    wire invB_d_flopped;
    wire Cin_d_flopped;

    // Flopped Signals for Execute Stage
    wire [15:0] ALU_e_flopped,ALU_e_2flopped;
    wire [15:0] PC_Jump_e_flopped;

    // Flopped Signals for Memory Stage
    wire [15:0] readData_m_flopped;


   // Control Signals //
   // wire nHaltSig_flopped, nHaltSig_2flopped, nHaltSig_3flopped
    wire RegWrt_flopped, ZeroExt_flopped, ImmSrc_flopped, ALUSign_flopped;
    wire ALUJmp_flopped, MemWrt_flopped, MemWrt_2flopped;
    //wire err_flopped;

    wire MemRead_flopped, MemRead_2_flopped;
    wire [1:0] RegSrc_flopped, RegSrc_2_flopped, RegSrc_3_flopped;

    wire [1:0] BSrc_flopped;



    // D Flip-Flop Instances for Each Control Signal //
    //dff dff_nHaltSig(.q(nHaltSig_flopped), .d(nHaltSig), .clk(clk), .rst(rst));

    dff dff_ImmSrc(.q(ImmSrc_flopped), .d(ImmSrc), .clk(clk), .rst(rst)); // ID to X 
    dff dff_ALUSign(.q(ALUSign_flopped), .d(ALUSign), .clk(clk), .rst(rst)); // ID to X
    dff dff_ALUJmp(.q(ALUJmp_flopped), .d(ALUJmp), .clk(clk), .rst(rst)); // ID to X
    dff dff_BSrc[1:0](.q(BSrc_flopped), .d(BSrc), .clk({2{clk}}), .rst({2{rst}})); // ID to X

   // dff dff_err(.q(err_flopped), .d(err), .clk(clk), .rst(rst)); // TODO 

    // signals to DM //
    dff dff_MemRead(.q(MemRead_flopped), .d(MemRead), .clk(clk), .rst(rst)); // ID to X
    dff dff_MemRead_2(.q(MemRead_2_flopped), .d(MemRead_flopped), .clk(clk), .rst(rst)); // X to DM

    dff dff_MemWrt(.q(MemWrt_flopped), .d(MemWrt), .clk(clk), .rst(rst)); // ID to X
    dff dff_MemWrt_2(.q(MemWrt_2flopped), .d(MemWrt_flopped), .clk(clk), .rst(rst)); // X to DM 

    // to WB //
    dff dff_RegSrc[5:0](.q({RegSrc_3_flopped,RegSrc_2_flopped,RegSrc_flopped}), .d({RegSrc_2_flopped,RegSrc_flopped, RegSrc}), .clk({6{clk}}), .rst({6{rst}})); // ID to X


   control control0(.instr(instr), .err(err), .nHaltSig(nHaltSig), .MemRead(MemRead),.RegDst(RegDst), .RegWrt(RegWrt), .ZeroExt(ZeroExt), .BSrc(BSrc), .ImmSrc(ImmSrc), .ALUOpr(ALUOpr), .ALUSign(ALUSign), .ALUJmp(ALUJmp), .MemWrt(MemWrt), .RegSrc(RegSrc), .BranchTaken(BranchTaken));

   fetch fetch0(
      .clk(clk), 
      .rst(rst), 
      .PC_B(PC_Jump_e_flopped), 
      .PC_curr(PC),
      .nHaltSig(nHaltSig),
      .instr(instr), 
      .PC_Next(PC_f)
      );

   register dff_f_pc(.r(PC_f_flopped), .w(PC_f), .clk(clk), .rst(rst),.we(1'b1)); //will move later
   register dff_f_pc_curr(.r(pc_curr_f_flopped), .w(PC), .clk(clk), .rst(rst),.we(1'b1));
   register dff_f_instr(.r(instr_f_flopped), .w(instr), .clk(clk), .rst(rst),.we(1'b1));
   
   decode decode0(
      .clk(clk), 
      .rst(rst), 
      .instr(instr_f_flopped), 
      .invA(invA),
      .invB(invB),
      .Cin(Cin),
      .RD(RD),
      .WB(WB), 
      .PC(PC_f_flopped), 
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

   dff dff_d_oper[3:0](.q(oper_d_flopped), .d(Oper), .clk({4{clk}}), .rst({4{rst}}));

   register dff_d_RSData(.r(RSData_d_flopped), .w(RSData), .clk(clk), .rst(rst), .we(1'b1));
   register dff_d_RTData(.r(RTData_d_flopped), .w(RTData), .clk(clk), .rst(rst), .we(1'b1));
   register dff_d_Imm5(.r(Imm5_d_flopped), .w(Imm5), .clk(clk), .rst(rst), .we(1'b1));
   register dff_d_Imm8(.r(Imm8_d_flopped), .w(Imm8), .clk(clk), .rst(rst), .we(1'b1));
   register dff_d_sImm8(.r(sImm8_d_flopped), .w(sImm8), .clk(clk), .rst(rst), .we(1'b1));
   register dff_d_sImm11(.r(sImm11_d_flopped), .w(sImm11), .clk(clk), .rst(rst), .we(1'b1));
   register dff_d_PC(.r(PC_d_flopped), .w(PC_d), .clk(clk), .rst(rst), .we(1'b1));
   register dff_d_PC2(.r(PC_d_2flopped), .w(PC_d_flopped), .clk(clk), .rst(rst), .we(1'b1));

   dff dff_d_invA(.q(invA_d_flopped), .d(invA), .clk(clk), .rst(rst));
   dff dff_d_invB(.q(invB_d_flopped), .d(invB), .clk(clk), .rst(rst));
   dff dff_d_Cin(.q(Cin_d_flopped), .d(Cin), .clk(clk), .rst(rst));

   execute execute0(
      .RSData(RSData_d_flopped), 
      .RTData(RTData_d_flopped), 
      .nHaltSig(nHaltSig),
      .Oper(Oper), 
      .PC(PC_d_flopped), 
      .Imm5(Imm5_d_flopped), 
      .Imm8(Imm8_d_flopped), 
      .sImm8(sImm8_d_flopped), 
      .sImm11(sImm11_d_flopped), 
      .BSrc(BSrc_flopped), 
      .ImmSrc(ImmSrc_flopped), 
      .ALUJmp(ALUJmp_flopped), 
      .invA(invA_d_flopped), 
      .invB(invB_d_flopped), 
      .ALUSign(ALUSign_flopped), 
      .cin(Cin_d_flopped), 
      .BranchTaken(BranchTaken), 
      .ALU_Out(ALU), 
      .PC_Next(PC_Jump)
      );
   register dff_e_ALU(.r(ALU_e_flopped), .w(ALU), .clk(clk), .rst(rst),.we(1'b1));
   register dff_e_ALU2(.r(ALU_e_2flopped), .w(ALU_e_flopped), .clk(clk), .rst(rst),.we(1'b1));
  // register dff_e_PC(.w(PC_Jump_e_flopped), .r(PC_Jump), .clk(clk), .rst(rst),.we(1'b1));

   memory memory0(.clk(clk),.rst(rst),.ALU(ALU_e_flopped), .nHaltSig(nHaltSig),.writeData(RTData), .readEn(MemRead_2_flopped), .MemWrt(MemWrt_2flopped), .readData(readData));
   register dff_memory(.w(readData_m_flopped), .r(readData), .clk(clk), .rst(rst),.we(1'b1));

   wb wb0(.MemIn(readData_m_flopped), .PcIn(PC_d_2flopped), .ALUIn(ALU_e_2flopped), .RegSrc(RegSrc_3_flopped), .WB(WB));



endmodule // proc
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0: