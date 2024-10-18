module alu_control(aluoper,instr,op);

    input [1:0] instr;
    input [3:0] aluoper;

    output [3:0] op;

    always@(*) 
        case(aluoper)
          4'b1100 : op = 4'b1000;
          4'b1101 : op = 4'b1001;
          4'b1110 : op = 4'b1010;
          4'b1111 : op = 4'b1011; 

    