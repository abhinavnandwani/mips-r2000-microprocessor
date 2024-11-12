/*  
   Author          : Abhinav Nandwani, Anna Huang
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/

`default_nettype none
module execute (
    input wire clk, 
    input wire rst, 
    input wire NOP,
    input wire [15:0] RSData, 
    input wire [15:0] RTData, 
    input wire [15:0] PC,
    input wire [15:0] Imm5, 
    input wire [15:0] Imm8, 
    input wire [15:0] sImm8, 
    input wire [15:0] sImm11,
    input wire [1:0] BSrc,
    input wire [3:0] Oper,
    input wire [3:0] BranchTaken,
    input wire ImmSrc, 
    input wire ALUJmp, 
    input wire invA, 
    input wire invB, 
    input wire ALUSign, 
    input wire cin, 
    input wire HaltSig,
    output wire [15:0] PC_Next,
    output wire [15:0] ALU_Out,
    output wire BrchCnd
);

   wire [15:0] ALUIn;
   wire [15:0] PC_I, PC_Branch, Branch;
   wire SF, CF, OF, ZF;

   // PC Adder
   assign PC_I = (ImmSrc) ? sImm8 : sImm11;
   cla_16b pc_adder(.sum(Branch), .c_out(), .a(PC), .b(PC_I), .c_in(1'b0));
   
   //Branch & Jump Mux
   assign PC_Branch = (~HaltSig ? BrchCnd : 1'b0) ? Branch : PC;
   assign PC_Next = (ALUJmp) ? ALU_Out : PC_Branch;

   // Register Mux
   assign ALUIn = (BSrc == 2'b00) ? RTData : (BSrc == 2'b01) ? Imm5 : (BSrc == 2'b10) ? Imm8 : 16'h0000;
   
   // Register Adder 
   alu alu1(.InA(RSData), .InB(ALUIn), .Cin(cin), .Oper(Oper), .invA(invA), .invB(invB), .sign(ALUSign), .Out(ALU_Out), .ZF(ZF), .SF(SF), .OF(OF), .CF(CF));

   //BrchCnd 
   brchcnd branch_ctrl(.SF(SF), .ZF(ZF), .brch_instr(NOP ? 4'b0000:BranchTaken), .BrchCnd(BrchCnd));

endmodule
`default_nettype wire