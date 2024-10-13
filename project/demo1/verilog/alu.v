/*
    CS/ECE 552 FALL '22
    Homework #2, Problem 3

    A multi-bit ALU module (defaults to 16-bit). It is designed to choose
    the correct operation to perform on 2 multi-bit numbers from rotate
    left, shift left, shift right arithmetic, shift right logical, add,
    or, xor, & and.  Upon doing this, it should output the multi-bit result
    of the operation, as well as drive the output signals Zero and Overflow
    (OFL).
*/

module alu (InA, InB, Cin, Oper, invA, invB, sign, Out, Zero, Ofl);

    parameter OPERAND_WIDTH = 16;    
    parameter NUM_OPERATIONS = 3;
       
    input  [OPERAND_WIDTH -1:0] InA ; // Input operand A
    input  [OPERAND_WIDTH -1:0] InB ; // Input operand B
    input                       Cin ; // Carry in
    input  [NUM_OPERATIONS-1:0] Oper; // Operation type
    input                       invA; // Signal to invert A
    input                       invB; // Signal to invert B
    input                       sign; // Signal for signed operation
    output [OPERAND_WIDTH -1:0] Out ; // Result of computation
    output                      Ofl ; // Signal if overflow occured
    output                      Zero; // Signal if Out is 0

    wire Cout;
    wire [15:0] S, ShOut, BitOut;
    wire [OPERAND_WIDTH -1:0] A, B;
    wire [OPERAND_WIDTH -1:0] sA, sB;
  
    assign A = invA ? ~InA : InA;
    assign B = invB ? ~InB : InB;

    
    cla_16b cla(.sum(S), .c_out(Cout), .a((A)), .b((B)), .c_in(Cin));

    shifter shift(.In(A), .ShAmt(B[3:0]), .Oper(Oper[1:0]), .Out(ShOut));

    assign BitOut = (Oper[1:0] == 2'b01) ? (A & B) : ((Oper[1:0] == 2'b10) ? (A | B) : (A^B));

    assign Out = (Oper[2]) ? ((Oper[1:0] == 2'b00) ? S : BitOut) : ShOut;
    assign Ofl = (sign) ? ((A[15]~^B[15]) & (S[15]^A[15])) : Cout;

                 
    assign Zero = (Out == 16'h0000) ? 1'b1 : 1'b0;
    

endmodule