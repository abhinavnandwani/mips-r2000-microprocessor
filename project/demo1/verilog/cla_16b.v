/* 
    Author          : Abhinav Nandwani, Anna Huang
    Filename        : cla_16b.v
    Description     : 16 bit carry look-ahead adder used by the ALU and for PC and IMM add at various stages. 
*/
module cla_16b(sum, c_out, a, b, c_in);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 16;

    output  [N-1:0] sum;
    output         c_out;
    input [N-1: 0] a, b;
    input          c_in;

    
    wire [2:0] carries;
    cla_4b cla [3:0] (.sum(sum), .c_out({c_out, carries[2:0]}), .a(a), .b(b), .c_in({carries[2:0], c_in}));
endmodule
