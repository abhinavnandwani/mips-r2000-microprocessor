/*
   CS/ECE 552 Spring '22
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/

module memory (ALU, writeData, nHaltSig, MemWrt, readData);
   input [15:0] ALU, writeData;
   input nHaltSig;
   input MemWrt;
   output [15:0] readData;

   // Data Memory
   memory2c data_mem(.data_out(readData), .data_in(writeData), .addr(ALU), .enable(nHaltSig), .wr(MemWrt), .createdump(1'b0), .clk(clk), .rst(rst));
   
endmodule

