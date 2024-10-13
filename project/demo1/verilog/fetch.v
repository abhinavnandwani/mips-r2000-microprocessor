/*
   CS/ECE 552 Spring '22
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
`default_nettype none
module fetch (/* TODO: Add appropriate inputs/outputs for your fetch stage here*/);
   input clk, rst;
   output [15:0] instr;
   output [15:0] PC_Next;

   wire nHaltSig;
   wire [15:0] PC_B;

   wire [15:0] PC;
   wire err;
   wire [15:0] add2;
   wire c_out;

   // PC Register NOT DONE
   regFile pc_reg (.read1Data(PC), .read2Data(), .err(err), .clk(clk), .rst(rst), .read1RegSel(3'b111), .read2RegSel(3'b000), .writeRegSel(), .writeData(PC_B), .writeEn(1'b1));

   // Instruction Memory
   memory2c instr_mem(.data_out(instr), .data_in(16'h0000), .addr(PC), .enable(nHaltSig), .wr(1'b0), .createdump(~nHaltSig), .clk(clk), .rst(rst));

   // Adder: PC + 2
   assign add2 = 16'h0002;
   cla_16b pc_add2 (.sum(PC_Next), .c_out(c_out), .a(PC), .b(add2), .c_in(1'b0));

   // Halt Mux
   assign PC_Next = (nHaltSig) ? PC_Next : PC;


endmodule
`default_nettype wire
