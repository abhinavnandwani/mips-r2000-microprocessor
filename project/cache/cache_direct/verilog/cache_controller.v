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
    output wire [1:0] counter,
    output reg done
);

    // Define the states using parameters
    parameter IDLE               = 3'b000;
    parameter FILL_CACHE_WRITE   = 3'b001;
    parameter WRITE_BACK         = 3'b010;
    parameter MEMORY_READ_MISS   = 3'b011;
    parameter WAIT_1               = 3'b100;
    parameter ACCESS_READ        = 3'b101;
    parameter DONE       = 3'b110;
    parameter FILL_CACHE         = 3'b111;

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
        cache_in = 1'b1;
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
                // No stall during IDLE, check if Rd or Wr is requested
                Stall = 1'b0;
                clr_counter = 1'b1;
                comp = Rd | Wr; // Enable comparison if read or write
                CacheHit = comp&hit&valid; // Determine cache hit
                MemWB = comp ? dirty : 1'b0; // Dirty bit indicates write-back is needed
                done = comp & CacheHit & (Rd | (Wr & ~MemWB)); // Done if operation completes
                next_state = Rd ? (CacheHit ? IDLE : (MemWB ? WRITE_BACK : FILL_CACHE)) :
                             Wr ? (CacheHit ? (MemWB ? WRITE_BACK : IDLE) : FILL_CACHE) : state;
            end

            WRITE_BACK: begin
                // Write dirty cache line to memory
                Stall = 1'b1;
                write_mem = 1'b1;
                mem_in = 1'b1; // Data comes from memory
                inc_counter = 1'b1; // Increment counter for memory writes
                next_state = (&counter) ? FILL_CACHE : WRITE_BACK; // Transition based on counter
                clr_counter = &counter; // Clear counter when done
            end

            FILL_CACHE: begin
                // Fill cache with data from memory
                Stall = 1'b1;
                write = 1'b1; // Write data to cache
                cache_in = ~Wr; // Write to cache only during reads
                valid_in = 1'b1; // Mark cache line as valid
                read_mem = Rd;
              //  inc_counter = 1'b1; // Increment counter
               // done = &counter; // Mark operation as done
                //clr_counter = &counter; // Clear counter when operation completes
                next_state =  WAIT_1; // Return to IDLE when done
            end

            WAIT_1 : begin
                     Stall = 1'b1;
               write = 1'b1;
               valid_in = 1'b1;
               next_state = (&counter) ?  DONE : FILL_CACHE;
              // done = &counter;
               inc_counter = 1'b1;
            end

            DONE : begin
               done = 1'b1;
               Stall = 1'b1;
               write = 1'b1;
               valid_in = 1'b1;
               next_state = IDLE;
               
            end

            default: begin
                // Default case resets state to IDLE
                next_state = IDLE;
            end
        endcase
    end


   //  always @(posedge clk) begin
   //    $display("Offset : %b CwRITE : %b", counter, valid);
   //  end


endmodule

`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
