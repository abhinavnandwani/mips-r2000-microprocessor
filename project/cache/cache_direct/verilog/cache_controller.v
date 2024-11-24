`default_nettype none
module cache_controller (
   // input wire enable,
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
   output reg Stall,
   output reg valid_in,
   output reg comp,
   output reg CacheHit,
   output reg write,
   output reg write_mem,
   output reg read_mem,
   output reg cache_in,
   output reg mem_in,
   output wire [1:0] counter,
   output reg done
   );

   // Define the states using parameters
   parameter IDLE                  = 3'b000;
   parameter COMPARE_READ          = 3'b001;
   parameter WRITE_MISS         = 3'b010;
   parameter MEMORY_READ_MISS      = 3'b011;
   parameter WAIT                  = 3'b100;
   parameter ACCESS_READ           = 3'b101;
   parameter ACCESS_WRITE          = 3'b110;
   parameter DONE                  = 3'b111;


   wire [2:0] state;
   reg [2:0] next_state;

   dff state_1 [2:0](.q(state), .d(next_state), .clk(clk), .rst(rst));

   reg clr_counter, inc_counter;
  dff counter_ff [1:0](.q(counter), .d(clr_counter ? 2'b00 : (inc_counter ? counter + 1'b1 : counter)), .clk({2{clk}}), .rst({2{rst | clr_counter}}));
  // assign counter = clr_counter ? 2'b00 : inc_counter ? counter + 2'b01 : counter;

   // always@(posedge clk, posedge rst)
   //    if (rst)
   //       counter <= 2'b00;
   //    else if (clr_counter)
   //       counter <= 2'b00;
   //    else if (inc_counter)
   //       counter <= counter + 1'b1;

   always @(*) begin
      // Default output values
      comp = 1'b0;
      write = 1'b0;
      write_mem = 1'b0;
      read_mem = 1'b0;
      CacheHit = 1'b0;
      valid_in = 1'b0;
      cache_in = 1'b0;
      mem_in = 1'b0;
      done = 1'b0;
      Stall = 1'b1; // Default: stall until explicitly cleared
      clr_counter = 1'b0;
      inc_counter = 1'b0;
      next_state = state;
      
      case (state)
         IDLE: begin
            Stall = 1'b0; // No stall in IDLE
            if (Rd) begin
               comp = 1'b1;
               if (hit&valid) begin
                  CacheHit = 1'b1;
                  done = 1'b1;
                  next_state = IDLE;
               end else begin
                  next_state = MEMORY_READ_MISS;
                  if (~hit&valid&dirty)begin
                  mem_in = 1'b1;
                  write_mem = 1'b1;
                  end 
               end
            
            end else if (Wr) begin 
               comp = 1'b1;
               if (hit&valid&~dirty) begin
                 CacheHit = 1'b1;
                 write = 1'b1;
               //  done = 1'b1;
                 valid_in = 1'b1;
                 next_state = DONE;
               end else next_state = WRITE_MISS;
            end
         end

         MEMORY_READ_MISS: begin
            Stall = 1'b1;
               if (~mem_stall) begin
                  write = 1'b1;
                  valid_in = 1'b1;
                  cache_in = 1'b1;
                  read_mem = 1'b1;
                  next_state = WAIT;
               end else next_state = MEMORY_READ_MISS; //retry if mem busy
         end
      
         WAIT: begin
            if (&counter) begin
               next_state = ACCESS_WRITE;
            end else begin
               inc_counter = 1'b1;
               next_state = MEMORY_READ_MISS;
            end
         end

         WRITE_MISS: begin
            Stall = 1'b1;
               if (dirty) begin
                  mem_in = 1'b1;
                  write_mem = 1'b1;
                  next_state = ACCESS_READ;
               end else begin
                  write = 1'b1;
                  valid_in = 1'b1;
                  cache_in = 1'b0;
                  next_state = ACCESS_WRITE;
               end
            
         end

         ACCESS_READ: begin
            Stall = 1'b1;
            if (~mem_stall) begin
               write = 1'b1;
               valid_in = 1'b1;
               cache_in = 1'b1;
               next_state = ACCESS_WRITE;
            end 
         end

         ACCESS_WRITE: begin
            Stall = 1'b1;
            write = 1'b1;
            valid_in = 1'b1;  // Set valid bit
            clr_counter = 1'b1;
            next_state = DONE;
         end

         DONE: begin
            Stall = 1'b1; 
            done = 1'b1;
            next_state = IDLE;
         end

         default: begin
            next_state = IDLE; // Reset to IDLE in unknown state
         end
      endcase
   end





endmodule
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
