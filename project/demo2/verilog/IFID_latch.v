module IFID_latch(
    input wire clk,
    input wire rst,
    input wire NOP_mech,
    input wire[15:0] IF_instr,
    input wire [15:0] IF_PC_Next,
    output wire [15:0] IFID_instr,
    output wire[15:0] IFID_PC_Next,
    input wire NOP_Branch,
    output wire [15:0] IFID_instr_comb
);
    wire [15:0] IFID_instr_branch;

    wire x;
    assign #100 x = NOP_Branch;
    assign IFID_instr_branch = (NOP_Branch) ? 16'b0000_1000_0000_0000 : IF_instr;
    assign IFID_instr_comb = (NOP_mech) ? IFID_instr : IFID_instr_branch;
    register dff_f_pc(.r(IFID_PC_Next), .w(IF_PC_Next), .clk(clk), .rst(rst), .we(1'b1));
    register dff_f_instr(.r(IFID_instr), .w(IFID_instr_comb), .clk(clk), .rst(rst), .we(1'b1));

endmodule