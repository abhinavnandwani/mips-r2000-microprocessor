module DMWB_latch(
    input wire clk,
    input wire rst,
    input wire[15:0] MEM_ALU,
    input wire[15:0] MEM_PC,
    input wire[15:0] MEM_readData,
    input wire FMEM_err,
    input wire MMEM_err,
    input wire MEM_RegWrt,
    input wire [2:0] MEM_RD,
    input wire [1:0] MEM_RegSrc,
    input wire Done_DM,
    output wire FWB_err,
    output wire DMWB_err,
    output wire [15:0] DMWB_ALU,
    output wire [15:0] DMWB_PC,
    output wire DMWB_RegWrt,
    output wire[15:0] DMWB_readData,
    output wire [2:0] DMWB_RD,
    output wire [1:0] DMWB_RegSrc
);

    // Flop PC from D (to E to M) to WB
    register dff_d_PC2(.r(DMWB_PC), .w(MEM_PC), .clk(clk), .rst(rst), .we(1'b1));

    register dff_e_ALU2(.r(DMWB_ALU), .w(Done_DM ? MEM_ALU :DMWB_ALU ), .clk(clk), .rst(rst), .we(1'b1));
    
    // DFF for memory stage read data
    register dff_memory(.r(DMWB_readData), .w(MEM_readData), .clk(clk), .rst(rst), .we(1'b1));
    dff dff_FWB_err (.q(FWB_err), .d(FMEM_err), .clk(clk), .rst(rst)); 
    dff dff_DMWB_err (.q(DMWB_err), .d(MMEM_err), .clk(clk), .rst(rst)); 
    dff dff_DMWB_RegWrt (.q(DMWB_RegWrt), .d(Done_DM ? MEM_RegWrt : 1'b0), .clk(clk), .rst(rst)); 
    dff dff_DMWB_RD [2:0] (.q(DMWB_RD), .d(Done_DM ? MEM_RD : 3'b000), .clk({3{clk}}), .rst({3{rst}})); 
    dff dff_DMWVB_RegSrc[1:0] (.q(DMWB_RegSrc), .d(Done_DM ? MEM_RegSrc : DMWB_RegSrc), .clk({2{clk}}), .rst({2{rst}})); 
endmodule