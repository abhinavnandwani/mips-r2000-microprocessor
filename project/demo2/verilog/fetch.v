/* 
    Author          : Abhinav Nandwani, Anna Huang
    Filename        : fetch.v
    Description     : This is the overall module for the fetch state of the processor. 
*/

module fetch (clk, rst, PC_B,nHaltSig, instr, PC_Next,PC_curr);
   input clk, rst;
   input [15:0] PC_B; // The PC value "back" from the execute stage. 
   input nHaltSig;
   output [15:0] instr;
   output [15:0] PC_Next,PC_curr;


   wire [15:0] PC,PC_regs, PC_Next_nflopped, instr_nflopped;
   wire err;
   wire [15:0] add2,PC_Sum;
   wire c_out;

   // PC Register
   assign PC_regs = (1'b0) ? PC_B:PC_Sum;
   register pc_reg (.r(PC), .w(PC_regs), .clk(clk), .rst(rst), .we(1'b1));
   assign PC_curr = PC;
   
   // Instruction Memory
   memory2c instr_mem(.data_out(instr_nflopped), .data_in(16'h0000), .addr(PC), .enable(1'b1), .wr(1'b0), .createdump(~nHaltSig), .clk(clk), .rst(rst));

   // Adder: PC + 2

   cla_16b pc_add2 (.sum(PC_Sum), .c_out(c_out), .a(PC), .b(16'h0002), .c_in(1'b0));
   
   // Halt Mux
   assign PC_Next_nflopped =  (!nHaltSig) ? PC:PC_Sum;
endmodule
