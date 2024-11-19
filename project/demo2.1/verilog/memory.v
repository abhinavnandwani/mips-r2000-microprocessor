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
    output wire Stall_DM
);


    wire done_mem;


    // Data Memory
    //memory2c_align data_mem(.data_out(readData), .data_in(writeData), .addr(ALU), .enable(MemWrt | readEn), .wr(MemWrt), .createdump(HaltSig), .clk(clk), .rst(rst), .err(err));
    stallmem data_mem(.DataOut(readData), .Done(done_mem), .Stall(Stall_DM), .CacheHit(), .DataIn(writeData), .Addr(ALU), .Rd(readEn), .Wr(MemWrt), .createdump(HaltSig), .clk(clk), .rst(rst), .err(err));

    assign Done_DM = done_mem | ~(readEn|MemWrt);

    // always@(posedge clk)

    //     $display("Fanum tax : %h",readData);





endmodule
