module IFID_latch(
    input wire clk,
    input wire rst,
    input wire NOP_mech,
    input wire[15:0] IF_instr,
    input wire [15:0] IF_PC_Next,
    output wire [15:0] IFID_instr,
    output wire[15:0] IFID_PC_Next
);
    
    register dff_f_pc(.r(IFID_PC_Next), .w(IF_PC_Next), .clk(clk), .rst(rst), .we(1'b1));
    register dff_f_instr(.r(IFID_instr), .w(NOP_mech ? IFID_instr : IF_instr), .clk(clk), .rst(rst), .we(1'b1));

endmodule