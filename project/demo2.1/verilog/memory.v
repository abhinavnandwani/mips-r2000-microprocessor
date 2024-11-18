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
    output wire err,
    output wire [15:0] readData
);

    // Data Memory
    stallmem data_mem(.DataOut(readData), .Done(), .Stall(), .CacheHit(), .DataIn(writeData), .Addr(ALU), .Rd(readEn), .Wr(MemWrt), .createdump(HaltSig), .clk(clk), .rst(rst), .err(err));

endmodule
