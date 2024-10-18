/*
   CS/ECE 552 Spring '22
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (clk, rst, PC_B, nHaltSig, instr, PC_Next);
   input clk, rst;
   input [15:0] PC_B; //PC from Branch/Jump Mux
   input nHaltSig;
   output [15:0] instr;
   output [15:0] PC_Next;



   wire [15:0] PC;
   wire err;
   wire [15:0] add2;
   wire c_out;

   // PC Register
   register pc_reg (.r(PC), .w(PC_B), .clk(clk), .rst(rst), .we(1'b1));

   // Instruction Memory
   memory2c instr_mem(.data_out(instr), .data_in(16'h0000), .addr(PC), .enable(nHaltSig), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));

   // Adder: PC + 2
   assign add2 = 16'h0002;
   cla_16b pc_add2 (.sum(PC_Next), .c_out(c_out), .a(PC), .b(add2), .c_in(1'b0));

   // Halt Mux
   assign PC_Next = (nHaltSig) ? PC_Next : PC;

endmodule
