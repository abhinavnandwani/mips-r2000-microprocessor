/* 
    Author          : Abhinav Nandwani, Anna Huang
    Filename        : alu.v
    Description     : A multi-bit ALU module (defaults to 16-bit). As various flags for branching and jumps. 
*/

`default_nettype none
module alu (InA, InB, Cin, Oper, invA, invB, sign, Out, ZF,SF,OF,CF);

    parameter OPERAND_WIDTH = 16;    
    parameter NUM_OPERATIONS = 4;
       
    input wire  [OPERAND_WIDTH -1:0] InA ; // input wire operand A
    input wire  [OPERAND_WIDTH -1:0] InB ; // input wire operand B
    input wire                       Cin ; // Carry in
    input wire  [NUM_OPERATIONS-1:0] Oper; // Operation type
    input wire                       invA; // Signal to invert A
    input wire                       invB; // Signal to invert B
    input wire                       sign; // Signal for signed operation
    output reg  [OPERAND_WIDTH -1:0] Out ; // Result of computation
    output wire                      OF ; // Signal if overflow occured
    output wire                      ZF,CF,SF; // Signal if Out is 0

    wire Cout;
    wire [15:0] S, ShOut, BitOut;
    wire [OPERAND_WIDTH -1:0] A, B;
    wire [OPERAND_WIDTH -1:0] sA, sB;
  
    assign A = invA ? ~InA : InA;
    assign B = invB ? ~InB : InB;

    
    cla_16b cla(.sum(S), .c_out(Cout), .a((B)), .b((A)), .c_in(Cin));


    shifter shift(.In(A), .ShAmt(B[3:0]), .Oper(Oper[1:0]), .Out(ShOut));

    assign BitOut = (Oper[1:0] == 2'b00) ? S : 
                    (Oper[1:0] == 2'b11) ? (A&B) :   
                    ((Oper[1:0] == 2'b10) ? (A^B) : (S));

    
    //// branch conditions ////
    assign ZF = (S == 16'h0000) ? 1'b1 : 1'b0;
    assign OF = (sign) ? ((A[15]~^B[15]) & (S[15]^A[15])) : Cout;
    assign CF = Cout;
    assign SF = S[OPERAND_WIDTH-1];

    always@(*) begin
        casex(Oper)
            4'b00xx: Out = BitOut;
            4'b01xx: Out = ShOut; 
            4'b1000: Out = {15'b000000000000000,ZF};
            4'b1001: Out = {15'b000000000000000, (~SF & ~ZF & ~OF)} | (OF & SF);
            4'b1010: Out = {15'b000000000000000, (ZF | (~SF & ~OF)) | (OF &SF)}; // SLE
            4'b1011: Out = {15'b000000000000000,CF};
            4'b1100: Out = {A[0],A[1],A[2],A[3],A[4],A[5],A[6],A[7],A[8],A[9],A[10],A[11],A[12],A[13],A[14],A[15]}; //TODO BTR
            4'b1101: Out = B; //LBI
            4'b1110: Out = {A[7:0],B[7:0]}; //SLBI
            default: Out = 0;
        endcase

    end
    

endmodule
`default_nettype wire