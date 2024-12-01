module forwarding_unit(
    input wire [2:0] RD_EXDM,
    input wire [2:0] RD_DMWB,
    input wire [1:0] B_Src,
    input wire [2:0] Rs,
    input wire [2:0] Rt,
    input wire [15:0] EXDM_ALU,
    input wire [15:0] EXDM_PC,
    input wire [15:0] DMWB_PC,
    input wire [15:0] DMWB_ALU,
    input wire [15:0] DMWB_readData,
    input wire [1:0] DMWB_RegSrc,
    input wire [1:0] EXDM_RegSrc,
    input wire DMWB_RegWrt,
    input wire EXDM_RegWrt,
    output [1:0] A_Sel,
    output [1:0] B_Sel,
    output wire [15:0] EXDM_RD_Data,
    output wire [15:0] DMWB_RD_Data,
    output wire takeRs_EXDM,
    output wire takeRt_EXDM,
    output wire takeRs_DMWB,
    output wire takeRt_DMWB
);

    // Data selection logic
    assign EXDM_RD_Data = (EXDM_RegSrc == 2'b00) ? EXDM_PC : 
                          (EXDM_RegSrc == 2'b10) ? EXDM_ALU : 16'h0000;

    assign DMWB_RD_Data = (DMWB_RegSrc == 2'b00) ? DMWB_PC : 
                          (DMWB_RegSrc == 2'b10) ? DMWB_ALU : 
                          (DMWB_RegSrc == 2'b01) ? DMWB_readData : 16'h0000;

    // `take` signals for forwarding decisions
    assign takeRs_EXDM = (RD_EXDM == Rs) ? ((EXDM_RegSrc != 2'b01) ? EXDM_RegWrt : 1'b0) : 1'b0;
    assign takeRt_EXDM = (RD_EXDM == Rt) ? ((EXDM_RegSrc != 2'b01) ? EXDM_RegWrt : 1'b0) : 1'b0;
    assign takeRs_DMWB = (RD_DMWB == Rs) ? (DMWB_RegWrt) : 1'b0;
    assign takeRt_DMWB = (RD_DMWB == Rt) ? (DMWB_RegWrt) : 1'b0;

    // Selection logic for A and B
    assign A_Sel = (takeRs_EXDM) ? 2'b01 :
                   (takeRs_DMWB) ? 2'b10 :
                   2'b00;

    assign B_Sel = (takeRt_EXDM) ? 2'b01 :
                   (takeRt_DMWB) ? 2'b10 :
                   2'b00;

endmodule
