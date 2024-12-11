
/* 
    Author          : Abhinav Nandwani, Anna Huang
    Filename        : fetch.v
    Description     : This is the overall module for the fetch state of the processor. 
*/

module fetch (
    input clk, rst,                   // Clock and Reset signals
    input [15:0] PC_B,                // PC value "back" from execute stage
    input [15:0] IFID_instr,          // Instruction from IF/ID pipeline register
    input HaltSig,                    // Halt signal to stop execution
    input NOP, branch, NOP_Branch,    // Control signals
    output [15:0] instr,              // Fetched instruction
    output [15:0] PC_Next, PC_curr,   // Next and current PC values
    output err,                       // Error signal
    output fetch_stall                // Stall signal for fetch stage
);

    // Internal wires
    wire [15:0] PC, PC_regs;     // Program Counter registers
    wire [15:0] PC_Sum;    // Incremented PC value
    wire [15:0] instr_memm;      // Instruction fetched from memory
    wire [15:0] instr_ff;        // Latched instruction
    wire Stall, Done;            // Memory stall and done signals

    // PC Register: Holds the current Program Counter
    register pc_reg (
        .r(PC), 
        .w(PC_Next), 
        .clk(clk), 
        .rst(rst), 
        .we(1'b1)
    );

    // Select current PC based on branch signal
    assign PC_curr = branch ? PC_B : PC;

    // Instruction Memory: Fetch instruction based on current PC
    mem_system #(0) instr_mem (
        .DataOut(instr), 
        .Done(Done), 
        .Stall(Stall), 
        .CacheHit(CacheHit), 
        .err(err), 
        .Addr(PC_curr), 
        .DataIn(16'h0000), 
        .Rd(1'b1), 
        .Wr(1'b0), 
        .createdump(HaltSig), 
        .clk(clk), 
        .rst(rst)
    );

    // Adder: Compute PC + 2 for sequential execution
    cla_16b pc_add2 (
        .sum(PC_Sum), 
        .c_out(), 
        .a(PC_curr), 
        .b(16'h0002), 
        .c_in(1'b0)
    );

    // Halt Mux: Select next PC value based on control signals
    assign PC_Next = (NOP | NOP_Branch | fetch_stall) ? PC_curr : PC_Sum;

    // Fetch Stall: Assert stall if memory access is not complete
    assign fetch_stall = ~Done;

endmodule