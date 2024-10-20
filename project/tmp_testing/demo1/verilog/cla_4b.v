/*
    CS/ECE 552 FALL'22
    Homework #2, Problem 1
    
    a 4-bit CLA module
*/
module cla_4b(sum, c_out, a, b, c_in);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 4;

    output  [N-1:0] sum;
    output         c_out;
    input  [N-1: 0] a, b;
    input          c_in;

    wire [3:0] p;            // Propagate signals
    wire [3:0] ng;           // Not-ed Generate signals
    wire [4:0] carries;      // Carry signals

    wire [3:0] cp;

    // Generate propagate and not-ed generate signals
    xor2 xor_1 [3:0] (.out(p),.in1(a),.in2(b));
    
    nand2 nand_1 [3:0] (.out(ng),.in1(a),.in2(b));

    // Carry look-ahead logic
    nand2 nand_2 [3:0](.out(cp),.in1(p),.in2({carries[3:1], c_in}));
    nand2 nand_3 [3:0](.out({c_out, carries[3:1]}),.in1(cp),.in2(ng));
    
    fullAdder_1b fa [3:0] (.s(sum), .c_out(), .a(a), .b(b), .c_in({carries[3:1], c_in}));


    

endmodule
