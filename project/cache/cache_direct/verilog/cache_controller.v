`default_nettype none

module cache_controller (
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
    output reg [1:0] counter,
    output reg done
);

    // Define the states using parameters
    parameter IDLE               = 4'b0000;
    parameter WRITE_BACK_0       = 4'b0001;
    parameter WRITE_BACK_1       = 4'b0010;
    parameter WRITE_BACK_2       = 4'b0011;
    parameter WRITE_BACK_3       = 4'b0100;
    parameter FILL_CACHE_0       = 4'b0101;
    parameter FILL_CACHE_1       = 4'b0110;
    parameter FILL_CACHE_2       = 4'b1000;
    parameter FILL_CACHE_3       = 4'b1001;
    // parameter WAIT_1           = 3'b100;
    parameter CWRITE           = 4'b1010;
    parameter DONE             = 4'b1100;

    // State and counter logic
    wire [3:0] state;
    reg [3:0] next_state;

    // State register
    dff state_1 [3:0] (
        .q(state),
        .d(next_state),
        .clk(clk),
        .rst(rst)
    );

    reg MemWB;
    // reg clr_counter, inc_counter, MemWB;

    // // Counter register
    // dff counter_ff [1:0] (
    //     .q(counter),
    //     .d(clr_counter ? 2'b00 : (inc_counter ? counter + 1'b1 : counter)),
    //     .clk({2{clk}}),
    //     .rst({2{rst}})
    // );

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
        counter = 2'b00;
        CacheHit = 1'b0; // Initialize to prevent latch inference
        next_state = state;

        // State machine logic
        case (state)
            IDLE: begin
                Stall = 1'b0;
                comp = Rd | Wr;
                CacheHit = comp & hit & valid;
                MemWB = comp ? dirty : 1'b0;
                done = comp & CacheHit & (Rd | (Wr & ~MemWB));
                $display("Cache Hit  %h", CacheHit);
                next_state = Rd ? (CacheHit ? IDLE : (MemWB ? WRITE_BACK_0 : FILL_CACHE_0)) :
                             Wr ? (CacheHit ? IDLE : (MemWB ? WRITE_BACK_0 : FILL_CACHE_0)) : state;
            end

            WRITE_BACK_0: begin
                Stall = 1'b1;
                write_mem = 1'b1;
                mem_in = 1'b1;
                counter = 2'b00;
                next_state = WRITE_BACK_1;
            end

            WRITE_BACK_1: begin
                Stall = 1'b1;
                write_mem = 1'b1;
                mem_in = 1'b1;
                counter = 2'b01;
                next_state = WRITE_BACK_2;
            end

            WRITE_BACK_2: begin
                Stall = 1'b1;
                write_mem = 1'b1;
                mem_in = 1'b1;
                counter = 2'b10;
                next_state = WRITE_BACK_3;
            end

            WRITE_BACK_3: begin
                Stall = 1'b1;
                write_mem = 1'b1;
                mem_in = 1'b1;
                counter = 2'b11;
                next_state = FILL_CACHE_0;
            end

            FILL_CACHE_0: begin
                Stall = 1'b1;
                write = 1'b1;
                cache_in = ~Wr;
                valid_in = 1'b1;
                read_mem = Rd;
                counter = 2'b00;
                next_state = mem_stall ? state : FILL_CACHE_1;
            end

            FILL_CACHE_1: begin
                Stall = 1'b1;
                write = 1'b1;
                cache_in = ~Wr;
                valid_in = 1'b1;
                read_mem = Rd;
                counter = 2'b01;
                next_state = mem_stall ? state : FILL_CACHE_2;
            end

            FILL_CACHE_2: begin
                Stall = 1'b1;
                write = 1'b1;
                cache_in = ~Wr;
                valid_in = 1'b1;
                read_mem = Rd;
                counter = 2'b10;
                next_state = mem_stall ? state : FILL_CACHE_3;
            end

            FILL_CACHE_3: begin
                Stall = 1'b1;
                write = 1'b1;
                valid_in = 1'b1;
                counter = 2'b11;
                next_state = Wr ? CWRITE : DONE;
            end

            // WAIT_1: begin
            //     Stall = 1'b1;
            //     write = 1'b1;
            //     valid_in = 1'b1;
            //     next_state = (&counter) ? (Wr ? CWRITE : DONE) : FILL_CACHE;
            //     clr_counter = &counter;
            //     inc_counter = ~mem_stall;
            // end

            CWRITE: begin
                cache_in = 1'b1;
                write = 1'b1;
                valid_in = 1'b1;
                done = 1'b1;
                next_state = IDLE;
            end

            DONE: begin
                done = 1'b1;
                Stall = 1'b1;
                write = 1'b1;
                valid_in = 1'b1;
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule

`default_nettype wire