
module stall_mech(
    output NOP_reg,
    input [2:0] RSData,
    input [2:0] RTData,
    input [2:0] RD_ff,
    input [2:0] RD_2ff,
    input [1:0] IDEX_RegSrc,
    input IDEX_RegWrt,
    input EXDM_RegWrt,
    input RegWrt_2ff,
    input RegWrt_ff,
    output takeRs_DMWB,
    output takeRt_DMWB,
    output takeRs_EXDM,
    output takeRt_EXDM,
    input Done_DM
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

