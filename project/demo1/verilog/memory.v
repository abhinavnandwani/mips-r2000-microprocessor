/*
   CS/ECE 552 Spring '22
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
`default_nettype none
module memory (/* TODO: Add appropriate inputs/outputs for your memory stage here*/);
   input [15:0] ALU;
   input [15:0] writeData;
   output [15:0] readData;
   wire MemWrt;

   // Data Memory NOT DONE
   memory2c data_mem(.data_out(readData), .data_in(writeData), .addr(ALU), .enable(nHaltSig), .wr(MemWrt), .createdump(~nHaltSig), .clk(clk), .rst(rst));
   
endmodule
`default_nettype wire
