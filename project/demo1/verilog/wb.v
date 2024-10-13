/*
   CS/ECE 552 Spring '22
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
`default_nettype none
module wb (MemIn, PcIn, AluIn, SpecIn, RegSrc, WB);
   input [1:0] RegSrc;
   input [15:0] MemIn, PcIn, AluIn, SpecIn;
   
   output [15:0] WB;

   assign WB = (RegSrc == 2'b11) ? SpecIn : (RegSrc == 2'b10) ? AluIn : (RegSrc == 2'b01) ? MemIn : PcIn;
   
endmodule
`default_nettype wire
