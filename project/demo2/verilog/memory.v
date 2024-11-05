/* 
    Author          : Abhinav Nandwani, Anna Huang
    Filename        : memory.v
    Description     : This module contains all components in the Memory stage of the processor.
*/
`default_nettype none
module memory (clk,rst, ALU, writeData, PC, readEn, MemWrt, readData,nHaltSig, ALU_ff, PC_Next);
    input wire [15:0] ALU, writeData, PC;
    input wire MemWrt,readEn,nHaltSig,clk,rst;
    output wire [15:0] readData, PC_Next, ALU_ff;

    wire [15:0] readData_nflopped;

    // Flop PC from D (to E to M) to WB
    register dff_d_PC2(.r(PC_Next), .w(PC), .clk(clk), .rst(rst), .we(1'b1));

    register dff_e_ALU2(.r(ALU_ff), .w(ALU), .clk(clk), .rst(rst), .we(1'b1));

    // Data Memory
    memory2c data_mem(.data_out(readData_nflopped), .data_in(writeData), .addr(ALU), .enable(MemWrt | readEn), .wr(MemWrt), .createdump(nHaltSig), .clk(clk), .rst(rst));

    // DFF for memory stage read data
    register dff_memory(.w(readData), .r(readData_nflopped), .clk(clk), .rst(rst), .we(1'b1));

endmodule
`default_nettype wire
