module stall_mech(
    output wire NOP_reg,
    input reg [2:0] RSData,
    input reg [2:0] RTData,
    input reg [2:0] RD_ff,
    input reg [2:0] RD_2ff,
    input wire [1:0] IDEX_RegSrc,
    input wire IDEX_RegWrt,
    input wire EXDM_RegWrt,
    input wire RegWrt_2ff,
    input wire RegWrt_ff,
    output wire takeRs_DMWB,
    output wire takeRt_DMWB,
    output wire takeRs_EXDM,
    output wire takeRt_EXDM,
    input wire Done_DM
);

    wire Rs_EXDM, Rs_DMWB, Rt_EXDM, Rt_DMWB;

    assign takeRs_EXDM = (IDEX_RegSrc != 2'b01) & IDEX_RegWrt & (RD_ff == RSData);
    assign takeRt_EXDM = (IDEX_RegSrc != 2'b01) & IDEX_RegWrt & (RD_ff == RTData);

    assign takeRs_DMWB = EXDM_RegWrt & (RD_2ff == RSData);
    assign takeRt_DMWB = EXDM_RegWrt & (RD_2ff == RTData);

    // Hazard detection logic
    assign Rs_EXDM = (RD_ff == RSData) ? (RegWrt_ff & ~takeRs_EXDM) : 1'b0;
    assign Rs_DMWB = (RD_2ff == RSData) ? (RegWrt_2ff & ~takeRs_DMWB) : 1'b0;
    assign Rt_EXDM = (RD_ff == RTData) ? (RegWrt_ff & ~takeRt_EXDM) : 1'b0;
    assign Rt_DMWB = (RD_2ff == RTData) ? (RegWrt_2ff & ~takeRt_DMWB) : 1'b0;

    // Stall logic
    assign NOP_reg = ~Done_DM | Rs_EXDM | Rs_DMWB | Rt_EXDM | Rt_DMWB;

endmodule