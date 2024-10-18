module alu_control(aluoper,instr,op);

    input [1:0] instr;
    input [3:0] aluoper;

    output [3:0] op;

    always@(*) 
        case(aluoper[5:3])
        
        4'b000: op = {0,aluoper[2:0]}; // I-type 1 //
        4'b001: op = 4'b0000;  // I-type 2 //
        4'b010: op = {0,aluoper[0],instr}; // R-type //

        // set if operations //
        4'b011 : op = 4'b1000;
        4'b100 : op = 4'b1001;
        4'b101 : op = 4'b1010;
        4'b110 : op = 4'b1011;

        4'b111 : op = 4'b1100; //BTR
        endcase
endmodule
         

    