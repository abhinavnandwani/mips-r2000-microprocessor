module stall_mech(
    output wire NOP_reg,
    input reg [2:0] RSData,
    input reg [2:0] RTData,
    input reg [2:0] RD_ff,
    input reg [2:0] RD_2ff,
    input wire RegWrt_2ff,
    input wire fetch_stall,
    input wire RegWrt_ff,
    input wire takeRs_DMWB,
    input wire takeRt_DMWB,
    input wire takeRs_EXDM,
    input wire takeRt_EXDM,
    input wire Done_DM
);

wire x,y,z,a;

assign x = (RD_ff ==  RSData ) ? (RegWrt_ff&~takeRs_EXDM):1'b0;
assign y = (RD_2ff ==  RSData ) ? (RegWrt_2ff&~takeRs_DMWB):1'b0;

assign z = (RD_ff ==  RTData ) ? (RegWrt_ff&~takeRt_EXDM):1'b0;
assign a = (RD_2ff ==  RTData ) ? (RegWrt_2ff&~takeRt_DMWB):1'b0;


assign NOP_reg = ~Done_DM | x | y | z | a;
    




endmodule