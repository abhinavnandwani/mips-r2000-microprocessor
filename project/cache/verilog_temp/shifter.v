/*
    CS/ECE 552 FALL '22
    Homework #2, Problem 2
    
    A barrel shifter module.  It is designed to shift a number via rotate
    left, shift left, shift right arithmetic, or shift right logical based
    on the 'Oper' value that is passed in.  It uses these
    shifts to shift the value any number of bits.
 */
module shifter (In, ShAmt, Oper, Out);

    // declare constant for size of inputs, outputs, and # bits to shift
    parameter OPERAND_WIDTH = 16;
    parameter SHAMT_WIDTH   =  4;
    parameter NUM_OPERATIONS = 2;

    input  [OPERAND_WIDTH -1:0] In   ; // Input operand
    input  [SHAMT_WIDTH   -1:0] ShAmt; // Amount to shift/rotate
    input  [NUM_OPERATIONS-1:0] Oper ; // Operation type
    output [OPERAND_WIDTH -1:0] Out  ; // Result of shift/rotate

    wire [15:0] s0,s1,s2,s3;

   /* YOUR CODE HERE */

   wire [15:0] temp_out_sh0,temp_out_sh1,temp_out_sh2,temp_out_sh3;

   bit_shift bs0(.in(In), .oper(Oper), .out(temp_out_sh0));
   assign s0 = ShAmt[0] ? temp_out_sh0 : In;

   bit_2shift bs1(.in(s0), .oper(Oper), .out(temp_out_sh1));
   assign s1 = ShAmt[1] ? temp_out_sh1 : s0;

   bit_4shift bs2 (.in(s1), .oper(Oper), .out(temp_out_sh2));
   assign s2 = ShAmt[2] ? temp_out_sh2 : s1;

   bit_8shift  bs3 (.in(s2), .oper(Oper), .out(temp_out_sh3));
   assign s3 = ShAmt[3] ? temp_out_sh3:s2;

   assign Out = s3;

   
endmodule
