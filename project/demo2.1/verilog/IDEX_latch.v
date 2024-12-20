module IDEX_latch (
    input wire clk,
    input wire rst,

    // Control Signals
    input wire ID_nHaltSig,
    input wire ID_MemRead,
    input wire Done_DM,
    input wire ID_ImmSrc,
    input wire ID_nHaltSig_comb,
    input wire ID_ALUSign,
    input wire ID_ALUJmp,
    input wire ID_MemWrt,
    input wire ID_err,
    input wire ID_RegWrt,
    input wire valid,

    // Register and Branch Controls
    input wire [1:0] ID_RegSrc,
    input wire [1:0] ID_BSrc,
    input wire [3:0] ID_BranchTaken,

    // Inputs
    input wire [3:0] ID_Oper,
    input wire [15:0] ID_RSData,
    input wire [15:0] ID_RTData,
    input wire [15:0] ID_Imm5,
    input wire [15:0] ID_Imm8,
    input wire [15:0] ID_sImm8,
    input wire [15:0] ID_sImm11,
    input wire [15:0] ID_PC_Next,
    input wire [2:0] ID_RD,
    input wire ID_invA,
    input wire ID_invB,
    input wire ID_Cin,
    input wire ID_NOP,
    input wire ID_RegWrt_2_nflopped,
    input wire ID_RegWrt_1_nflopped,
    input wire [2:0] ID_RD_2_nflopped,
    input wire [2:0] ID_RD_1_nflopped,

    // Outputs
    output wire IDEX_nHaltSig,
    output wire IDEX_MemRead,
    output wire IDEX_ImmSrc,
    output wire IDEX_nHaltSig_comb,
    output wire IDEX_ALUSign,
    output wire IDEX_ALUJmp,
    output wire IDEX_MemWrt,
    output wire [2:0] IDEX_RD,
    output wire IDEX_err,
    output wire IDEX_RegWrt,

    // Register and Branch Controls
    output wire [1:0] IDEX_RegSrc,
    output wire [1:0] IDEX_BSrc,
    output wire [3:0] IDEX_BranchTaken,

    // Outputs
    output wire [3:0] IDEX_Oper,
    output wire [15:0] IDEX_RSData,
    output wire [15:0] IDEX_RTData,
    output wire [15:0] IDEX_Imm5,
    output wire [15:0] IDEX_Imm8,
    output wire [15:0] IDEX_sImm8,
    output wire [15:0] IDEX_sImm11,
    output wire [15:0] IDEX_PC_Next,
    output wire IDEX_invA,
    output wire IDEX_invB,
    output wire IDEX_Cin,
    output wire IDEX_NOP
);
    dff dff_IDEX_RegSrc[1:0] (.q(IDEX_RegSrc), .d(Done_DM ? IDEX_RegSrc : ID_RegSrc), .clk({2{clk}}), .rst({2{rst}})); 
    dff dff_IDEX_BSrc[1:0] (.q(IDEX_BSrc), .d(Done_DM ? IDEX_BSrc : ID_BSrc), .clk({2{clk}}), .rst({2{rst}})); 
    dff dff_IDEX_ImmSrc (.q(IDEX_ImmSrc), .d(Done_DM ? IDEX_ImmSrc : ID_ImmSrc), .clk(clk), .rst(rst)); 
    dff dff_IDEX_ALUSign (.q(IDEX_ALUSign), .d(Done_DM ? IDEX_ALUSign : ID_ALUSign), .clk(clk), .rst(rst)); 
    dff dff_IDEX_ALUJmp (.q(IDEX_ALUJmp), .d(Done_DM ? IDEX_ALUJmp : ID_ALUJmp), .clk(clk), .rst(rst)); 
    dff dff_IDEX_MemRead (.q(IDEX_MemRead), .d(Done_DM ? IDEX_MemRead : ID_MemRead), .clk(clk), .rst(rst)); 
    dff dff_IDEX_MemWrt (.q(IDEX_MemWrt), .d(Done_DM ? IDEX_MemWrt : ID_MemWrt), .clk(clk), .rst(rst)); 
    dff dff_IDEX_rd [2:0] (.q(IDEX_RD), .d(Done_DM ? IDEX_RD : ID_RD), .clk({3{clk}}), .rst({3{rst}})); 
    dff dff_IDEX_nHaltSig (.q(IDEX_nHaltSig), .d(Done_DM ? IDEX_nHaltSig : (valid ? ID_nHaltSig : 1'b0)), .clk(clk), .rst(rst)); 
    dff dff_IDEX_d_oper[3:0] (.q(IDEX_Oper), .d(Done_DM ? IDEX_Oper : ID_Oper), .clk({4{clk}}), .rst({4{rst}}));
    register dff_IDEX_d_RSData (.r(IDEX_RSData), .w(Done_DM ? IDEX_RSData : ID_RSData), .clk(clk), .rst(rst), .we(1'b1));
    register dff_IDEX_d_RTData (.r(IDEX_RTData), .w(Done_DM ? IDEX_RTData : ID_RTData), .clk(clk), .rst(rst), .we(1'b1));
    register dff_IDEX_d_Imm5 (.r(IDEX_Imm5), .w(Done_DM ? IDEX_Imm5 : ID_Imm5), .clk(clk), .rst(rst), .we(1'b1));
    register dff_IDEX_d_Imm8 (.r(IDEX_Imm8), .w(Done_DM ? IDEX_Imm8 : ID_Imm8), .clk(clk), .rst(rst), .we(1'b1));
    register dff_IDEX_d_sImm8 (.r(IDEX_sImm8), .w(Done_DM ? IDEX_sImm8 : ID_sImm8), .clk(clk), .rst(rst), .we(1'b1));
    register dff_IDEX_d_sImm11 (.r(IDEX_sImm11), .w(Done_DM ? IDEX_sImm11 : ID_sImm11), .clk(clk), .rst(rst), .we(1'b1));
    register dff_IDEX_d_PC (.r(IDEX_PC_Next), .w(Done_DM ? IDEX_PC_Next : ID_PC_Next), .clk(clk), .rst(rst), .we(1'b1));
    dff dff_IDEX_d_invA (.q(IDEX_invA), .d(Done_DM ? IDEX_invA : ID_invA), .clk(clk), .rst(rst));
    dff dff_IDEX_d_invB (.q(IDEX_invB), .d(Done_DM ? IDEX_invB : ID_invB), .clk(clk), .rst(rst));
    dff dff_IDEX_d_Cin (.q(IDEX_Cin), .d(Done_DM ? IDEX_Cin : ID_Cin), .clk(clk), .rst(rst));
    dff dff_IDEX_d_BranchTaken [3:0] (.q(IDEX_BranchTaken), .d(Done_DM ? IDEX_BranchTaken : ID_BranchTaken), .clk({4{clk}}), .rst({4{rst}}));
    dff dff_IDEX_NOP (.q(IDEX_NOP), .d(Done_DM ? IDEX_NOP : ID_NOP), .clk(clk), .rst(rst)); 
    dff dff_IDEX_err (.q(IDEX_err), .d(Done_DM ? IDEX_err : ID_err), .clk(clk), .rst(rst)); 
    dff dff_IDEX_RegWrt (.q(IDEX_RegWrt), .d(Done_DM ? IDEX_RegWrt : ID_RegWrt), .clk(clk), .rst(rst)); 

endmodule
