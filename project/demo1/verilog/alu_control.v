module alu_control(aluoper,instr,op);

    input [1:0] instr;
    input [5:0] aluoper;

    output reg [3:0] op;

    always@(*) 
        case(aluoper[5:3])
        
        3'b000: op = {1'b0,aluoper[2:0]}; // I-type 1 //
        3'b001: op = 4'b0000;  // I-type 2 TO DO//
        3'b010: op = {1'b0,aluoper[0],instr}; // R-type //

        // set if operations //
        3'b011 : op = 4'b1000;
        3'b100 : op = 4'b1001;
        3'b101 : op = 4'b1010;
        3'b110 : op = 4'b1011;

        3'b111 : op = 4'b1100; //BTR
        endcase
endmodule
         

    