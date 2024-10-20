/*
   CS/ECE 552 Spring '22
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/

module memory (ALU, writeData, readEn, MemWrt, readData,nHaltSig);
   input wire [15:0] ALU, writeData;
   input wire MemWrt,readEn,nHaltSig;
   output wire [15:0] readData;

   // Data Memory
   memory2c data_mem(.data_out(readData), .data_in(writeData), .addr(ALU), .enable(MemWrt | MemRead), .wr(MemWrt), .createdump(!nHaltSig), .clk(clk), .rst(rst));
   
endmodule

