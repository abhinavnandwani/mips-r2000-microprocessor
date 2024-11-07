/* 
    Author          : Abhinav Nandwani, Anna Huang
    Filename        : fetch.v
    Description     : This is the overall module for the fetch state of the processor. 
*/

module fetch (clk, rst, NOP, nHalt_ff,PC_B,nHaltSig, instr, PC_Next,PC_curr, branch, branch_ff, ALUJmp, ALUJmp_ff);
   input clk, rst;
   input [15:0] PC_B; // The PC value "back" from the execute stage. 
   input nHaltSig,nHalt_ff, branch, branch_ff, ALUJmp, ALUJmp_ff;
   output [15:0] instr;
   output [15:0] PC_Next,PC_curr;
   output NOP;


   wire [15:0] PC,PC_regs;
   wire err;
   wire [15:0] add2,PC_Sum;
   wire c_out;

   // PC Register
   assign PC_regs = (branch_ff | ALUJmp_ff) ? PC_B:PC_Next;
   register pc_reg (.r(PC), .w(PC_regs), .clk(clk), .rst(rst), .we(1'b1));
   assign PC_curr = PC;
   
   // Instruction Memory
   memory2c instr_mem(.data_out(instr), .data_in(16'h0000), .addr(PC), .enable(1'b1), .wr(1'b0), .createdump(nHalt_ff), .clk(clk), .rst(rst));

   // Adder: PC + 2
   cla_16b pc_add2 (.sum(PC_Sum), .c_out(c_out), .a(PC), .b(16'h0002), .c_in(1'b0));
   
   // Halt Mux
   assign PC_Next = (nHaltSig | NOP ) ? PC : PC_Sum;


   always@(*) begin
    $display("branch: %d, branch_ff %d, alujmp %d, alujmp_ff: %d, PC_B: %d, PC: %d, PC_Next: %d", branch, branch_ff, ALUJmp, ALUJmp_ff, PC_B, PC, PC_Next);
   end
endmodule