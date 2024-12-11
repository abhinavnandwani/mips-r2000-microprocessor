module branchFSM(
    input clk,
    input rst,
    input instr_b,
    input actualTaken,
    output reg expectedTaken
);

    // Define state encoding using localparam
    localparam STRONG_NOT_TAKEN = 2'b00,
               WEAK_NOT_TAKEN = 2'b01,
               WEAK_TAKEN     = 2'b10,
               STRONG_TAKEN   = 2'b11;

    wire [1:0] state; 
    reg [1:0] next_state;

    // State register
    dff branch_state [1:0] (
        .q(state),
        .d(next_state),
        .clk(clk),
        .rst(rst)
    );

    // Combinatorial logic for state transitions and expectedTaken assignment
    always @(*) begin
        // Default assignments
        expectedTaken = 1'b0; // Default expectedTaken value


        case(state)
            STRONG_NOT_TAKEN: begin
                expectedTaken = 1'b0;
                next_state = instr_b ? (actualTaken ? WEAK_NOT_TAKEN : STRONG_NOT_TAKEN) : state;
            end

            WEAK_NOT_TAKEN: begin
                expectedTaken = 1'b0;
                next_state = instr_b ? (actualTaken ? WEAK_TAKEN : STRONG_NOT_TAKEN) : state;
            end

            WEAK_TAKEN: begin
                expectedTaken =  1'b1;
                next_state = instr_b ? (actualTaken ? STRONG_TAKEN : WEAK_NOT_TAKEN) : state;
            end

            STRONG_TAKEN: begin
                expectedTaken = 1'b1;
                next_state = instr_b ? (actualTaken ? STRONG_TAKEN : WEAK_TAKEN) : state;
            end
        endcase

    end

    // always@(posedge clk)        
    //     if(instr_b)
    //     $display("state %b next_state %b actualTaken %h expectedTaken %h", state, next_state, actualTaken, expectedTaken);

endmodule
