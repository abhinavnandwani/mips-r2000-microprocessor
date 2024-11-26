`default_nettype none

module cache_controller_old (
    input wire clk,
    input wire rst,
    input wire createdump,
    input wire Rd,
    input wire Wr,
    input wire [3:0] busy,
    input wire valid,
    input wire dirty,
    input wire hit,
    input wire mem_stall,
    output reg CacheHit,
    output reg Stall,
    output reg valid_in,
    output reg comp,
    output reg write,
    output reg write_mem,
    output reg read_mem,
    output reg cache_in,
    output reg mem_in,
    output wire [1:0] counter,
    output reg done
);

    // Define the states using parameters
    parameter IDLE             = 3'b000;
    parameter WRITE_BACK       = 3'b001;
    parameter FILL_CACHE       = 3'b010;
    parameter MEMORY_READ_MISS = 3'b011;
    parameter WAIT_1           = 3'b100;
    parameter CWRITE           = 3'b101;
    parameter DONE             = 3'b110;

    // State and counter logic
    wire [2:0] state;
    reg [2:0] next_state;

    // State register
    dff state_1 [2:0] (
        .q(state),
        .d(next_state),
        .clk(clk),
        .rst(rst)
    );

    reg clr_counter, inc_counter, MemWB;

    // Counter register
    dff counter_ff [1:0] (
        .q(counter),
        .d(clr_counter ? 2'b00 : (inc_counter ? counter + 1'b1 : counter)),
        .clk({2{clk}}),
        .rst({2{rst}})
    );

    // Next state and output logic
    always @(*) begin
        // Default output values
        comp = 1'b0;
        write = 1'b0;
        write_mem = 1'b0;
        read_mem = 1'b0;
        valid_in = 1'b0;
        cache_in = 1'b0;
        mem_in = 1'b0;
        done = 1'b0;
        Stall = 1'b1;
        clr_counter = 1'b0;
        inc_counter = 1'b0;
        CacheHit = 1'b0; // Initialize to prevent latch inference
        next_state = state;

        // State machine logic
        case (state)
            IDLE: begin
                Stall = 1'b0;
                clr_counter = 1'b1;
                comp = Rd | Wr;
                CacheHit = comp & hit & valid;
                MemWB = comp ? dirty : 1'b0;
                done = comp & CacheHit & (Rd | (Wr & ~MemWB));
                next_state = Rd ? (CacheHit ? IDLE : (MemWB ? WRITE_BACK : FILL_CACHE)) :
                             Wr ? (CacheHit ? IDLE : (MemWB ? WRITE_BACK : FILL_CACHE)) : state;
            end

            WRITE_BACK: begin
                Stall = 1'b1;
                write_mem = 1'b1;
                mem_in = 1'b1;
                inc_counter = ~mem_stall;
                next_state = (&counter) ? FILL_CACHE : WRITE_BACK;
                clr_counter = &counter;
            end

            FILL_CACHE: begin
                Stall = 1'b1;
                write = 1'b1;
                cache_in = ~Wr;
                valid_in = 1'b1;
                read_mem = Rd;
                next_state = ~mem_stall ? WAIT_1 : FILL_CACHE;
            end

            WAIT_1: begin
                Stall = 1'b1;
                write = 1'b1;
                valid_in = 1'b1;
                next_state = (&counter) ? (Wr ? CWRITE : DONE) : FILL_CACHE;
                clr_counter = &counter;
                inc_counter = ~mem_stall;
            end

            DONE: begin
                done = 1'b1;
                Stall = 1'b1;
                write = 1'b1;
                valid_in = 1'b1;
                next_state = IDLE;
            end

            CWRITE: begin
                cache_in = 1'b1;
                write = 1'b1;
                valid_in = 1'b1;
                done = 1'b1;
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // always @(posedge mem_stall) begin

    //     $display("Rd : %b Wr : %b mem_stall : %h",Rd,Wr,mem_stall);
        
    // end

endmodule

`default_nettype wire