/* 
    Author          : Abhinav Nandwani, Anna Huang
    Filename        : fetch.v
    Description     : This is the overall module for the fetch state of the processor. 
*/

module fetch (clk, rst, NOP, NOP_Branch, branch, PC_B, HaltSig, instr, PC_Next, PC_curr, IFID_instr,err);
    input clk, rst;
    input [15:0] PC_B; // The PC value "back" from the execute stage. 
    input [15:0] IFID_instr;
    input HaltSig, NOP, branch, NOP_Branch;
    output [15:0] instr;
    output [15:0] PC_Next,PC_curr;
    output err;


    wire [15:0] PC,PC_regs;
    wire err;
    wire [15:0] add2,PC_Sum,instr_memm;
    wire c_out;
    wire Stall,Done;

    // PC Register
    register pc_reg (.r(PC), .w(PC_Next), .clk(clk), .rst(rst), .we(1'b1));
    assign PC_curr = branch ? PC_B : PC;

    // Instruction Memory
    stallmem instr_mem(.DataOut(instr_memm), .Done(Done), .Stall(Stall), .CacheHit(), .DataIn(16'h0000), .Addr(PC_curr), .Rd(1'b1), .Wr(1'b0), .createdump(HaltSig), .clk(clk), .rst(rst), .err(err));

    assign instr = ~Done ? 16'h0800 : instr_memm;
    // Adder: PC + 2
    cla_16b pc_add2 (.sum(PC_Sum), .c_out(c_out), .a(PC_curr), .b(16'h0002), .c_in(1'b0));

    // Halt Mux
    assign PC_Next = (NOP | NOP_Branch | Stall) ? PC_curr : PC_Sum;

endmodule