module alu_control(aluoper,instr,op,invA,invB,Cin);

    input [1:0] instr;
    input [5:0] aluoper;
    output reg invA, invB, Cin;

    output reg [3:0] op;

    always@(*) begin
        invA = 1'b0;
        invB = 1'b0;
        Cin = 1'b0;
        case(aluoper[5:3])
        3'b000: begin // I-type 1 //
                op = {1'b0,aluoper[2:0]}; 
                Cin = (aluoper[2:0] == 3'b001) ? 1'b1:1'b0;
                invA = (aluoper[2:0] == 3'b001) ? 1'b1:1'b0;
                invB = (aluoper[2:0] == 3'b011) ? 1'b1:1'b0;
                end
        3'b001:  op = {2'b11,aluoper[2:1]};  // I-type 2 (SLBI, LBI) 
                
        // R-type //
        3'b010: begin 
                op = {1'b0,aluoper[2],instr};
                Cin = ({aluoper[2],instr} == 3'b001) ? 1'b1:1'b0;
                invA = ({aluoper[2],instr} == 3'b001) ? 1'b1:1'b0;
                invB = ({aluoper[2],instr} == 3'b011) ? 1'b1:1'b0;
                end
        
        3'b110: op = 4'b1011;  //SCO
        3'b111 : op = 4'b1100; //BTR
        
        // set if operations // 
          default: begin
                op = 4'b1000 + (aluoper[5:3]-3'b011); 
                invA = 1'b1;
                Cin = 1'b1;
                end 
        endcase
        end
endmodule
         

    