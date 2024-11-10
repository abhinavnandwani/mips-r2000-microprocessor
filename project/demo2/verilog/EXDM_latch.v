module EXDM_latch(
    input wire clk,
    input wire rst,
    input wire[15:0] EX_RTData,
    input wire[15:0] EX_PC,
    input wire EX_MemWrt,
    input wire EX_MemRead,
    input wire EX_nHaltSig,
    output wire [15:0] EXDM_RTData,
    output wire [15:0] EXDM_PC,
    output wire EXDM_MemWrt,
    output wire EXDM_MemRead,
    output wire EXDM_HaltSig
);

    register rtdata_dff(.r(EXDM_RTData), .w(EX_RTData), .clk(clk), .rst(rst), .we(1'b1));

    // DFF for decode stage PC signal
    register dff_d_PC2(.r(EXDM_PC), .w(EX_PC), .clk(clk), .rst(rst), .we(1'b1));

    dff MemWrt_2dff(.q(EXDM_MemWrt), .d(EX_MemWrt), .clk(clk), .rst(rst)); // X to DM
    dff MemRead_2dff(.q(EXDM_MemRead), .d(EX_MemRead), .clk(clk), .rst(rst)); // X to DM
    dff nHaltSig_2dff(.q(EXDM_HaltSig), .d(EX_nHaltSig), .clk(clk), .rst(rst)); // X to DM

endmodule