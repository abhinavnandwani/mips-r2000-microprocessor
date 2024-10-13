/*
   CS/ECE 552 Spring '22
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
`default_nettype none
module execute (/* TODO: Add appropriate inputs/outputs for your execute stage here*/);
   input [15:0] RSData, RTData;
   input [15:0] Imm5, Imm8, sImm8, sImm11;

   wire [15:0] ALUIn, PC_I, Branch;
   wire [1:0] BSrc;
   wire ImmSrc;


   // PC Mux
   assign PC_I = (ImmSrc) ? sImm8 : sImm11;
   // PC Adder
   cla_16b pc_adder(.sum(Branch), .c_out(), .a(PC_Next), .b(PC_I), .c_in(1'b0));
  
   // Branch Mux?
   // Jump Mux?

   // Register Mux
   assign ALUIn = (BSrc == 2'b00) ? RTData : (BSrc == 2'b01) ? Imm5 : (BSrc == 2'b10) ? Imm5 : 16'h0000;
   // Register Adder NOT DONE NEED TO FIX ALU
   alu alu1(.InA(), .InB(), .Cin(), .Oper(), .invA(), .invB(), .sign(), .Out(), .Zero(), .Ofl());

endmodule
`default_nettype wire
