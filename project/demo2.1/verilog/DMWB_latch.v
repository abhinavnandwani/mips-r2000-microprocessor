module DMWB_latch(
    input wire clk,
    input wire rst,
    input wire[15:0] MEM_ALU,
    input wire[15:0] MEM_PC,
    input wire[15:0] MEM_readData,
    output wire [15:0] DMWB_ALU,
    output wire [15:0] DMWB_PC,
    output wire[15:0] DMWB_readData
);

    // Flop PC from D (to E to M) to WB
    register dff_d_PC2(.r(DMWB_PC), .w(MEM_PC), .clk(clk), .rst(rst), .we(1'b1));

    register dff_e_ALU2(.r(DMWB_ALU), .w(MEM_ALU), .clk(clk), .rst(rst), .we(1'b1));
    // DFF for memory stage read data
    register dff_memory(.r(DMWB_readData), .w(MEM_readData), .clk(clk), .rst(rst), .we(1'b1));

endmodule