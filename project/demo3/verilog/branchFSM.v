module branchFSM(
    input clk,
    input rst,
    input actualTaken,
    output reg expectedTaken
);

    // Define state encoding using localparam
    localparam STRONG_NOT_TAKEN = 2'b00,
               WEAK_NOT_TAKEN = 2'b01,
               WEAK_TAKEN     = 2'b10,
               STRONG_TAKEN   = 2'b11;

    reg [1:0] state, next_state;

    // State transition logic (synchronous reset)
    always @(posedge clk or negedge rst) begin
        if (!rst)
            state <= STRONG_NOT_TAKEN; // Reset to STRONG_NOT_TAKEN on reset
        else 
            state <= next_state; // Transition to the next state
    end

    // Combinatorial logic for state transitions and expectedTaken assignment
    always @(*) begin
        // Default assignments
        expectedTaken = 1'b0; // Default expectedTaken value

        case(state)
            STRONG_NOT_TAKEN: begin
                expectedTaken = 1'b0;
                next_state = actualTaken ? WEAK_NOT_TAKEN : STRONG_NOT_TAKEN;
            end

            WEAK_NOT_TAKEN: begin
                expectedTaken = 1'b0;
                next_state = actualTaken ? WEAK_TAKEN : STRONG_NOT_TAKEN;
            end

            WEAK_TAKEN: begin
                expectedTaken = 1'b1;
                next_state = actualTaken ? STRONG_TAKEN : WEAK_NOT_TAKEN;
            end

            STRONG_TAKEN: begin
                expectedTaken = 1'b1;
                next_state = actualTaken ? STRONG_TAKEN : WEAK_TAKEN;
            end

            default: begin
                expectedTaken = 1'b0;
                next_state = STRONG_NOT_TAKEN; // Default state if invalid
            end
        endcase
    end

endmodule
