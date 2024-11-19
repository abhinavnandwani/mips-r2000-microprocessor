module EXDM_latch(
    input wire clk,
    input wire rst,
    input wire[15:0] EX_RTData,
    input wire[15:0] EX_PC,
    input wire[15:0] EX_ALU,
    input wire EX_MemWrt,
    input wire EX_MemRead,
    input wire EX_nHaltSig,
    input wire EX_RegWrt,
    input wire [2:0] EX_RD,
    input wire [1:0] EX_RegSrc,
    input wire EX_err,
    input wire Done_DM,
    output wire EXDM_err,
    output wire [15:0] EXDM_RTData,
    output wire [15:0] EXDM_PC,
    output wire [15:0] EXDM_ALU,
    output wire [2:0] EXDM_RD,
    output wire EXDM_MemWrt,
    output wire EXDM_MemRead,
    output wire EXDM_RegWrt,
    output wire EXDM_HaltSig,
    output wire [1:0] EXDM_RegSrc
);

    register rtdata_dff(.r(EXDM_RTData), .w(EX_RTData), .clk(clk), .rst(rst), .we(Done_DM));
    dff dff_EXDM_RegSrc[1:0] (.q(EXDM_RegSrc), .d(Done_DM ? EX_RegSrc : EXDM_RegSrc), .clk({2{clk}}), .rst({2{rst}})); 

    // DFF for decode stage PC signal
    register dff_d_PC2(.r(EXDM_PC), .w(EX_PC), .clk(clk), .rst(rst), .we(Done_DM));

    dff MemWrt_2dff(.q(EXDM_MemWrt), .d(Done_DM ? EX_MemWrt : EXDM_MemWrt), .clk(clk), .rst(rst)); // X to DM
    dff MemRead_2dff(.q(EXDM_MemRead), .d(Done_DM ? EX_MemRead : EXDM_MemRead), .clk(clk), .rst(rst)); // X to DM
    dff nHaltSig_2dff(.q(EXDM_HaltSig), .d(Done_DM ? EX_nHaltSig : EXDM_HaltSig), .clk(clk), .rst(rst)); // X to DM

    dff dff_EXDM_Rd [2:0] (.q(EXDM_RD), .d(Done_DM ? EX_RD : EXDM_RD), .clk({3{clk}}), .rst({3{rst}})); 
    

    // DFFs for execute stage signals
    register dff_e_ALU(.r(EXDM_ALU), .w(EX_ALU), .clk(clk), .rst(rst), .we(Done_DM));
    dff dff_EXDM_err (.q(EXDM_err), .d(EX_err), .clk(clk), .rst(rst)); 
    dff dff_EXDM_RegWrt (.q(EXDM_RegWrt), .d(Done_DM ? EX_RegWrt : EXDM_RegWrt), .clk(clk), .rst(rst)); 
endmodule