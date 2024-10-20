module bit_8shift (in,oper,out);

    input [15:0] in;  //16 bit input 
    input [1:0] oper;  // what type of shift to do (in specification)
    output [15:0] out;  //16 bit output

    
    assign out = (oper == 2'b00) ? {in[7:0], in[15:8]} :  //rotate left
                 (oper == 2'b01) ? {in[7:0], 8'b00000000} : //shift left
                 (oper == 2'b10) ? {in[7:0],in[15:8]} : //rotate right 
                  {8'b00000000,in[15:8]}; //shift right logical   

endmodule