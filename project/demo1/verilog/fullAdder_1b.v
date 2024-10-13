/*
    CS/ECE 552 FALL '22
    Homework #2, Problem 1
    
    a 1-bit full adder
*/
module fullAdder_1b(s, c_out, a, b, c_in);
    output  s;
    output c_out;
	input   a, b;
    input  c_in;

    // YOUR CODE HERE
    xor2 xor_1(AxorB, a, b);
    xor2 xor_2(s, AxorB, c_in);
    nand2 nand_1(CnandAB, AxorB, c_in);
    nand2 nand_2(AnandB, a, b);
    nand2 nand_3(c_out, AnandB, CnandAB);
    

endmodule
