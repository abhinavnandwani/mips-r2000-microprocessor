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

   wire [15:0] PC, instr, PC_f, PC_d;
   wire [15:0] PC_Jump, WB;
   wire [15:0] RSData, RTData, ALU, readData;
   wire [15:0] Imm5, Imm8, sImm8, sImm11;

   // Control signals
   wire HaltSig, ZeroExt, ImmSrc, invA, invB;
   wire ALUSign, Cin, ALUJmp, MemWrt, MemRead;
   wire [1:0] RegSrc, BSrc, RegDst;
   wire [3:0] Oper, BranchTaken;
   wire [2:0] RD,ID_Rt,ID_Rs,IDEX_Rs,IDEX_Rt;

   // Flopped signals between pipeline stages
   wire [15:0] ID_PC, ID_instr;
   wire NOP, NOP_mech;

   wire valid;
   wire [15:0] IFID_instr_comb;

   // Stall Flops
   wire RegWrt_1_nflopped, RegWrt_2_nflopped;
   wire [2:0] RD_1_nflopped, RD_2_nflopped;

   wire IDEX_HaltSig, IDEX_MemRead, IDEX_ImmSrc, IDEX_HaltSig_comb, IDEX_ALUSign, IDEX_ALUJmp, IDEX_MemWrt, IDEX_err, IDEX_RegWrt;
   wire [1:0] IDEX_RegSrc, IDEX_BSrc,B_Sel,A_Sel;
   wire [3:0] IDEX_BranchTaken, IDEX_Oper;
   wire [15:0] IDEX_RSData, IDEX_RTData, IDEX_Imm5, IDEX_Imm8, IDEX_sImm8, IDEX_sImm11, IDEX_PC_Next;
   wire IDEX_invA, IDEX_invB, IDEX_Cin, IDEX_NOP, IDEX_RegWrt_2_nflopped, IDEX_RegWrt_1_nflopped;
   wire [2:0] IDEX_RD, IDEX_RD_2_nflopped, IDEX_RD_1_nflopped;
   wire BrchCnd, NOP_Branch;

   wire [15:0] EX_ALU,EXDM_ALU;
   wire [15:0] EXDM_RTData;
   wire [15:0] EXDM_PC;
   wire EXDM_MemWrt, EXDM_MemRead, EXDM_HaltSig;
   wire [15:0] DMWB_ALU, DMWB_PC, DMWB_readData,DMWB_RD_Data,EXDM_RD_Data,ALU_RTData;
   wire IF_err, ID_err, IDF_err, EX_err, ID_reg_err, DM_err, FDM_err, FWB_err, DMWB_err, WB_err;
   wire Stall_DM, Done_DM,EX_RegWrt,ID_RegWrt,EXDM_RegWrt,DMWB_RegWrt;
   wire [2:0] EXDM_RD, DMWB_RD;
   wire fetch_stall;
   wire [1:0] EXDM_RegSrc, DMWB_RegSrc;
   wire CacheHit;
   wire takeRs_EXDM, takeRt_EXDM, takeRs_DMWB, takeRt_DMWB, takeRs_EXDM_ff, takeRt_EXDM_ff,takeRs_DMWB_ff,takeRt_DMWB_ff;
   wire Done_DM_ff;

   dff done_ff(.q(Done_DM_ff), .d(Done_DM), .clk(clk), .rst(rst));

   dff Rs_EXDM_ff(.q(takeRs_EXDM_ff), .d(Done_DM ? takeRs_EXDM : takeRs_EXDM_ff), .clk(clk), .rst(rst));
   dff Rs_DMWB_ff(.q(takeRs_DMWB_ff), .d(Done_DM ? takeRs_DMWB : takeRs_DMWB_ff), .clk(clk), .rst(rst));
   dff Rt_EXDM_ff(.q(takeRt_EXDM_ff), .d(Done_DM ? takeRt_EXDM : takeRt_EXDM_ff), .clk(clk), .rst(rst));
   dff Rt_DMWB_ff(.q(takeRt_DMWB_ff), .d(Done_DM ? takeRt_DMWB : takeRt_DMWB_ff), .clk(clk), .rst(rst));

   /* Fetch Stage */
   fetch fetch0 (
      .clk(clk), 
      .rst(rst),
      .NOP(NOP_mech),
      .NOP_Branch(NOP_Branch),
      .branch(|{BrchCnd,IDEX_ALUJmp}),
      .PC_B(PC_Jump), 
      .PC_curr(PC),
      .fetch_stall(fetch_stall),
      .HaltSig(HaltSig),
      .instr(instr), 
      .PC_Next(PC_f),
      .IFID_instr(ID_instr),
      .err(IF_err)
   );

   /* IFID latch */
   IFID_latch IFID(
      .clk(clk),
      .rst(rst),
      .NOP_mech(NOP_mech),
      .NOP_Branch(NOP_Branch),
      .fetch_stall(fetch_stall),
      .IF_instr(instr),
      .IF_PC_Next(PC_f),
      .IFID_instr(ID_instr),
      .IFID_instr_comb(IFID_instr_comb),
      .IFID_PC_Next(ID_PC),
      .nHaltSig(1'b1 ? HaltSig : 1'b0),
      .IF_err(IF_err),
      .IFID_err(IDF_err)
   );

   stall_mech stall(
      .NOP_reg(NOP_mech), 
      .RSData(ID_instr[10:8]),
      .RTData(ID_instr[7:5]),
      .RD_ff(IDEX_RD),
      .RD_2ff(EXDM_RD), 
      .RegWrt_2ff(EXDM_RegWrt), 
      .RegWrt_ff(IDEX_RegWrt), 
      .Done_DM(Done_DM), 
      .takeRs_EXDM(takeRs_EXDM), 
      .takeRt_EXDM(takeRt_EXDM), 
      .takeRs_DMWB(takeRs_DMWB),
      .takeRt_DMWB(takeRt_DMWB),
      .IDEX_RegSrc(IDEX_RegSrc),
      .IDEX_RegWrt(IDEX_RegWrt),
      .EXDM_RegWrt(EXDM_RegWrt)
   );

   /* Decode Stage */
   decode decode0 (
      .clk(clk), 
      .rst(rst), 
      .NOP_Branch(NOP_Branch),
      .NOP(NOP),
      .NOP_mech(NOP_mech),
      .nHaltSig_comb(),
      .instr(ID_instr), 
      .instr_comb(IFID_instr_comb),
      .invA(invA),
      .invB(invB),
      .RegWrt(ID_RegWrt),
      .IDF_err(IDF_err),
      .DMWB_RD(DMWB_RD),
      .Cin(Cin),
      .RD(RD),
      .WB(WB), 
      .PC(ID_PC), 
      .valid(valid),
      .nHaltSig(HaltSig),
      .MemRead(MemRead),
      .ImmSrc(ImmSrc),
      .ALUSign(ALUSign),
      .ALUJmp(ALUJmp),
      .MemWrt(MemWrt),
      .RegSrc(RegSrc),
      .BSrc(BSrc),
      .BranchTaken(BranchTaken),
      .Oper(Oper),
      .err(ID_err), 
      .RSData(RSData), 
      .RTData(RTData), 
      .Imm5(Imm5), 
      .Imm8(Imm8), 
      .sImm8(sImm8), 
      .sImm11(sImm11), 
      .Rs(ID_Rs),
      .Rt(ID_Rt),
      .PC_Next(PC_d),
      .RD_2_nflopped(RD_2_nflopped),
      .RD_1_nflopped(RD_1_nflopped),
      .RegWrt_1_nflopped(RegWrt_1_nflopped),
      .RegWrt_2_nflopped(RegWrt_2_nflopped),
      .DMWB_RegWrt(DMWB_RegWrt),
      .Done_DM(Done_DM),
      .Done_DM_ff(Done_DM_ff)
   );

   /* IDEX latch */
   IDEX_latch IDEX (
      .clk(clk),
      .rst(rst),
      .valid(valid),
      // Control Signals
      .ID_nHaltSig(HaltSig),
      .ID_MemRead(MemRead),
      .ID_ImmSrc(ImmSrc),
      .ID_nHaltSig_comb(),
      .ID_ALUSign(ALUSign),
      .ID_ALUJmp(ALUJmp),
      .ID_MemWrt(MemWrt),
      .ID_err(ID_err),
      .ID_RegWrt(ID_RegWrt),
      .ID_Rs(ID_Rs),
      .ID_Rt(ID_Rt),
      // Register and Branch Controls
      .ID_RegSrc(RegSrc),
      .ID_BSrc(BSrc),
      .ID_BranchTaken(BranchTaken),

      // Inputs
      .ID_Oper(Oper),
      .ID_RSData(RSData),
      .ID_RTData(RTData),
      .ID_Imm5(Imm5),
      .ID_Imm8(Imm8),
      .ID_sImm8(sImm8),
      .ID_sImm11(sImm11),
      .ID_PC_Next(ID_PC),
      .ID_invA(invA),
      .ID_invB(invB),
      .ID_Cin(Cin),
      .ID_RD(RD),
      .ID_NOP(NOP_mech),
      .Done_DM(~Done_DM),

      // Outputs
      .IDEX_nHaltSig(IDEX_HaltSig),
      .IDEX_MemRead(IDEX_MemRead),
      .IDEX_ImmSrc(IDEX_ImmSrc),
      .IDEX_nHaltSig_comb(),
      .IDEX_ALUSign(IDEX_ALUSign),
      .IDEX_ALUJmp(IDEX_ALUJmp),
      .IDEX_MemWrt(IDEX_MemWrt),
      .IDEX_err(EX_err),
      .IDEX_RD(IDEX_RD),
      .IDEX_RegWrt(IDEX_RegWrt),

      // Register and Branch Controls
      .IDEX_RegSrc(IDEX_RegSrc),
      .IDEX_BSrc(IDEX_BSrc),
      .IDEX_BranchTaken(IDEX_BranchTaken),

      // Outputs
      .IDEX_Oper(IDEX_Oper),
      .IDEX_RSData(IDEX_RSData),
      .IDEX_RTData(IDEX_RTData),
      .IDEX_Imm5(IDEX_Imm5),
      .IDEX_Imm8(IDEX_Imm8),
      .IDEX_sImm8(IDEX_sImm8),
      .IDEX_sImm11(IDEX_sImm11),
      .IDEX_PC_Next(IDEX_PC_Next),
      .IDEX_invA(IDEX_invA),
      .IDEX_invB(IDEX_invB),
      .IDEX_Rs(IDEX_Rs),
      .IDEX_Rt(IDEX_Rt),
      .IDEX_Cin(IDEX_Cin),
      .IDEX_NOP(IDEX_NOP)
   );

   /* Execute Stage */
   execute execute0 (
      .clk(clk),
      .rst(rst),
      .NOP(IDEX_NOP), // Placeholder if NOP signal is needed
      .RSData(IDEX_RSData), 
      .RTData(IDEX_RTData), 
      .HaltSig(IDEX_HaltSig),
      .Oper(IDEX_Oper), 
      .PC(IDEX_PC_Next), 
      .Imm5(IDEX_Imm5), 
      .Imm8(IDEX_Imm8), 
      .sImm8(IDEX_sImm8), 
      .sImm11(IDEX_sImm11), 
      .BSrc(IDEX_BSrc), 
      .ImmSrc(IDEX_ImmSrc), 
      .ALUJmp(IDEX_ALUJmp), 
      .invA(IDEX_invA), 
      .invB(IDEX_invB), 
      .ALUSign(IDEX_ALUSign), 
      .cin(IDEX_Cin), 
      .BranchTaken(IDEX_BranchTaken), 
      .ALU_Out(EX_ALU),
      .ALU_RTData(ALU_RTData),
      .PC_Next(PC_Jump),
      .BrchCnd(BrchCnd),
      .EXDM_RD_Data(EXDM_RD_Data),
      .DMWB_RD_Data(DMWB_RD_Data),
      .A_Sel(A_Sel),
      .B_Sel(B_Sel)
   );

   forwarding fu (
      .EXDM_ALU(EXDM_ALU),
      .EXDM_PC(EXDM_PC),
      .DMWB_PC(DMWB_PC),
      .DMWB_ALU(DMWB_ALU),
      .DMWB_readData(DMWB_readData),
      .EXDM_RegSrc(EXDM_RegSrc),
      .DMWB_RegSrc(DMWB_RegSrc),
      .EXDM_RD_Data(EXDM_RD_Data),
      .EXDM_RTData(EXDM_RTData),
      .DMWB_RD_Data(DMWB_RD_Data),
      .A_Sel(A_Sel),
      .B_Sel(B_Sel),
      .takeRs_EXDM(takeRs_EXDM_ff),
      .takeRt_EXDM(takeRt_EXDM_ff),
      .takeRs_DMWB(takeRs_DMWB_ff),
      .takeRt_DMWB(takeRt_DMWB_ff)
   );

   /* EXDM latch */
   EXDM_latch EXDM (
      .clk(clk),
      .rst(rst),
      .EX_RTData(ALU_RTData),
      .EX_PC(IDEX_PC_Next),
      .EX_ALU(EX_ALU),
      .EX_MemWrt(IDEX_MemWrt),
      .EX_MemRead(IDEX_MemRead),
      .EX_nHaltSig(IDEX_HaltSig),
      .EX_RegWrt(IDEX_RegWrt),
      .EX_RD(IDEX_RD),
      .EX_RegSrc(IDEX_RegSrc),
      .EX_err(EX_err),
      .EXDM_err(FDM_err),
      .EXDM_RTData(EXDM_RTData),
      .EXDM_PC(EXDM_PC),
      .EXDM_MemWrt(EXDM_MemWrt),
      .EXDM_MemRead(EXDM_MemRead),
      .EXDM_ALU(EXDM_ALU),
      .EXDM_HaltSig(EXDM_HaltSig),
      .EXDM_RD(EXDM_RD),
      .EXDM_RegWrt(EXDM_RegWrt),
      .EXDM_RegSrc(EXDM_RegSrc),
      .Done_DM(Done_DM)
   );

   /* Memory Stage */
   memory memory0 (
      .clk(clk),
      .rst(rst),
      .ALU(EXDM_ALU), 
      .HaltSig(EXDM_HaltSig),
      .writeData(EXDM_RTData), 
      .readEn(EXDM_MemRead), 
      .MemWrt(EXDM_MemWrt), 
      .readData(readData),
      .err(DM_err),
      .Done_DM(Done_DM),
      .Stall_DM(Stall_DM),
      .CacheHit(CacheHit)
   );

   /* DMWB latch */
   DMWB_latch DMWB (
      .clk(clk),
      .rst(rst),
      .MEM_ALU(EXDM_ALU),
      .MEM_PC(EXDM_PC),
      .MEM_RegWrt(EXDM_RegWrt),
      .MEM_RD(EXDM_RD),
      .MEM_RegSrc(EXDM_RegSrc),
      .MEM_readData(readData),
      .FMEM_err(FDM_err),
      .MMEM_err(DM_err),
      .FWB_err(FWB_err),
      .DMWB_err(DMWB_err),
      .DMWB_ALU(DMWB_ALU),
      .DMWB_RegWrt(DMWB_RegWrt),
      .DMWB_RD(DMWB_RD),
      .DMWB_PC(DMWB_PC),
      .DMWB_readData(DMWB_readData),
      .DMWB_RegSrc(DMWB_RegSrc),
      .Done_DM(Done_DM)
   );

   /* Write-Back (WB) Stage */
   wb wb0 (
      .MemIn(DMWB_readData), 
      .PcIn(DMWB_PC), 
      .ALUIn(DMWB_ALU), 
      .FWB_err(FWB_err),
      .DMWB_err(DMWB_err),
      .RegSrc(DMWB_RegSrc), 
      .WB(WB),
      .WB_err(WB_err)
   );

   assign err = DM_err | WB_err;

endmodule // proc
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
