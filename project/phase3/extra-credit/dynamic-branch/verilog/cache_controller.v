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
    input wire cache_sel,
    input wire [7:0] index_in,
    input wire [2:0] offset_in,
    input wire [4:0] tag_out,
    input wire [255:0] lru_out,
    output reg [255:0] lru_in,
    output reg [2:0] offset_out,
    output reg [15:0] mem_addr,
    output wire CacheHit,
	output reg data_out_sel,
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

    // State definitions //
    // These states define the cache controller's operations, transitioning based on 
    // read/write requests and cache hit/miss conditions.

    parameter IDLE           = 4'b0000; // Idle state: Waiting for commands
    parameter WRITE_BACK_0   = 4'b0001; // Write back first word to memory
    parameter WRITE_BACK_1   = 4'b0010; // Write back second word to memory
    parameter WRITE_BACK_2   = 4'b0011; // Write back third word to memory
    parameter WRITE_BACK_3   = 4'b0100; // Write back fourth word to memory
    parameter FILL_CACHE_0   = 4'b0101; // Start fetching data into cache (first word)
    parameter FILL_CACHE_1   = 4'b0110; // Fetch second word into cache
    parameter FILL_CACHE_2   = 4'b0111; // Fetch third word and write to cache
    parameter FILL_CACHE_3   = 4'b1000; // Fetch fourth word and continue writing
    parameter FILL_CACHE_4   = 4'b1001; // Complete cache fill (first half)
    parameter FILL_CACHE_5   = 4'b1010; // Complete cache fill (second half)



    // State and next state signals
    // The state register holds the current state of the state machine and 
    // updates to the next state at every clock cycle.
    wire [3:0] state;
    reg [3:0] next_state;

    // State register
    dff state_1 [3:0] (
        .q(state),
        .d(next_state),
        .clk({4{clk}}),
        .rst({4{rst}})
    );

    // CacheHit indicates whether the requested data is present in the cache 
    // (comp and valid are true) and has been successfully accessed (hit is true).
    assign CacheHit = comp & hit & valid;

    // Next state and output logic
    always @(*) begin
        // Default outputs
        comp = 1'b0;
        write = 1'b0;
        write_mem = 1'b0;
        read_mem = 1'b0;
        valid_in = 1'b0;
        lru_in = lru_out;
        cache_in = 1'b0;
		data_out_sel = 1'b1;
        mem_in = 1'b0;
        mem_addr = 16'h0000;
        offset_out = offset_in;
        done = 1'b0;
        Stall = 1'b1;
        next_state = state;

        // State machine logic
        case (state)
            IDLE: begin
                // In the IDLE state, the controller waits for a 
                // read (Rd) or write (Wr) command and evaluates 
                // whether the operation will result in a hit or miss.
                Stall = 1'b0;
                comp = Rd | Wr;
                write = Wr & CacheHit;
             //   CacheHit = comp & hit & valid;
                valid_in = write;
                cache_in = ~write;
                done = comp & CacheHit;
				lru_in[index_in] =  done ? ~cache_sel :lru_out[index_in] ;

                // - If a read or write misses, move to WRITE_BACK or FILL_CACHE based on the dirty bit.
                // - If a hit occurs, complete the operation in the same cycle.
                next_state = Rd ? (CacheHit ? IDLE : (dirty ? WRITE_BACK_0 : FILL_CACHE_0)) :
                             Wr ? (CacheHit ? IDLE : (dirty ? WRITE_BACK_0 : FILL_CACHE_0)) : state;
            end

            WRITE_BACK_0: begin
                // Initiates the write-back sequence by writing 
                // the first word of a dirty cache line to main memory.
                Stall = 1'b1;
                write_mem = 1'b1;
                mem_in = 1'b1;
                mem_addr = {tag_out, index_in, 3'b000};
                offset_out = 3'b000;
                next_state = WRITE_BACK_1;
            end

            WRITE_BACK_1: begin
                // Continue the write-back sequence, writing successive words of the cache line to main memory.
                Stall = 1'b1;
                write_mem = 1'b1;
                mem_in = 1'b1;
                mem_addr = {tag_out, index_in, 3'b010};
                offset_out = 3'b010;
                next_state = WRITE_BACK_2;
            end

            WRITE_BACK_2: begin
                // Continue the write-back sequence, writing successive words of the cache line to main memory.
                Stall = 1'b1;
                write_mem = 1'b1;
                mem_in = 1'b1;
                mem_addr = {tag_out, index_in, 3'b100};
                offset_out = 3'b100;
                next_state = WRITE_BACK_3;
            end

            WRITE_BACK_3: begin
                // Completes the write-back operation and transitions to the next phase (filling cache or returning to idle).
                Stall = 1'b1;
                write_mem = 1'b1;
                mem_in = 1'b1;
                mem_addr = {tag_out, index_in, 3'b110};
                offset_out = 3'b110;
                next_state = FILL_CACHE_0;
            end

            FILL_CACHE_0: begin
                // Starts fetching the first word of the required data from memory into the cache.
                Stall = 1'b1;
                read_mem = 1'b1;
                mem_addr = {tag_in, index_in, 3'b000};
                next_state = FILL_CACHE_1;
            end

            FILL_CACHE_1: begin
                // Fetches successive words from memory into the cache and prepares the cache for use.
                Stall = 1'b1;
                read_mem = 1'b1;
                mem_addr = {tag_in, index_in, 3'b010};
                next_state = FILL_CACHE_2;
            end

            FILL_CACHE_2: begin
                // Fetches successive words from memory into the cache and prepares the cache for use.
                Stall = 1'b1;
                read_mem = 1'b1;
                valid_in = 1'b1;
                write = 1'b1;
                cache_in = 1'b1;
                mem_addr = {tag_in, index_in, 3'b100};
                offset_out = 3'b000;
				data_out_sel = (Rd & (offset_in == 3'b000)) ? 1'b0 : 1'b1;
                next_state = FILL_CACHE_3;
            end

            FILL_CACHE_3: begin
                // Fetches successive words from memory into the cache and prepares the cache for use.
                Stall = 1'b1;
                read_mem = 1'b1;
                write = 1'b1;
                valid_in = 1'b1;
                cache_in = 1'b1;
                mem_addr = {tag_in, index_in, 3'b110};
                offset_out = 3'b010;
				data_out_sel = (Rd & (offset_in == 3'b010)) ? 1'b0 : 1'b1;
                next_state = FILL_CACHE_4;
            end

            FILL_CACHE_4: begin
                // Fetches successive words from memory into the cache and prepares the cache for use.
                Stall = 1'b1;
                write = 1'b1;
                valid_in = 1'b1;
                cache_in = 1'b1;
                offset_out = 3'b100;
				data_out_sel = (Rd & (offset_in == 3'b100)) ? 1'b0 : 1'b1;
                next_state = FILL_CACHE_5;
            end

            FILL_CACHE_5: begin
                // Completes the cache fill operation. 
                // If this was triggered by a read, the 
                // operation is complete; otherwise, 
                // the controller transitions to CWRITE.
                Stall = 1'b1;
                write = 1'b1;
                cache_in = 1'b1;
                valid_in = 1'b1;
                offset_out = 3'b110;
				data_out_sel = (Rd & (offset_in == 3'b110)) ? 1'b0 : 1'b1;
				done = Rd & ~data_out_sel;
				lru_in[index_in] = done ? ~cache_sel : lru_out[index_in] ;
                next_state = IDLE;
            end

            default: begin
                // If an unknown state is encountered, reset to IDLE to avoid unpredictable behavior.
                next_state = IDLE;
            end
        endcase
    end

endmodule

`default_nettype wire