/* 
    Author          : Abhinav Nandwani, Anna Huang
    Filename        : bit_4shift.v
    Description     : This module does a 4-bit shift of the input based on the oper(ation)
*/
module bit_4shift (in,oper,out);

    input [15:0] in;  //16 bit input 
    input [1:0] oper;  // what type of shift to do (in specification)
    output [15:0] out;  //16 bit output

    
    assign out = (oper == 2'b00) ? {in[11:0], in[15:12]} :  //rotate left
                 (oper == 2'b01) ? {in[11:0], 4'b0000} : //shift left
                 (oper == 2'b10) ? {in[3:0],in[15:4]} : //rotate right 
                  {4'b0000,in[15:4]}; //shift right logical   

endmodule