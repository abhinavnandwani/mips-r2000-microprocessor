/* 
    Author          : Abhinav Nandwani, Anna Huang
    Filename        : decode.v
    Description     : This is the overall module for the decode stage of the processor. 
*/

module decode (
    // Clock and Reset
    input wire clk,
    input wire rst,

    // Instruction and Data Inputs
    input wire [15:0] instr,
    input wire [15:0] WB,
    input wire [15:0] PC,
    
    // Control Signals
    output wire nHaltSig,
    output wire MemRead,
    output wire ImmSrc,
    output wire nHaltSig_comb,
    output wire ALUSign,
    output wire ALUJmp,
    output wire MemWrt,
    output reg err,
    output wire RegWrt,

    // Register and Branch Controls
    output wire [1:0] RegSrc,
    output wire [1:0] BSrc,
    output wire [3:0] BranchTaken,

    // Outputs
    output wire [3:0] Oper,
    output wire [15:0] RSData,
    output wire [15:0] RTData,
    output wire [15:0] Imm5,
    output wire [15:0] Imm8,
    output wire [15:0] sImm8,
    output wire [15:0] sImm11,
    output wire [15:0] PC_Next,
    output wire invA,
    output wire invB,
    output wire Cin,
    output wire [2:0] RD,
    output wire NOP
);

    // Control Signals
    wire ZeroExt;
    wire RegWrt_nflopped;
    wire RegWrt_1_nflopped, RegWrt_2_nflopped;
    wire [5:0] ALUOpr;
    wire [1:0] RegDst;

    wire [1:0] RegSrc_nflopped, RegSrc_1_nflopped, RegSrc_2_nflopped;
    wire [1:0] BSrc_nflopped;
    wire [3:0] Oper_nflopped;
    wire [15:0] RSData_nflopped;
    wire [15:0] RTData_nflopped;
    wire [15:0] Imm5_nflopped;
    wire [15:0] Imm8_nflopped;
    wire [15:0] sImm8_nflopped;
    wire [15:0] sImm11_nflopped;
    wire invA_nflopped;
    wire invB_nflopped;
    wire Cin_nflopped;
    wire [2:0] RD_nflopped, RD_1_nflopped, RD_2_nflopped;
    wire MemRead_nflopped;
    wire ImmSrc_nflopped;
    wire ALUSign_nflopped;
    wire ALUJmp_nflopped;
    wire MemWrt_nflopped,nHaltSig_nflopped;
    wire NOP_mech, NOP_comb;

    // Register File
    assign RD_nflopped = (RegDst == 2'b00) ? instr[7:5] :
                         (RegDst == 2'b01) ? instr[10:8] :
                         (RegDst == 2'b10) ? instr[4:2] :
                         3'b111;

    // Triple-flopped RD
    dff dff_RD[8:0](.q({RD, RD_2_nflopped, RD_1_nflopped}), .d({RD_2_nflopped, RD_1_nflopped, RD_nflopped}), .clk({9{clk}}), .rst({9{rst}}));

    regFile_bypass regFile0 (.read1Data(RSData_nflopped), .read2Data(RTData_nflopped), .err(), .clk(clk), .rst(rst), .read1RegSel(instr[10:8]), .read2RegSel(instr[7:5]), .writeRegSel(RD), .writeData(WB), .writeEn(RegWrt));

    // Sign Extension
    assign Imm5_nflopped = (ZeroExt) ? {11'h000, instr[4:0]} : {{11{instr[4]}}, instr[4:0]};
    assign sImm8_nflopped = {{8{instr[7]}}, instr[7:0]};
    assign Imm8_nflopped = (ZeroExt) ? {8'h00, instr[7:0]} : sImm8_nflopped;
    assign sImm11_nflopped = {{5{instr[10]}}, instr[10:0]};
    assign nHaltSig_comb = nHaltSig_nflopped;

    alu_control aluc (.aluoper(ALUOpr), .instr(instr[1:0]), .op(Oper_nflopped), .invA(invA_nflopped), .invB(invB_nflopped), .Cin(Cin_nflopped));
    

   // always@(posedge clk, posedge rst)
     //   if (rst)
       //     {RegWrt,RegWrt_2_nflopped,RegWrt_1_nflopped} <= 3'b0;
        //else
          //   {RegWrt,RegWrt_2_nflopped,RegWrt_1_nflopped} <=  {RegWrt_2_nflopped,RegWrt_1_nflopped,RegWrt_nflopped}; 

   dff dff_d_RegWrt[2:0](.q({RegWrt, RegWrt_2_nflopped, RegWrt_1_nflopped}), .d({RegWrt_2_nflopped, RegWrt_1_nflopped, RegWrt_nflopped}), .clk({clk,clk,clk}), .rst({rst,rst,rst}));
    control control0 (.instr(NOP_mech ? 16'h0Axx : instr), .err(), .NOP(NOP_comb), .nHaltSig(nHaltSig_nflopped), .MemRead(MemRead_nflopped), .RegDst(RegDst), .RegWrt(RegWrt_nflopped), .ZeroExt(ZeroExt), .BSrc(BSrc_nflopped), .ImmSrc(ImmSrc_nflopped), .ALUOpr(ALUOpr), .ALUSign(ALUSign_nflopped), .ALUJmp(ALUJmp_nflopped), .MemWrt(MemWrt_nflopped), .RegSrc(RegSrc_nflopped), .BranchTaken(BranchTaken));
    assign NOP = NOP_comb;

    dff dff_RegSrc[5:0](.q({RegSrc, RegSrc_2_nflopped, RegSrc_1_nflopped}), .d({RegSrc_2_nflopped, RegSrc_1_nflopped, RegSrc_nflopped}), .clk({6{clk}}), .rst({6{rst}})); 
    dff dff_BSrc[1:0](.q(BSrc), .d(BSrc_nflopped), .clk({2{clk}}), .rst({2{rst}})); 
    dff dff_ImmSrc(.q(ImmSrc), .d(ImmSrc_nflopped), .clk(clk), .rst(rst)); 
    dff dff_ALUSign(.q(ALUSign), .d(ALUSign_nflopped), .clk(clk), .rst(rst)); 
    dff dff_ALUJmp(.q(ALUJmp), .d(ALUJmp_nflopped), .clk(clk), .rst(rst)); 
    dff dff_MemRead(.q(MemRead), .d(MemRead_nflopped), .clk(clk), .rst(rst)); 
    dff dff_MemWrt(.q(MemWrt), .d(MemWrt_nflopped), .clk(clk), .rst(rst)); 

    dff dff_nHaltSig(.q(nHaltSig), .d(nHaltSig_nflopped), .clk(clk), .rst(rst)); 

    dff dff_d_oper[3:0](.q(Oper), .d(Oper_nflopped), .clk({4{clk}}), .rst({4{rst}}));

    register dff_d_RSData(.r(RSData), .w(RSData_nflopped), .clk(clk), .rst(rst), .we(1'b1));
    register dff_d_RTData(.r(RTData), .w(RTData_nflopped), .clk(clk), .rst(rst), .we(1'b1));
    register dff_d_Imm5(.r(Imm5), .w(Imm5_nflopped), .clk(clk), .rst(rst), .we(1'b1));
    register dff_d_Imm8(.r(Imm8), .w(Imm8_nflopped), .clk(clk), .rst(rst), .we(1'b1));
    register dff_d_sImm8(.r(sImm8), .w(sImm8_nflopped), .clk(clk), .rst(rst), .we(1'b1));
    register dff_d_sImm11(.r(sImm11), .w(sImm11_nflopped), .clk(clk), .rst(rst), .we(1'b1));
    register dff_d_PC(.r(PC_Next), .w(PC), .clk(clk), .rst(rst), .we(1'b1));

    dff dff_d_invA(.q(invA), .d(invA_nflopped), .clk(clk), .rst(rst));
    dff dff_d_invB(.q(invB), .d(invB_nflopped), .clk(clk), .rst(rst));
    dff dff_d_Cin(.q(Cin), .d(Cin_nflopped), .clk(clk), .rst(rst));

    stall_mech stall(.NOP_reg(NOP_mech), .RSData(instr[10:8]),.RTData(instr[7:5]),.RD_ff(RD_1_nflopped),.RD_2ff(RD_2_nflopped), .RegWrt_2ff(RegWrt_2_nflopped), .RegWrt_ff(RegWrt_1_nflopped));

endmodule
