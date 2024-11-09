module IDEX_latch (
    input wire clk,
    input wire rst,

    // Control Signals
    input wire ID_nHaltSig,
    input wire ID_MemRead,
    input wire ID_ImmSrc,
    input wire ID_nHaltSig_comb,
    input wire ID_ALUSign,
    input wire ID_ALUJmp,
    input wire ID_MemWrt,
    input reg ID_err,
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
    input wire ID_invA,
    input wire ID_invB,
    input wire ID_Cin,
    input wire [2:0] ID_RD,
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
    output reg IDEX_err,
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
    output wire [2:0] IDEX_RD,
    output wire IDEX_NOP,
    output wire IDEX_RegWrt_2_nflopped,
    output wire IDEX_RegWrt_1_nflopped,
    output wire [2:0] IDEX_RD_2_nflopped,
    output wire [2:0] IDEX_RD_1_nflopped
);
    wire [1:0] IDEX_RegSrc_2_nflopped,IDEX_RegSrc_1_nflopped;
    dff dff_IDEX_RegSrc[5:0] (.q({IDEX_RegSrc, IDEX_RegSrc_2_nflopped, IDEX_RegSrc_1_nflopped}), .d({IDEX_RegSrc_2_nflopped, IDEX_RegSrc_1_nflopped, ID_RegSrc}), .clk({6{clk}}), .rst({6{rst}})); 
    dff dff_IDEX_BSrc[1:0] (.q(IDEX_BSrc), .d(ID_BSrc), .clk({2{clk}}), .rst({2{rst}})); 
    dff dff_IDEX_ImmSrc (.q(IDEX_ImmSrc), .d(ID_ImmSrc), .clk(clk), .rst(rst)); 
    dff dff_IDEX_ALUSign (.q(IDEX_ALUSign), .d(ID_ALUSign), .clk(clk), .rst(rst)); 
    dff dff_IDEX_ALUJmp (.q(IDEX_ALUJmp), .d(ID_ALUJmp), .clk(clk), .rst(rst)); 
    dff dff_IDEX_MemRead (.q(IDEX_MemRead), .d(ID_MemRead), .clk(clk), .rst(rst)); 
    dff dff_IDEX_MemWrt (.q(IDEX_MemWrt), .d(ID_MemWrt), .clk(clk), .rst(rst)); 
    dff dff_IDEX_nHaltSig (.q(IDEX_nHaltSig), .d(valid ? ID_nHaltSig : 1'b0), .clk(clk), .rst(rst)); 
    dff dff_IDEX_d_oper[3:0] (.q(IDEX_Oper), .d(ID_Oper), .clk({4{clk}}), .rst({4{rst}}));
    register dff_IDEX_d_RSData (.r(IDEX_RSData), .w(ID_RSData), .clk(clk), .rst(rst), .we(1'b1));
    register dff_IDEX_d_RTData (.r(IDEX_RTData), .w(ID_RTData), .clk(clk), .rst(rst), .we(1'b1));
    register dff_IDEX_d_Imm5 (.r(IDEX_Imm5), .w(ID_Imm5), .clk(clk), .rst(rst), .we(1'b1));
    register dff_IDEX_d_Imm8 (.r(IDEX_Imm8), .w(ID_Imm8), .clk(clk), .rst(rst), .we(1'b1));
    register dff_IDEX_d_sImm8 (.r(IDEX_sImm8), .w(ID_sImm8), .clk(clk), .rst(rst), .we(1'b1));
    register dff_IDEX_d_sImm11 (.r(IDEX_sImm11), .w(ID_sImm11), .clk(clk), .rst(rst), .we(1'b1));
    register dff_IDEX_d_PC (.r(IDEX_PC_Next), .w(ID_PC_Next), .clk(clk), .rst(rst), .we(1'b1));
    dff dff_IDEX_d_invA (.q(IDEX_invA), .d(ID_invA), .clk(clk), .rst(rst));
    dff dff_IDEX_d_invB (.q(IDEX_invB), .d(ID_invB), .clk(clk), .rst(rst));
    dff dff_IDEX_d_Cin (.q(IDEX_Cin), .d(ID_Cin), .clk(clk), .rst(rst));

endmodule
