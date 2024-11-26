/* 
    Author          : Abhinav Nandwani, Anna Huang
    Filename        : fetch.v
    Description     : This is the overall module for the fetch state of the processor. 
*/

module fetch (clk, rst, NOP, NOP_Branch, branch, PC_B, HaltSig, instr, PC_Next, PC_curr, IFID_instr,err,fetch_stall);
    input clk, rst;
    input [15:0] PC_B; // The PC value "back" from the execute stage. 
    input [15:0] IFID_instr;
    input HaltSig, NOP, branch, NOP_Branch;
    output [15:0] instr;
    output [15:0] PC_Next,PC_curr;
    output err;
    output fetch_stall;


    wire [15:0] PC,PC_regs;
    wire err;
    wire [15:0] add2,PC_Sum,instr_memm, instr_ff;
    wire c_out;
    wire Stall,Done, done_ff,Stall_M;

    // PC Register
    register pc_reg (.r(PC), .w(PC_Next), .clk(clk), .rst(rst), .we(1'b1));
    assign PC_curr = branch ? PC_B : PC;
    assign done_ff = Done;

    // Instruction Memory
   stallmem instr_mem(.DataOut(instr_memm), .Done(Done), .Stall(Stall), .CacheHit(), .DataIn(16'h0000), .Addr(PC_curr), .Rd(1'b1), .Wr(1'b0), .createdump(HaltSig), .clk(clk), .rst(rst), .err(err));
   // mem_system instr_mem(.DataOut(instr_memm), .Done(Done), .Stall(Stall), .CacheHit(CacheHit), .err(err), .Addr(PC_curr), .DataIn(16'h0000), .Rd(1'b1), .Wr(1'b0), .createdump(HaltSig), .clk(clk), .rst(rst));
    assign instr = (1'b0) ? 16'h0800 : instr_memm;

    // Adder: PC + 2
    cla_16b pc_add2 (.sum(PC_Sum), .c_out(c_out), .a(PC_curr), .b(16'h0002), .c_in(1'b0));

    // Halt Mux
    assign PC_Next = (NOP | NOP_Branch | fetch_stall ) ? PC_curr : PC_Sum;
    assign fetch_stall = ~done_ff;

    // always @(posedge clk) begin
    //     $display("NOP_Branch : %h Done %h instr_memm %h",NOP_Branch, Done, instr_memm);
    // end

endmodule