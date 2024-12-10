/*
   CS/ECE 552 Spring '22
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/

module wb (MemIn, PcIn, ALUIn, RegSrc, WB, FWB_err, DMWB_err, WB_err);
   input [15:0] MemIn, PcIn, ALUIn;
   input [1:0] RegSrc;
   input FWB_err;
   input DMWB_err;

   output WB_err;
   output [15:0] WB;

   assign WB = (RegSrc == 2'b00) ? PcIn : (RegSrc == 2'b01) ? MemIn : ALUIn;
   assign WB_err = FWB_err | DMWB_err;
   
endmodule

