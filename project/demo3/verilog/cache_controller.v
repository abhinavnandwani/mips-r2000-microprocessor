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
   parameter IDLE                  = 3'b000;
   parameter COMPARE_READ          = 3'b001;
   parameter COMPARE_WRITE         = 3'b010;
   parameter MEMORY_READ_MISS      = 3'b011;
   parameter WAIT                  = 3'b100;
   parameter ACCESS_READ           = 3'b101;
   parameter ACCESS_WRITE          = 3'b110;
   parameter DONE                  = 3'b111;


   wire [2:0] state;
   reg [2:0] next_state;

   dff state_1 [2:0](.q(state), .d(next_state), .clk(clk), .rst(rst));

   reg clr_counter, inc_counter;
  // dff counter_ff [1:0](.q(counter), .d(clr_counter ? 2'b00 : (inc_counter ? counter + 1'b1 : counter)), .clk(clk), .rst(rst));

   always@(posedge clk, posedge rst)
      if (rst)
         counter <= 2'b00;
      else if (clr_counter)
         counter <= 2'b00;
      else if (inc_counter)
         counter <= counter + 1'b1;

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
      clr_counter = 1'b0;
      inc_counter = 1'b0;
      next_state = state;

      case (state)
         IDLE: begin
            if (Rd) begin
               comp = 1'b1;
               next_state = COMPARE_READ;
            end else if (Wr) begin 
               comp = 1'b1;
               next_state = COMPARE_WRITE;
            end
         end

         COMPARE_READ: begin
            if (~hit) begin
               comp = 1'b0;
               write = 1'b1;
             //  read_mem = 1'b1;
               next_state = MEMORY_READ_MISS;
            end else begin
               if (hit&valid) begin
                  next_state = DONE; //data ready
               end else begin
                  comp = 1'b0;
                  write = 1'b0;
       
                  next_state = MEMORY_READ_MISS;
               end
            end
         end

         MEMORY_READ_MISS : begin // understand 4 banked (evict)
            if (~mem_stall) begin
               if (dirty) begin             // evict, check dirty bit
                  comp = 1'b0;
                  write = 1'b0;
                  mem_in = 1'b1;
                  write_mem = 1'b1;
                  next_state = ACCESS_READ;
               end else begin
                  comp = 1'b0;
                  write = 1'b1;
                  valid_in = 1'b1;
                  cache_in = 1'b1;
                  read_mem = 1'b1;

                  if (~(&counter))
                     next_state = WAIT;
                  else next_state =  ACCESS_WRITE;
               end
            end
         end

         WAIT: begin
            inc_counter = 1'b1;
            next_state = MEMORY_READ_MISS;
         end
         // MEMORY_READ_NOTVALID: begin
         //    if (~mem_stall) begin
         //       comp = 1'b0;
         //       write = 1'b1;
         //       valid_in = 1'b1;  // set valid bit
         //       cache_in = 1'b1;
         //       next_state = ACCESS_WRITE; // write to cache
         //    end
         // end

         COMPARE_WRITE: begin
            if (~valid) 
               if (dirty) begin             // evict, check dirty bit
                  comp = 1'b0;
                  write = 1'b0;
                  mem_in = 1'b1;
                  write_mem = 1'b1;
                  next_state = ACCESS_READ;
               end else begin
                  comp = 1'b0;
                  write = 1'b1;
                  valid_in = 1'b1;
                  cache_in = 1'b0;
                  
                  next_state = ACCESS_WRITE;
               end
            else begin
               if (hit)
                  comp = 1'b0;
                  write = 1'b1;
                  valid_in = 1'b1;
                  cache_in = 1'b0;
                  next_state = DONE;
            end
         end

         ACCESS_READ: begin
            if (~mem_stall) begin
               comp = 1'b0;
               write = 1'b1;
               valid_in = 1'b1;
               cache_in = 1'b1;
              next_state = ACCESS_WRITE;
            end 
         end

         ACCESS_WRITE: begin
            write = 1'b1;
            valid_in = 1'b1;  // set valid bit
            next_state = DONE;
         end

         DONE : begin
           done = 1'b1;
           clr_counter = 1'b1;
           next_state = IDLE;
         end

         default: begin
            next_state = IDLE; // Default case to reset to IDLE
         end
      endcase
   end

   // always@(posedge clk)
   //    $display("state : %b, counter; %h, inc: %h, clr: %h",state, counter, inc_counter, clr_counter);

endmodule
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
