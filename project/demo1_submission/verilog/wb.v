/*
   CS/ECE 552 Spring '22
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/

module wb (MemIn, PcIn, ALUIn, RegSrc, WB);
   input [15:0] MemIn, PcIn, ALUIn;
   input [1:0] RegSrc;
   
   output [15:0] WB;

   assign WB = (RegSrc == 2'b00) ? PcIn : (RegSrc == 2'b01) ? MemIn : ALUIn;
   
endmodule

