/*
   CS/ECE 552 Spring '22
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
module decode (clk, rst, instr, WB, RD, PC, RegDst, ALUOpr, ZeroExt, RegWrt, err, RSData, RTData, Imm5, Imm8, sImm8, sImm11, PC_Next,Oper);
   input clk, rst;
   input [15:0] instr, WB;
   input [15:0] PC;
   input [1:0] RegDst;
   input ZeroExt, RegWrt;
   input [5:0] ALUOpr;
   output [3:0] Oper;
   output err;
   output [15:0] RSData, RTData;
   output [15:0] Imm5, Imm8, sImm8, sImm11;
   output [15:0] PC_Next;

   output [2:0] RD;
   
   //Register File
assign RD = (RegDst == 2'b00) ? instr[7:5] :
            (RegDst == 2'b01) ? instr[10:8] :
            (RegDst == 2'b10) ? instr[4:2] :
            3'b111;

   regFile regFile0 (.read1Data(RSData), .read2Data(RTData), .err(err), .clk(clk), .rst(rst), .read1RegSel(instr[10:8]), .read2RegSel(instr[7:5]), .writeRegSel(RD), .writeData(WB), .writeEn(RegWrt));

   //Sign Extension
   assign Imm5 = (ZeroExt) ? {11'h000, instr[4:0]} : {{11{instr[4]}}, instr[4:0]};
   assign sImm8 = {{8{instr[7]}}, instr[7:0]};
   assign Imm8 = (ZeroExt) ? {8'h00, instr[7:0]} : sImm8;
   assign sImm11 = {{5{instr[10]}}, instr[10:0]};

   assign PC_Next = PC;
   alu_control aluc(.aluoper(ALUOpr),.instr(instr[1:0]),.op(Oper));
   
endmodule
