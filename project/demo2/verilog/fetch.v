/* 
    Author          : Abhinav Nandwani, Anna Huang
    Filename        : fetch.v
    Description     : This is the overall module for the fetch state of the processor. 
*/

module fetch (clk, rst, NOP, NOP_Branch, branch, PC_B,nHaltSig, instr, PC_Next,PC_curr);
   input clk, rst;
   input [15:0] PC_B; // The PC value "back" from the execute stage. 
   input nHaltSig, NOP, branch, NOP_Branch;
   output [15:0] instr;
   output [15:0] PC_Next,PC_curr;


   wire [15:0] PC,PC_regs;
   wire err;
   wire [15:0] add2,PC_Sum;
   wire c_out;
   wire x,y;

   assign #100 x = NOP_Branch;
   assign y = branch ? NOP_Branch : (NOP_Branch^x);


   // PC Register
   //assign PC_regs = () ? PC_B : PC;
   register pc_reg (.r(PC), .w(PC_Next), .clk(clk), .rst(rst), .we(1'b1));
   assign PC_curr = PC;
   
   // Instruction Memory
   memory2c instr_mem(.data_out(instr), .data_in(16'h0000), .addr(branch ? PC_B : PC), .enable(1'b1), .wr(1'b0), .createdump(nHaltSig), .clk(clk), .rst(rst));

   // Adder: PC + 2

   cla_16b pc_add2 (.sum(PC_Sum), .c_out(c_out), .a(branch ? PC_B : PC), .b(16'h0002), .c_in(1'b0));
   
   // Halt Mux
   assign PC_Next = (NOP | NOP_Branch) ? PC : PC_Sum;

      always @(*) begin
        $display("PC %h, PC_Next %h, Inst: %h, NOP_Branch %d, BrchCnd %d", PC, PC_B, instr, NOP_Branch, branch);
   end

endmodule