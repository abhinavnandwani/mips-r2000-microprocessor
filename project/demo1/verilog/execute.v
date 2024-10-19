/*
   CS/ECE 552 Spring '22
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
module execute (RSData, RTData, PC, Imm5, Imm8, sImm8, sImm11, BSrc, ImmSrc, ALUJmp, invA, invB, ,Oper, ALUSign, cin, BranchTaken, ALU_Out, PC_Next);
   input [15:0] RSData, RTData, PC;
   input [15:0] Imm5, Imm8, sImm8, sImm11;
   input [1:0] BSrc;
   input [3:0] Oper;
   input [2:0] BranchTaken;
   input ImmSrc, ALUJmp, invA, invB, ALUSign, cin;
   output [15:0] ALU_Out, PC_Next;

   wire [15:0] ALUIn;
   wire [15:0] PC_I, PC_Branch, Branch;
   wire BrchCnd;
   wire SF, CF, OF, ZF;

   // PC Adder
   assign PC_I = (ImmSrc) ? sImm8 : sImm11;
   cla_16b pc_adder(.sum(Branch), .c_out(), .a(PC), .b(PC_I), .c_in(1'b0));
   
   //Branch & Jump Mux
   assign PC_Branch = (BrchCnd) ? Branch : PC;
   assign PC_Next = (ALUJmp) ? ALU_Out : PC_Branch;

   // Register Mux
   assign ALUIn = (BSrc == 2'b00) ? RTData : (BSrc == 2'b01) ? Imm5 : (BSrc == 2'b10) ? Imm5 : 16'h0000;
   
   // Register Adder NOT DONE NEED TO FIX ALU
   alu alu1(.InA(RSData), .InB(ALUIn), .Cin(cin), .Oper(Oper), .invA(invA), .invB(invB), .sign(ALUSign), .Out(ALU_Out), .ZF(ZF), .SF(SF), .OF(OF), .CF(CF));
   
   
   //BrchCnd 
   brchcnd branch_ctrl(.SF(SF), .ZF(ZF), .brch_instr(BranchTaken), .BrchCnd(BrchCnd));

endmodule
