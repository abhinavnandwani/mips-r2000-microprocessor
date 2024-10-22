/* 
    Author          : Abhinav Nandwani, Anna Huang
    Filename        : bit_2shift.v
    Description     : This module does a 2-bit shift of the input based on the oper(ation)
*/

module bit_2shift (in,oper,out);

    input [15:0] in;  //16 bit input 
    input [1:0] oper;  // what type of shift to do (in specification)
    output [15:0] out;  //16 bit output

    
    assign out = (oper == 2'b00) ? {in[13:0], in[15:14]} :  //rotate left
                 (oper == 2'b01) ? {in[13:0], 2'b00} : //shift left
                 (oper == 2'b10) ? {in[1:0],in[15:2]} : //rotate right 
                  {2'b00,in[15:2]}; //shift right logical   

endmodule