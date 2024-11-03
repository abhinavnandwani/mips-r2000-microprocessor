/* 
    Author          : Abhinav Nandwani, Anna Huang
    Filename        : decode.v
    Description     : This is the overall module for the decode stage of the processor. 
*/

module decode (
    // Clock and Reset
    input wire clk,
    input wire rst,

    // Instruction and Data Inputs
    input wire [15:0] instr,
    input wire [15:0] WB,
    input wire [15:0] PC,
    
    // Control Signals
    input wire [1:0] RegDst,
    input wire ZeroExt,
    input wire RegWrt,
    input wire [5:0] ALUOpr,

    // Outputs
    output wire [3:0] Oper,
    output wire err,
    output wire [15:0] RSData,
    output wire [15:0] RTData,
    output wire [15:0] Imm5,
    output wire [15:0] Imm8,
    output wire [15:0] sImm8,
    output wire [15:0] sImm11,
    output wire [15:0] PC_Next,
    output wire invA,
    output wire invB,
    output wire Cin,
    output wire [2:0] RD
    );
   
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
   alu_control aluc(.aluoper(ALUOpr),.instr(instr[1:0]),.op(Oper), .invA(invA), .invB(invB), .Cin(Cin));
   
endmodule
