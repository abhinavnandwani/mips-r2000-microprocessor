module bit_shift (in,oper,out);

    input [15:0] in;  //16 bit input 
    input [1:0] oper;  // what type of shift to do (in specification)
    output [15:0] out;  //16 bit output

    
    assign out = (oper == 2'b00) ? {in[14:0], in[15]} :  //rotate left
                 (oper == 2'b01) ? {in[14:0], 1'b0} : //shift left
                 (oper == 2'b10) ? {in[15],in[15:1]} : //shift right arithmetic
                  {1'b0,in[15:1]}; //shift right logical   

endmodule
