`default_nettype none

module cache_controller (
    input wire clk,
    input wire rst,
    input wire createdump,
    input wire Rd,
    input wire Wr,
    input wire valid,
    input wire dirty,
    input wire hit,
    input wire mem_stall,
    input wire [4:0] tag_in,
    input wire [7:0] index_in,
    input wire [2:0] offset_in,
    input wire [4:0] tag_out,
    output reg [2:0] offset_out,
    output reg [15:0] mem_addr,
    output reg CacheHit,
    output reg Stall,
    output reg valid_in,
    output reg comp,
    output reg write,
    output reg write_mem,
    output reg read_mem,
    output reg cache_in,
    output reg mem_in,
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
    parameter FILL_CACHE_2       = 4'b0111;
    parameter FILL_CACHE_3       = 4'b1000;
    parameter FILL_CACHE_4       = 4'b1001;
    parameter FILL_CACHE_5       = 4'b1010;
    parameter CWRITE             = 4'b1011;
    parameter DONE               = 4'b1100;

    // State and counter logic
    wire [3:0] state;
    reg [3:0] next_state;



    // State register
    dff state_1 [3:0] (
        .q(state),
        .d(next_state),
        .clk({4{clk}}),
        .rst({4{rst}})
    );

    reg MemWB;

    // Next state and output logic
    always @(*) begin
        // Default output values
        comp = 1'b0;
        write = 1'b0;
        write_mem = 1'b0;
        read_mem = 1'b0;
        valid_in = 1'b0;
        cache_in = 1'b1;
        mem_in = 1'b0;
        mem_addr = 16'h0000;
        offset_out = 3'b000;
        done = 1'b0;
        Stall = 1'b1;
        CacheHit = 1'b0; // Initialize to prevent latch inference
        next_state = state;

        // State machine logic
        case (state)
            IDLE: begin
                Stall = 1'b0;
                comp = Rd | Wr;
                CacheHit = comp & hit & valid;
                MemWB = comp ? dirty : 1'b0;
                write = Wr & CacheHit;
                valid_in = write;
                cache_in = ~write;
                done = comp & CacheHit;
                next_state = Rd ? (CacheHit ? IDLE : (MemWB ? WRITE_BACK_0 : FILL_CACHE_0)) :
                             Wr ? (CacheHit ? IDLE : (MemWB ? WRITE_BACK_0 : FILL_CACHE_0)) : state;
            end

            WRITE_BACK_0: begin
                Stall = 1'b1;
                write_mem = 1'b1;
                mem_in = 1'b1;
                mem_addr = {tag_out,index_in,3'b000};
                offset_out = 3'b000;
                next_state = 1'b0 ? state : WRITE_BACK_1;
            end

            WRITE_BACK_1: begin
                Stall = 1'b1;
                write_mem = 1'b1;
                mem_in = 1'b1;
                mem_addr = {tag_out,index_in,3'b010};
                offset_out = 3'b010;
                next_state = 1'b0 ? state  : WRITE_BACK_2;
            end

            WRITE_BACK_2: begin
                Stall = 1'b1;
                write_mem = 1'b1;
                mem_in = 1'b1;
                mem_addr = {tag_out,index_in,3'b100};
                offset_out = 3'b100;
                next_state = 1'b0 ? state  : WRITE_BACK_3;
            end

            WRITE_BACK_3: begin
                Stall = 1'b1;
                write_mem = 1'b1;
                mem_in = 1'b1;
                mem_addr = {tag_out,index_in,3'b110};
                offset_out = 3'b110;
                next_state = 1'b0 ? state  : FILL_CACHE_0;
            end

            FILL_CACHE_0: begin
                Stall = 1'b1;
                read_mem = 1'b1;
                mem_addr = {tag_in,index_in,3'b000};
                next_state = 1'b0 ? state  : FILL_CACHE_1;
            end

            FILL_CACHE_1: begin
                Stall = 1'b1;
                read_mem = 1'b1;
                mem_addr = {tag_in,index_in,3'b010};
                next_state = 1'b0 ? state  : FILL_CACHE_2;
            end

            FILL_CACHE_2: begin
                Stall = 1'b1;
                read_mem = 1'b1;
                write = 1'b1;
                cache_in = 1'b1;
                mem_addr = {tag_in,index_in,3'b100};
                offset_out = 3'b000;
                next_state = 1'b0 ? state : FILL_CACHE_3;
            end

            FILL_CACHE_3: begin
                Stall = 1'b1;
                read_mem = 1'b1;
                write = 1'b1;
                cache_in = 1'b1;
                mem_addr = {tag_in,index_in,3'b110};
                offset_out = 3'b010;
                next_state = 1'b0 ? state  : FILL_CACHE_4;
            end

            FILL_CACHE_4: begin
                Stall = 1'b1;
                write = 1'b1;
                cache_in = 1'b1;
                offset_out = 3'b100;
                next_state = 1'b0 ? state : FILL_CACHE_5;
            end

            FILL_CACHE_5: begin
                Stall = 1'b1;
                write = 1'b1;
                cache_in = 1'b1;
                offset_out = 3'b110;
                done = 1'b1;
                next_state = IDLE;
            end

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