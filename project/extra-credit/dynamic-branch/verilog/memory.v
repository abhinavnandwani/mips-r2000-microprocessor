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
    output wire [15:0] readData,
    output wire Done_DM, 
    output wire Stall_DM,
    output CacheHit
);
    wire done_mem;

    // Data Memory
    mem_system #(1) data_mem(.DataOut(readData), .Done(done_mem), .Stall(Stall_DM), .CacheHit(CacheHit), .err(), .Addr(ALU), .DataIn(writeData), .Rd(readEn), .Wr(MemWrt), .createdump(HaltSig), .clk(clk), .rst(rst));
    assign Done_DM = (done_mem) | ~(readEn|MemWrt);

endmodule
