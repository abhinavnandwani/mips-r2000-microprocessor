/*
    CS/ECE 552 FALL '22
    Homework #2, Problem 1
    
    a 16-bit CLA module
*/
module cla_16b(sum, c_out, a, b, c_in);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 16;

    output  [N-1:0] sum;
    output         c_out;
    input [N-1: 0] a, b;
    input          c_in;

    // YOUR CODE HERE
    wire [2:0] carries;
    cla_4b cla [3:0] (.sum(sum), .c_out({c_out, carries[2:0]}), .a(a), .b(b), .c_in({carries[2:0], c_in}));
endmodule
