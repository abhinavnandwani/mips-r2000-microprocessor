/*  
   Author          : Abhinav Nandwani, Anna Huang
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/

`default_nettype none
module execute (clk,rst,NOP,RSData, RTData, PC, Imm5, Imm8, sImm8, sImm11, BSrc, nHaltSig_ff, nHaltSig_2ff,ImmSrc, ALUJmp, invA, invB, Oper, ALUSign, cin, BranchTaken, ALU_Out, PC_Next, MemWrt_ff,MemRead_ff, MemWrt_2ff, MemRead_2ff, PC_2ff, BrchCnd);
   input wire [15:0] RSData, RTData, PC;
   input wire [15:0] Imm5, Imm8, sImm8, sImm11;
   input wire [1:0] BSrc;
   input wire [3:0] Oper;
   input wire [3:0] BranchTaken;
   input wire ImmSrc, ALUJmp, invA, invB, ALUSign, cin,nHaltSig_ff;
   output wire [15:0] ALU_Out, PC_Next;
   output wire BrchCnd;

   input wire clk, rst, NOP;
   input wire MemWrt_ff;
   output wire MemWrt_2ff;

   input wire MemRead_ff;
   output wire MemRead_2ff;

   output wire [15:0] PC_2ff;
   output wire nHaltSig_2ff;

   // DFF for decode stage PC signal
   register dff_d_PC2(.r(PC_2ff), .w(PC), .clk(clk), .rst(rst), .we(1'b1));

   dff MemWrt_2dff(.q(MemWrt_2ff), .d(1'b0 ? MemWrt_2ff : MemWrt_ff), .clk(clk), .rst(rst)); // X to DM
   dff MemRead_2dff(.q(MemRead_2ff), .d(1'b0 ? MemRead_2ff : MemRead_ff), .clk(clk), .rst(rst)); // X to DM
   dff nHaltSig_2dff(.q(nHaltSig_2ff), .d(1'b0 ? nHaltSig_2ff : nHaltSig_ff), .clk(clk), .rst(rst)); // X to DM
   

   wire [15:0] ALUIn, ALU_nflopped;
   wire [15:0] PC_I, PC_Branch, Branch;
   //wire BrchCnd;
   wire SF, CF, OF, ZF;

   // PC Adder
   assign PC_I = (ImmSrc) ? sImm8 : sImm11;
   cla_16b pc_adder(.sum(Branch), .c_out(), .a(PC), .b(PC_I), .c_in(1'b0));

   
   //Branch & Jump Mux
   assign PC_Branch = (~nHaltSig_ff ? BrchCnd : 1'b0) ? Branch : PC;
   assign PC_Next = (ALUJmp) ? ALU_nflopped : PC_Branch;

   // Register Mux
   assign ALUIn = (BSrc == 2'b00) ? RTData : (BSrc == 2'b01) ? Imm5 : (BSrc == 2'b10) ? Imm8 : 16'h0000;
   
   // Register Adder 
   alu alu1(.InA(RSData), .InB(ALUIn), .Cin(cin), .Oper(Oper), .invA(invA), .invB(invB), .sign(ALUSign), .Out(ALU_nflopped), .ZF(ZF), .SF(SF), .OF(OF), .CF(CF));
   
   // DFFs for execute stage signals
   register dff_e_ALU(.r(ALU_Out), .w(ALU_nflopped), .clk(clk), .rst(rst), .we(1'b1));

   //BrchCnd 
   brchcnd branch_ctrl(.SF(SF), .ZF(ZF), .brch_instr(NOP ? 4'b0000:BranchTaken), .BrchCnd(BrchCnd));

   always @(posedge clk) begin
        $display("PC %h PC_Next %h, A: %h, B: %h,  OUT: %h, BrchCnd: %h, ALUJmp %h", PC, PC_Next, RSData, ALUIn, ALU_nflopped, BrchCnd, ALUJmp);
   end



endmodule
`default_nettype wire