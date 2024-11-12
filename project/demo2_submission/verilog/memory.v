/* 
    Author          : Abhinav Nandwani, Anna Huang
    Filename        : memory.v
    Description     : This module contains all components in the Memory stage of the processor.
*/

module memory (
    input wire clk,
    input wire rst,
    input wire [15:0] ALU,
    input wire [15:0] writeData,
    input wire readEn,
    input wire MemWrt,
    input wire HaltSig,
    output wire [15:0] readData
);

    // Data Memory
    memory2c data_mem(.data_out(readData), .data_in(writeData), .addr(ALU), .enable(MemWrt | readEn), .wr(MemWrt), .createdump(HaltSig), .clk(clk), .rst(rst));
endmodule
